require 'spec_helper'

describe ScheduledMail do
  before do
    RSpec::Mocks.proxy_for(PadmaAccount).reset
    PadmaAccount.stub(:find).and_return(PadmaAccount.new(full_name: 'acc-name',
                                                         email: 'acc@mail.co'))
  end
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
      context "if shceduled mail has conditions" do
        let(:sm){create(:scheduled_mail, contact_id: 1, conditions: ActiveSupport::JSON.encode({status: "student"}))}
        it { should have_key "conditions" }
      end
    end
  end
  
  describe "get_from_display_name" do
    subject{sm.get_from_display_name}
    describe "when from_display_name is blank" do
      let(:sm){ build(:scheduled_mail, from_display_name: nil) }
      it "returns account's full_name" do
        should eq 'acc-name'
      end
    end
    describe "when from_display_name has no meta var" do
      let(:sm){ build(:scheduled_mail, from_display_name: 'given')}
      it "returns given from_display_name" do
        should eq 'given'
      end
    end
  end
  
  describe "get_from_email_address" do
    subject{sm.get_from_email_address}
    describe "when from_email_address is blank" do
      let(:sm){ build(:scheduled_mail, from_email_address: nil) }
      it "returns account's email" do
        should eq 'acc@mail.co'
      end
    end
    describe "when from_email_address has no meta var" do
      let(:sm){ build(:scheduled_mail, from_email_address: 'given@mail.co')}
      it "returns given from_email_address" do
        should eq 'given@mail.co'
      end
    end
  end
  
  describe "get_bccs" do
    subject{sm.get_bccs}
    describe "when bccs is blank" do
      let(:sm){ build(:scheduled_mail, bccs: nil) }
      it { should be_blank }
    end
    describe "when bccs has no meta var" do
      let(:sm){ build(:scheduled_mail, bccs: 'given@mail.co')}
      it "returns given bccs" do
        should eq 'given@mail.co'
      end
    end
  end
  context "when it has conditions" do
    before do
        PadmaUser.stub(:find).and_return(PadmaUser.new)
        PadmaContact.stub(:find).and_return(PadmaContact.new(status: "student", coefficient: "perfil"))
      end
    describe "and meets them" do
      let(:sm){ build(:scheduled_mail, contact_id: 1, conditions: ActiveSupport::JSON.encode({"status" => "student", "coefficient" => "perfil"})) }
      it "should send the mail" do
        contact_hash = sm.data_hash
        sm.conditions_met?(contact_hash).should be_true
      end
    end
    describe "and does not meet them" do
      let(:sm){ build(:scheduled_mail, contact_id: 1, conditions: ActiveSupport::JSON.encode({"status" => "former_student", "coefficient" => "perfil"})) }
      it "should not send the mail" do
        contact_hash = sm.data_hash
        sm.conditions_met?(contact_hash).should be_false
      end
    end
  end
  context "when it does not have conditions" do
    let(:sm){ build(:scheduled_mail, contact_id: 1, conditions: ActiveSupport::JSON.encode({})) }
    before do
      PadmaUser.stub(:find).and_return(PadmaUser.new)
      PadmaContact.stub(:find).and_return(PadmaContact.new(status: "student", coefficient: "perfil"))
    end
    it "should meet conditions" do
      contact_hash = sm.data_hash
      sm.conditions_met?(contact_hash).should be_true
    end
  end
end
