class Segment < ActiveRecord::Base
  attr_accessible :api_id, :query, :name
  belongs_to :list
  
  serialize :query, Hash
  
  before_create :create_mailchimp_segment
  
  private
  
  def create_mailchimp_segment
    @mailchimp = self.list.mailchimp
    @api = @mailchimp.api         
    ret = @api.lists.segment-add({
      id: self.list.api_id
      name: self.name
      opts: {
        
      }
    })
  end
  
  def create_opts
    opts = Hash.new
    opts['match'] = 'all'
    opts['conditions'] = [
            
    ]
  end
  
end
