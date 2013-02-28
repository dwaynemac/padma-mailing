# Expects base to respond to:
#   - contact_id
#   - id
#   - class
#   - username if no username is specified in options
#   - account_name if no account_name is specified in options
module RegistersActivity

  def initialize_creation_activity(content,options=nil)
    options = parse_options(options)
    ActivityStream::Activity.new(target_id: self.contact_id, target_type: 'Contact',
                                 object_id: self.id, object_type: self.class.to_s,
                                 generator: ActivityStream::LOCAL_APP_NAME,
                                 content: content,
                                 public: options[:public] || false,
                                 username: options[:username],
                                 account_name: options[:account_name],
                                 created_at: options[:created_at].to_s,
                                 updated_at: options[:updated_at].to_s
    )
  end

  def initialize_deletion_activity(content=nil,options =nil)
    content = "#{self.class}##{self.id} deleted" if content.nil?
    options = parse_options(options)
    ActivityStream::Activity.new(target_id: self.contact_id, target_type: 'Contact',
                                 object_id: self.id, object_type: self.class.to_s,
                                 generator: ActivityStream::LOCAL_APP_NAME,
                                 content: content,
                                 public: options[:public] || false,
                                 verb: 'deleted',
                                 username: options[:username],
                                 account_name: options[:account_name],
                                 created_at: options[:created_at].to_s,
                                 updated_at: options[:updated_at].to_s
    )
  end

  private

  def parse_options(options)
    options = {} if options.nil?
    options[:username] = self.username unless options[:username]
    options[:account_name] = self.account_name unless options[:account_name]
    options[:create_at] = Time.zone.now.to_s unless options[:created_at]
    options[:updated_at] = Time.zone.now.to_s unless options[:updated_at]
    options
  end
end