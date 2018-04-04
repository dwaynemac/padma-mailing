require 'spec_helper'

describe Mailchimp::SubscriptionsHelper do
  let(:pc){ Mailchimp::PetalController.new { include Mailchimp::SubscriptionController } }
  let(:user){ FactoryGirl.create(:user) }
  let(:padma_user){ PadmaUser.new(username: user.username) }
  let(:account){ FactoryGirl.create(:account) }
  let(:padma_account){ PadmaAccount.new(name: account.name, enabled: true, enabled_petals: enabled_petals) }

  before(:each) do
    allow(user).to receive(:current_account).and_return(account)
    allow_any_instance_of(User).to receive(:padma_enabled?).and_return true
    allow_any_instance_of(User).to receive(:padma).and_return padma_user
    allow_any_instance_of(Account).to receive(:padma).and_return(padma_account)
    allow_any_instance_of(Mailchimp::PetalController).to receive(:current_user).and_return(user)
  end

  describe "mailchimp_enabled?" do
    subject { pc.mailchimp_enabled? }
    describe "if account has no enabled_petals ([])" do
      let(:enabled_petals){[]}
      it { should be_falsey }
    end
    describe "if account has enabled_petals nil" do
      let(:enabled_petals){nil}
      it { should be_falsey }
    end
    describe "if account has other enabled petals, not mailchimp" do
      let(:enabled_petals){%W(petal1 petal2)}
      it { should be_falsey }
    end
    describe "if account has mailchimp in its enabled petals" do
      let(:enabled_petals){%W(petal1 petal2 mailchimp)}
      it { should be_truthy }
    end
  end
end
