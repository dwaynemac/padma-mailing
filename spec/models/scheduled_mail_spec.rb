require 'spec_helper'

describe ScheduledMail do
  it { should belong_to(:account).with_foreign_key(:local_account_id) }
  it { should belong_to(:template) }

  it { should validate_presence_of :recipient_email }

  describe "data_hash" do
    subject{sm.data_hash}
    context "with accounts-ws and contacts-ws online" do
      before do
        PadmaUser.stub(:find).and_return(PadmaUser.new)
        PadmaContact.stub(:find).and_return(PadmaContact.new)
      end
      context "if scheduled mail has contact_id" do
        let(:sm){create(:scheduled_mail, contact_id: 1)}
        it { should have_key 'contact' }
        it { should have_key 'persona' }
      end
      context "if scheduled mail data has no contact_id" do
        let(:sm){create(:scheduled_mail, data: data)}
        context "and data has contact_id" do
          let(:data){ActiveSupport::JSON.encode({contact_id: 1})}
          it { should have_key 'contact' }
          it { should have_key 'persona' }
        end
        context "and data does not have contact_id" do
          let(:data){nil}
          it { should_not have_key 'contact' }
          it { should_not have_key 'persona' }
        end
      end
      context "if scheduled mail has username" do
        let(:sm){create(:scheduled_mail, username: 'xx')}
        it { should have_key 'instructor' }
      end
      context "if scheduled mail has no username" do
        let(:sm){create(:scheduled_mail, username: nil, data: data)}
        context "if data has username" do
          let(:data){ActiveSupport::JSON.encode({username: 'asd'})}
          it { should have_key 'instructor' }
        end
        context "if data does not have username" do
          let(:data){nil}
          it { should_not have_key 'instructor' }
        end
      end
    end
  end
end
