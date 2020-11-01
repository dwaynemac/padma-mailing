require 'spec_helper'

describe Account do
  let(:account) { FactoryGirl.create(:account) }
  before(:each) do
    allow(PadmaAccount).to receive(:find).and_return(PadmaAccount.new(:name => account.name, :enabled => true))
  end
  subject { account }

  it {should validate_presence_of :name}
  it {should validate_uniqueness_of :name}

  it { should have_many(:templates).class_name('Template').with_foreign_key(:local_account_id)}

  describe "#padma" do
    it "should give access to padma accounts api" do
      expect(account.padma).to be_a(PadmaAccount)
    end

    describe ".enabled?" do
      it "should show if account is enabled in padma-accounts ws" do
        expect(account.padma.enabled?).to be_truthy
      end
    end
  end
end
