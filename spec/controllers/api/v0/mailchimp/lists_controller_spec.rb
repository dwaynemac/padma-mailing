#encoding: UTF-8
require 'spec_helper'

describe Api::V0::Mailchimp::ListsController do
  let(:list){create(:mailchimp_list)}
  let(:account){create(:account)}
  let(:contact){create(:contact)}
  before do
    PadmaContact.stub(:search).and_return([PadmaContact.new(id: 1234)])
    ActivityStream::Activity.stub(:new)
    Mailchimp::List.any_instance.stub_chain(:mailchimp_configuration, :account).and_return(account)
  end
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
        Mailchimp::List.any_instance.should_receive(:subscription_change).with("Has been subscribed to list: #{list.name}", 1234)
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
        Mailchimp::List.any_instance.should_receive(:subscription_change).with("Has been unsubscribed from list: #{list.name}", 1234)
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
        Mailchimp::List.any_instance.should_receive(:inform_campaign).with("Campaign newcamp sent")
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
        Mailchimp::List.any_instance.should_not_receive(:inform_campaign).with("Campaign newcamp sent")
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
