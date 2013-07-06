#encoding: UTF-8
require 'spec_helper'

describe Api::V0::ScheduledMailsController do
  before do
    @account = FactoryGirl.create(:account)
    @email = "test@mail.com"
    @template = FactoryGirl.create(:template)
    @template.local_account_id = @account.id
    @template.update_attribute(:name, "test")
    @template.save
    @scheduled_mail = FactoryGirl.create(:scheduled_mail, recipient_email: @email)
    @scheduled_mail.update_attributes(local_account_id: @account.id, template_id: @template.id)
    @scheduled_mail.save
  end

  describe "#index" do
    before do
      PadmaAccount.stub!(:find).and_return(PadmaAccount.new(:name => @account.name, :enabled => true))
      @user = FactoryGirl.create(:user)
      sign_in(@user)
      get :index, format: :json, app_key: 'f06634e2ccb74104f3e8c8f56a136268', account_name: @account.name, username: @user.username,
          where: {recipient_email: @email}
    end
    it { response.should be_success }
    it "should return an array with one scheduled mail and a total number of 1" do
      body = JSON.parse(response.body)
      body.should include('total')
      body.should include('collection')
      body['collection'].last['recipient_email'].should == @email
      body['total'].should == 1
    end
  end
end