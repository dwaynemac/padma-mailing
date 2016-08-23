class Merge

  attr_accessor :son_id, :parent_id

  def initialize(son_id, parent_id)
    self.son_id = son_id
    self.parent_id = parent_id
  end

  def merge
    ScheduledMail.where(contact_id: son_id).each do |sm|
      if sm.data
        parsed_data = JSON.parse(sm.data) 
        if parsed_data["contact_id"] && parsed_data["contact_id"] == son_id
          parsed_data["contact_id"] = parent_id
          sm.data = parsed_data.to_json
        end
      end
      sm.contact_id = parent_id
      sm.save
    end

  end


end
