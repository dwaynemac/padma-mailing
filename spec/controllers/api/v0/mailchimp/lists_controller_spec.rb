#encoding: UTF-8
require 'spec_helper'

describe Api::V0::Mailchimp::ListsController do
  before do
    allow(PadmaContact).to receive(:search).and_return([PadmaContact.new(id: 1234)])
    allow(ActivityStream::Activity).to receive(:new)
    allow_any_instance_of(Mailchimp::List).to receive_message_chain(:mailchimp_configuration, :account).and_return(account)
    allow_any_instance_of(Mailchimp::List).to receive(:add_webhook)
    allow_any_instance_of(Mailchimp::Configuration).to receive(:sync_mailchimp_lists_locally)
    allow_any_instance_of(Mailchimp::List).to receive(:mailchimp_configuration).and_return(conf)
    I18n.default_locale = "en"
  end
  let(:account){create(:account)}
  let(:conf){
    c = build(:mailchimp_configuration, local_account_id: account.id)
    c.save(:validate => false)
    c
  }
  let(:list){create(:mailchimp_list, mailchimp_configuration: conf)}
  let(:contact){create(:contact)}
  describe "#webhooks" do
    context "without api key" do
      before do
        get :webhooks,
          id: list.id
      end
      it { should respond_with 200 }
    end
    context "on subscribe" do
      before do
        expect_any_instance_of(Mailchimp::List).to receive(:subscription_change).with(I18n.t("mailchimp.webhook.subscribed_to", list_name: list.name), 1234)
      end
      it "should create an activity" do
        get :webhooks,
          id: list.id,
          "type" => "subscribe",
          "fired_at" => "2009-03-26 21:35:57",
          "data" => {
            "id" => "8a25ff1d98", 
            "list_id"=>"a6b5da1054",
            "email"=>"api@mailchimp.com", 
            "email_type"=>"html", 
            "merges" => {
              "EMAIL"=>"api@mailchimp.com", 
              "FNAME"=>"MailChimp", 
              "LNAME"=>"API", 
              "INTERESTS"=>"Group1,Group2", 

            },
            "ip_opt"=>"10.20.10.30", 
            "ip_signup"=>"10.20.10.30"
          }
      end
    end
    context "on unsubscribe" do
      before do
        expect_any_instance_of(Mailchimp::List).to receive(:subscription_change).with(I18n.t("mailchimp.webhook.unsubscribed_from", list_name: list.name), 1234)
      end
      it "should create an activity" do
        get :webhooks,
          id: list.id,
          "type" => "unsubscribe",
          "fired_at" => "2009-03-26 21:35:57",
          "data" => {
            "action" => "unsub",
            "reason" => "manual",
            "id" => "8a25ff1d98", 
            "list_id"=>"a6b5da1054",
            "email"=>"api@mailchimp.com", 
            "email_type"=>"html", 
            "merges" => {
              "EMAIL"=>"api@mailchimp.com", 
              "FNAME"=>"MailChimp", 
              "LNAME"=>"API", 
              "INTERESTS"=>"Group1,Group2", 

            },
            "ip_opt"=>"10.20.10.30", 
            "ip_signup"=>"10.20.10.30"
          }
      end
    end
    context "on campaign sent" do
      before do
        expect_any_instance_of(Mailchimp::List).to receive(:inform_campaign).with("newcamp")
      end
      it "should create an activity" do
        get :webhooks,
          id: list.id,
          "type" => "campaign",
          "fired_at" => "2009-03-26 21:35:57",
          "data" => {
            "id" => "8a25ff1d98", 
            "list_id"=>"a6b5da1054",
            "subject"=>"newcamp", 
            "status"=>"sent"
          }
      end
    end
    context "on campaign not sent" do
      before do
        expect_any_instance_of(Mailchimp::List).not_to receive(:inform_campaign).with("Campaign newcamp from list #{list.name} sent")
      end
      it "should create an activity" do
        get :webhooks,
          id: list.id,
          "type" => "campaign",
          "fired_at" => "2009-03-26 21:35:57",
          "data" => {
            "id" => "8a25ff1d98", 
            "list_id"=>"a6b5da1054",
            "subject"=>"newcamp", 
            "status"=>"ready"
          }
      end
    end
  end
end
