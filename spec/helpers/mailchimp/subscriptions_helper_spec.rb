require 'spec_helper'

describe Mailchimp::SubscriptionsHelper do
  describe "mailchimp_enabled?" do
    subject { mailchimp_enabled? }
    describe "if account has no enabled_petals ([])" do
      let(:enabled_petals){[]}
      before { stub_current_user }
      it { should be_false }
    end
    describe "if account has enabled_petals nil" do
      let(:enabled_petals){nil}
      before { stub_current_user }
      it { should be_false }
    end
    describe "if account has other enabled petals, not mailchimp" do
      let(:enabled_petals){%W(petal1 petal2)}
      before { stub_current_user }
      it { should be_false }
    end
    describe "if account has mailchimp in its enabled petals" do
      let(:enabled_petals){%W(petal1 petal2 mailchimp)}
      before { stub_current_user }
      it { should be_true }
    end
  end

  def stub_current_user
    @account = FactoryGirl.create(:account)
    pa = PadmaAccount.new(name: @account.name, enabled: true, enabled_petals: enabled_petals)
    Account.any_instance.stub(:padma).and_return(pa)

    @user = FactoryGirl.create(:user)
    pu = PadmaUser.new(username: @user.username)

    @user.stub(:current_account).and_return(@account)

    User.any_instance.stub(:padma_enabled?).and_return true
    User.any_instance.stub(:padma).and_return pu
    
    # hack to stub current_user
    (1..10).each do |i|
      (1..10).each do |j|
        begin
          eval "RSpec::Core::ExampleGroup::Nested_#{i}::Nested_1::Nested_#{j}.any_instance.stub(:current_user).and_return(@user)"
        rescue NameError
        end
      end
    end
  end
end
