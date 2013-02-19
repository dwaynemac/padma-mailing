require 'spec_helper'

describe Trigger do
  it { should belong_to(:account).with_foreign_key(:local_account_id) }
  it { should validate_presence_of(:local_account_id) }
  it { should have_many :filters }
  it { should have_many :templates }
end
