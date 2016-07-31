class Merge

  attr_accessor :son_id, :parent_id

  def initialize(son_id, parent_id)
    self.son_id = son_id
    self.parent_id = parent_id
  end

  def merge
    ScheduledMail.where(contact_id: son_id).update_all(contact_id: parent_id)
  end


end
