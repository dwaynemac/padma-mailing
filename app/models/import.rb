require "open-uri"
require "csv"

class Import < ActiveRecord::Base
  attr_accessible :csv_file, :headers, :status, :type
  attr_accessor   :mail_header, :mail_header_content_type, :mail_header_file_name, :mail_header_file_size, :mail_header_updated_at,
                  :mail_footer, :mail_footer_content_type, :mail_footer_file_name, :mail_footer_file_size, :mail_footer_updated_at

  belongs_to :account, class_name: "Account", foreign_key: :local_account_id
  validates_presence_of :account

  has_many :import_details
  has_many :imported_ids
  has_many :failed_rows

  serialize :headers, Array

  VALID_STATUS = [:ready, :working, :finished]

  after_create :set_defaults
  validate :validate_headers

  has_attached_file :csv_file,
        :path => "/system/import/:id/:filename",
        :url => "/system/import/:id/:filename"

  do_not_validate_attachment_file_type :csv_file
  
  # Mail header and footer are stored in S3. The 'preserve_files'
  #  option preserves the file even when the import is deleted
  has_attached_file :mail_header, { :preserve_files => "true" }
  has_attached_file :mail_footer, { :preserve_files => "true" }

  # Sets account by name
  # @param [String] name
  def account_name=(name)
    self.account = Account.find_or_create_by_name(name)
  end
  
  # It returns column number for given attribute according to headers
  # @param [String] attribute_name
  def index_for(attribute_name)
    self.headers.index(attribute_name)
  end

  # @param [CSV::Row] row
  # @param [String] attribute_name
  def value_for(row,attribute_name)
    row[index_for(attribute_name)]
  end

  # overrride this method on child class
  def valid_headers
    %W(name description subject content trigger header_image_url footer_image_url)
  end

  # Override this on child class
  # @param [CSV::Row]
  # @param [Integer] row index
  # @return [ImportDetail] 
  def handle_row(row, row_i)
    template = Template.new
    template.name = value_for(row, 'name')
    template.description = value_for(row, 'description')
    template.subject = value_for(row, 'subject')
    template.content = build_template_content(value_for(row, 'content'))
    template.account = self.account
    
    trigger = build_template_trigger( value_for(row, 'trigger'))
    #template.templates_triggerses.new(trigger_id: trigger.id)

    if template.save
      if !trigger.nil?
        trigger.templates_triggerses.create(template_id: template.id)
        set_template_offset(template, value_for(row, 'trigger'))
      end
      ImportedId.new(value: template.id)
    else
      trigger.destroy
      FailedRow.new(value: row_i, message: template.errors.messages.map{|attr,err_array| "#{attr}: #{err_array.join(' and ')}" }.join(' AND '))
    end

  end

  def process_CSV
    return unless self.status.to_sym == :ready
    
    begin
      log "processing csv"

      self.update_attribute(:status, :working)

      unless csv_file_handle.nil?
        # set header and footer
        first_row = CSV.open(csv_file_handle, "rb",{:headers => true}) {|csv| csv.first}

        set_import_header_and_footer(value_for(first_row, 'header_image_url'),value_for(first_row, 'footer_image_url'))
        
        row_i = 1 # start at 1 because first row is skipped
        CSV.foreach(csv_file_handle, encoding:"UTF-8:UTF-8", headers: :first_row) do |row|
          log "row #{row_i}"
          begin
            log "     ok"
            self.import_details << handle_row(row, row_i)
            self.import_details.last.save
          rescue => e
            log "     failed"
            self.import_details << FailedRow.new(value: row_i, message: "Exception: #{e.message}")
            self.import_details.last.save
          end
          row_i += 1
        end
      end

      self.status = :finished
      self.save
    rescue Exception => e
      Rails.logger.warn e.message
      self.update_attribute(:status, :failed)
    end
  end
  
  # @return [Contact]
  def map_contact(external_id)
    local_contact = Contact.where(external_sysname: 'Kshema', external_id: external_id).first
    if local_contact
      local_contact
    else
      c = PadmaContact.find_by_kshema_id(external_id)
      if c
        Contact.get_by_padma_id(c.id,self.account.id, c, {external_sysname: 'Kshema', external_id: external_id})
      end
    end
  end

  def failed_rows_to_csv
    import_csv = CSV.read(self.csv_file.path)
    unless import_csv.nil?
      CSV.generate do |failed_rows_csv|
        failed_rows_csv << ['row'] + self.headers + ['error message'] 
        self.failed_rows.each do |failed_row|
          failed_rows_csv << [failed_row.value] + import_csv[failed_row.value] + [failed_row.message]
        end
      end 
    end
  end

  private

  def build_template_content(content)
    if !self.mail_header.nil? || self_mail_header.url.include?("missing")
      header_image_tag = %(<img src="#{self.mail_header.url}" border="0" /><br/>)
      content.gsub!(/{{header}}/, header_image_tag)
    end
    if !self.mail_footer.nil? || self_mail_footer.url.include?("missing")
      footer_image_tag = %(<br/><img src="#{self.mail_footer.url}" border="0" />)
      content.gsub!(/{{footer}}/, footer_image_tag)
    end
    content
  end

  def build_template_trigger(trigger_name)
    return nil if trigger_name.blank?

    trigger = Trigger.new
    trigger.local_account_id = self.account.id

    filters = []

    case trigger_name
      when 'birthday_alumnos'
        trigger_name = 'birthday'
        filters << {key: 'local_status', value: 'student'}
      when 'birthday_prospects'
        trigger_name = 'birthday'
        filters << {key: 'local_status', value: 'prospect'}
      when 'bienvenida'
        trigger_name = 'subscription_change'
        filters << {key: 'type', value: 'enrollment'}
      when 'fin_plan'
        trigger_name = 'membership'
      when 'remind_prueba'
        trigger_name = 'trial_lesson'
      when 'post_visita'
        trigger_name = 'communication'
        filters << {key: 'media', value: 'interview'}
      when 'post_first_month'
        trigger_name = 'subscription_change'
        filters << {key: 'type', value: 'enrollment'}
      when 'post_a_month_of_visit_not_signed_in'
        # mes después de la visita si no se inscribe y es perfil
        trigger_name = 'communication'
        filters << {key: 'local_status', value: 'prospect'}
        filters << {key: 'global_status', value: 'prospect'}
        filters << {key: 'estimated_coefficient', value: 'perfil'}
        filters << {key: 'estimated_coefficient', value: 'pmas'}
    end
    trigger.event_name = trigger_name
    filters.each do |f|
      trigger.filters.new(key: f[:key], value: f[:value])
    end
    trigger.save
    
    trigger 
  end

  def set_template_offset(template, trigger_name)
    offset_number = 0
    offset_unit = "days"
    offset_reference = nil
    case trigger_name
      when 'remind_prueba'
        offset_reference = "trial_at"
        offset_number = 1
      when 'post_first_month'
        offset_reference = "changed_at"
        offset_number = 1
        offset_unit = "months"
      when 'post_a_month_of_visit_not_signed_in'
        offset_reference = "communicated_at"
        offset_number = 1
        offset_unit = "months"
      when 'birthday_alumnos'
        offset_reference = "birthday_at"
      when 'birthday_prospects'
        offset_reference = "birthday_at"
      when 'bienvenida'
        offset_reference = "changed_at"
      when 'fin_plan'
        offset_reference = "ends_on"
        offset_number = 1
        offset_unit = "months"
      when 'post_visita'
        offset_reference = "communicated_at"
    end
    template.templates_triggerses.first.update_attributes(offset_number: offset_number, offset_unit: offset_unit, offset_reference: offset_reference) unless offset_reference.nil?
  end

  def csv_file_handle
    @csv_file_handle ||= if Rails.env.test? || Rails.env.development?
      open(self.csv_file.url)
    else
      open(self.csv_file.url)
    end
  end

  def set_defaults
    if self.status.nil?
      self.status = :ready
    end
    if self.imported_ids.nil?
      self.imported_ids = []
    end
    if self.failed_rows.nil?
      self.failed_rows = []
    end
  end

  def validate_headers
    if self.headers.nil? || self.headers.empty?
      return
    elsif self.valid_headers.nil?
      errors.add(:headers, 'invalid headers - check import type, there are no valid headers')
    else
      # compat headers, this way we consider nil valid
      unless (self.headers.reject {|x| x.blank?} - self.valid_headers).empty?
        errors.add(:headers, 'invalid headers')
      end
    end
  end

  def set_import_header_and_footer(original_mail_header_url, original_mail_footer_url)
    if original_mail_header_url.blank? || original_mail_header_url.include?("missing")
      self.mail_header = nil
    else
      self.mail_header = open(original_mail_header_url)
      self.mail_header.save
    end

    if original_mail_footer_url.blank? || original_mail_footer_url.include?("missing")
      self.mail_footer = nil
    else
      self.mail_footer = open(original_mail_footer_url)
      self.mail_footer.save
    end    
  end

  def log(txt)
    Rails.logger.debug "[#{self.type} #{self.id}] #{txt}"
  end
end
