require 'spec_helper'

describe MailModel do

  it { should validate_presence_of :subject }
  it { should validate_presence_of :name }
  it { should validate_presence_of :account_id }
end
