require 'spec_helper'

describe ScheduledMail do
  it { should belong_to(:account).with_foreign_key(:local_account_id) }
  it { should belong_to(:template) }

  it { should validate_presence_of :recipient_email }
end
