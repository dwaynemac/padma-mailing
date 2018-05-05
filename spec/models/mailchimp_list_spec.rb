require 'spec_helper'

describe Mailchimp::List do
  let(:configuration){FactoryGirl.create(:mailchimp_configuration, api_key: "1234")}
  let(:list){FactoryGirl.create(:mailchimp_list, receive_notifications: false, mailchimp_configuration: configuration)}
  before do
    allow_any_instance_of(Mailchimp::Configuration).to receive(:api_key_is_valid).and_return(true)
    allow_any_instance_of(Mailchimp::Configuration).to receive(:create_synchronizer).and_return(true)
    allow_any_instance_of(Mailchimp::Configuration).to receive(:sync_mailchimp_lists_locally).and_return(true)
  end
  describe "#add_webhook" do
    context "on fail" do
      before do
        allow_any_instance_of(Gibbon::Request).to receive_message_chain(:lists, :webhooks, :create, :body).and_return({"id"=> nil, errors: "some error"})
      end
      it "should not change receive notifications" do
        list.add_webhook_without_delay
        list.receive_notifications.should be_falsy
      end
      it "should show setted error" do
        list.add_webhook_without_delay
        list.errors.full_messages.first.should == "some error"
      end
    end
    context "on success" do
      before do
        allow_any_instance_of(Gibbon::Request).to receive_message_chain(:lists, :webhooks, :create, :body).and_return({"id"=> "1234", errors: "some error"})
      end
      it "should set receive notifications to true" do
        list.add_webhook_without_delay
        list.receive_notifications.should be_truthy
      end
    end
  end
end
