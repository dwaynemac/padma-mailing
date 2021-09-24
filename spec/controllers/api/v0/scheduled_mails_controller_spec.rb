#encoding: UTF-8
require 'rails_helper'

describe Api::V0::ScheduledMailsController do
  before do
    @account = FactoryBot.create(:account)
    @email = "test@mail.com"
    @template = FactoryBot.create(:template)
    @template.local_account_id = @account.id
    @template.update_attribute(:name, "test")
    @template.save
    @scheduled_mail = FactoryBot.create(:scheduled_mail, recipient_email: @email)
    @scheduled_mail.update_attributes(local_account_id: @account.id, template_id: @template.id)
    @scheduled_mail.save
  end

  describe "#index" do
    before do
      @user = FactoryBot.create(:user)
      get :index,
        format: :json,
        app_key: ENV['app_key'],
        account_name: @account.name,
        username: @user.username,
        where: {recipient_email: @email}
    end
    it { should respond_with 200 }
    it "should return an array with one scheduled mail and a total number of 1" do
      body = JSON.parse(response.body)
      expect(body).to include('total')
      expect(body).to include('collection')
      expect(body['collection'].last['recipient_email']).to eq @email
      expect(body['total']).to eq 1
    end
  end
end
