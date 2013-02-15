require 'spec_helper'

describe Account do

  before do
    @account = FactoryGirl.create(:account)
    PadmaAccount.stub!(:find).and_return(PadmaAccount.new(:name => @account.name, :enabled => true))
  end

  subject { @account }

  it {should validate_presence_of :name}
  it {should validate_uniqueness_of :name}

  it { should have_many(:templates).with_foreign_key(:local_account_id)}

  describe "#padma" do
    it "should give access to padma accounts api" do
      @account.padma.should be_a(PadmaAccount)
    end

    describe ".enabled?" do
      it "should show if account is enabled in padma-accounts ws" do
        @account.padma.enabled?.should be_true
      end
    end
  end
end
