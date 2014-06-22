require 'spec_helper'

describe ScheduledMail do
  it { should belong_to(:account).with_foreign_key(:local_account_id) }
  it { should belong_to(:template) }

  it { should validate_presence_of :recipient_email }

  describe "data_hash" do
    it "works if data is blank" do
      sm = create(:scheduled_mail, data: nil)
      expect{sm.data_hash}.not_to raise_exception
    end
  end
end
