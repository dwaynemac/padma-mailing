require 'spec_helper'

describe TemplatesController do
  describe "#index" do
    context "without params" do
      before do
        @account = FactoryGirl.create(:account)
        PadmaAccount.stub!(:find).and_return(PadmaAccount.new(:name => @account.name, :enabled => true))
        @user = FactoryGirl.create(:user)
        get :index
      end
      it { should respond_with(:success) } # response.should be_success
      it { should assign_to(:templates) }
      it "should show total amount of templates" do
        result = ActiveSupport::JSON.decode(templates.body)
        result["total"].should == 1
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
