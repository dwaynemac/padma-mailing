require 'rails_helper'

describe Mailchimp::List do
  let(:configuration){FactoryBot.create(:mailchimp_configuration, api_key: "1234")}
  let(:list){FactoryBot.create(:mailchimp_list, receive_notifications: false, mailchimp_configuration: configuration)}
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
        list.add_webhook
        expect(list.receive_notifications).to be_falsy
      end
      it "should show setted error" do
        list.add_webhook
        expect(list.errors.full_messages.first).to eq "some error"
      end
    end
    context "on success" do
      before do
        allow_any_instance_of(Gibbon::Request).to receive_message_chain(:lists, :webhooks, :create, :body).and_return({"id"=> "1234", errors: "some error"})
      end
      it "should set receive notifications to true" do
        list.add_webhook
        expect(list.receive_notifications).to be_truthy
      end
    end
  end
  describe "#create_activity" do
    before do
      allow_any_instance_of(Account).to receive(:padma).and_return(PadmaAccount.new(locale: "es", timezone: "Buenos Aires"))
      allow_any_instance_of(Mailchimp::List).to receive(:subscription_change).and_return(nil)
      allow_any_instance_of(Mailchimp::List).to receive(:add_webhook).and_return(nil)
      a = FactoryBot.create(:account)
      configuration.local_account_id = a.id
      u = FactoryBot.create(:user, current_account_id: a.id)
      allow_any_instance_of(Mailchimp::List).to receive(:get_contact_id_by_email).and_return(u.id)
    end
    it "should send message with correct locale" do
      I18n.locale = "en"
      params = {
        type: "subscribe",
        data: {
          email: "email@mail.com"
        }
      }
      list.create_activity(params)
      expect(I18n.locale).to eq :es
    end
    it "should send message with correct timezone" do
      Time.zone = "Sydney"
      params = {
        type: "subscribe",
        data: {
          email: "email@mail.com"
        }
      }
      list.create_activity(params)
      expect(Time.zone.name).to eq "Buenos Aires"
    end
  end
end
