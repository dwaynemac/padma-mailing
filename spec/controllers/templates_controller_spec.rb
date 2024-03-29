require 'rails_helper'

describe TemplatesController do
  describe "#index" do
    context "without params" do
      before do
        @account = FactoryBot.create(:account)
        allow(PadmaAccount).to receive(:find).and_return(PadmaAccount.new(name: @account.name, enabled: true))
        @user = FactoryBot.create(:user)
        pu = PadmaUser.new(username: @user.username)
        allow_any_instance_of(User).to receive(:padma_enabled?).and_return true
        allow_any_instance_of(User).to receive(:padma).and_return pu
        sign_in(@user)
        get :index
      end
      it { should respond_with(:success) } # response.should be_success
      it "should assign to templates" do
        expect(assigns(:templates)).not_to be_nil
      end
    end
  end

  describe "#create" do

  end

  describe "#destroy" do

  end

  describe "#update" do

  end

end
