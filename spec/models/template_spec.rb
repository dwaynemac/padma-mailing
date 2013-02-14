require 'spec_helper'

describe Template do
  it { should validate_presence_of :subject }
  it { should validate_presence_of :name }

  it { should belong_to(:account).with_foreign_key(:local_account_id)}
  it { should validate_presence_of :account }
end
