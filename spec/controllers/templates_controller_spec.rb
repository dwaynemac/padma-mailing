require 'spec_helper'

describe TemplatesController do
  describe "#index" do
    context "without params" do
      before do
        @account = FactoryGirl.create(:account)
        PadmaAccount.stub!(:find).and_return(PadmaAccount.new(name: @account.name, enabled: true))
        @user = FactoryGirl.create(:user)
        pu = PadmaUser.new(username: @user.username)
        User.any_instance.stub(:padma_enabled?).and_return true
        User.any_instance.stub(:padma).and_return pu
        sign_in(@user)
        get :index
      end
      it { should respond_with(:success) } # response.should be_success
      it "should assign to templates" do
        assigns(:templates).should_not be_nil
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
