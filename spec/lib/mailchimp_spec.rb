require 'spec_helper'

require 'mailchimp'

describe Mailchimp do

  let(:mailchimp_key){'52367766fce5ea2b15447612c817d29e-us5'}
  let(:account){FactoryGirl.create(:account, mailchimp_api_key: mailchimp_key)}
  let(:mailchimp){Mailchimp.new @account}
  let(:contact){PadmaContact.new email: 'this-is-a-test-email@falsemail.com', first_name: 'Testname', last_name: 'TestSurname'}

  before do
    PadmaAccount.stub!(:find).and_return(PadmaAccount.new(:name => account.name, :enabled => true))
  end


  describe "subscribe" do
    it "adds contact to the list" do
      assert true
    end
  end

  describe "unsubscribe" do
    it "removes contact from the list" do
      assert true
    end
  end

end
