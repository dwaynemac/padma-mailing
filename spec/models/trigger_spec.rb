require 'spec_helper'

describe Trigger do
  it { should belong_to(:account).with_foreign_key(:local_account_id) }
  it { should validate_presence_of(:local_account_id) }
  it { should have_many :filters }
  it { should have_many :templates }

  describe "#filters_match?" do
    let(:trigger){create(:trigger, filters_attributes: [
        {key: 'k1', value: 'v1'},
        {key: 'k2', value: 'v2'}
    ])}
    context "with data { k1: v1, k2: v2}" do
      let(:data){{ 'k1' => 'v1', 'k2' => 'v2'}}
      it "returns true" do
        trigger.filters_match?(data)
      end
    end
    context "with data { k1: v1, k2: v2, k3: v4}" do
      let(:data){{ 'k1' => 'v1', 'k2' => 'v2', 'k3' => 'v4'}}
      it "returns true" do
        trigger.filters_match?(data)
      end
    end
    context "with data { k1: v1}" do
      let(:data){{ 'k1' => 'v1'}}
      it "returns false" do
        trigger.filters_match?(data)
      end
    end
    describe "birthday" do
      it "see .catch_message with :birthday..." do
        assert true # for indexing
      end
    end
  end

  describe ".catch_message" do
    let(:template){create(:template)}
    let(:trigger){create(:trigger,
                         account: create(:account, name: 'my-account'),
                         event_name: 'communication',
                         templates_triggerses_attributes: [
                             {template_id: template.id,
                              offset_number: 1,
                              offset_unit: 'day',
                              offset_reference: 'communicated_at'}
                         ]
    )}
    let(:other_trigger){create(:trigger,
                         account: create(:account, name: 'other-account'),
                         event_name: 'communication',
                         templates_triggerses_attributes: [
                             {template_id: template.id,
                              offset_number: 1,
                              offset_unit: 'day',
                              offset_reference: 'communicated_at'}
                         ]
    )}
    let(:birthday_trigger){create(:trigger,
                               account: create(:account, name: 'my-account'),
                               event_name: 'birthday',
                               templates_triggerses_attributes: [
                                   {template_id: template.id,
                                    offset_number: 1,
                                    offset_unit: 'day',
                                    offset_reference: 'birthday_at'}
                               ]
    )}
    context "with data containing avoid_mailing_triggers: true" do
      let(:key){:communication}
      let(:data){{avoid_mailing_triggers: true, contact_id: 1234, communicated_at: Time.now, account_name: 'my-account'}.stringify_keys!}
      before do
        trigger # create trigger
      end
      it "wont create a ScheduledEmail" do
        expect{Trigger.catch_message(key,data)}.not_to change{ScheduledMail.count}
      end
    end
    context "with :communication, {contact_id: 1234, communicated_at: now, account_name: 'my-account'}" do
      let(:key){:communication}
      let(:data){{contact_id: 1234, communicated_at: Time.now, account_name: 'my-account'}.stringify_keys!}
      before do
        trigger # create trigger
        PadmaContact.should_receive(:find)
                    .with(1234,
                          select: [:email],
                          account_name: 'my-account')
                    .and_return(PadmaContact.new(id: 1234, email: 'dwaynemac@gmail.com'))
      end
      it "only matches triggers of 'my-account'" do
        other_trigger
        expect{Trigger.catch_message(key,data)}.to change{ScheduledMail.count}.by 1
      end
      it "calls PadmaContact" do
        Trigger.catch_message(key,data)
      end
      it "creates a ScheduledEmail" do
        expect{Trigger.catch_message(key,data)}.to change{ScheduledMail.count}.by 1
      end
      it "schedules email to now+1day" do
        Trigger.catch_message key, data
        ScheduledMail.last.send_at.should be_within(1).of(Time.now+1.day)
      end
    end

    context "with :communication, {contact_id: 1234, communicated_at: now, account_name: 'account-without-triggers'}" do
      let(:key){:communication}
      let(:data){{contact_id: 1234, communicated_at: Time.now, account_name: 'account-without-triggers'}.stringify_keys!}
      it "wont schedule emails" do
        trigger
        other_trigger
        expect{Trigger.catch_message key, data}.not_to change{ScheduledMail.count}
      end
    end

    context "with :birthday, {contact_id: 1234, birthday_at: now, account_name: 'my-account'}" do
      describe "if contact is a student of the account" do
        let(:key){"birthday"}
        let(:data){{
                      contact_id: 1234, 
                      birthday_at: Time.now, 
                      linked_accounts_names: %W(my-account),
                      'local_status_for_my-account' => 'student',
                      status: 'student'}.stringify_keys!}
        before do
          birthday_trigger
          PadmaContact.should_receive(:find).with(1234,select: [:email], account_name: nil).and_return(
              PadmaContact.new(id: 1234, email: 'dwaynemac@gmail.com'))
        end
        it "calls PadmaContact" do
          Trigger.catch_message(key,data)
        end
        it "creates a ScheduledEmail" do
          expect{Trigger.catch_message(key, data)}.to change{ScheduledMail.count}.by 1
        end
      end

      describe "if contact is not a student of the current account, but student of another school" do
        let(:key){"birthday"}
        let(:data){{
                      contact_id: 1234, 
                      birthday_at: Time.now, 
                      linked_accounts_names: %W(my-account),
                      'local_status_for_my-account' => 'prospect',
                      status: 'student'}.stringify_keys!}
        before do
          birthday_trigger
          PadmaContact.should_receive(:find).with(1234,select: [:email], account_name: nil).and_return(
              PadmaContact.new(id: 1234, email: 'dwaynemac@gmail.com'))
        end
        it "calls PadmaContact" do
          Trigger.catch_message(key,data)
        end
        it "should not create a ScheduledEmail" do
          expect{Trigger.catch_message(key, data)}.not_to change{ScheduledMail.count}
        end
      end

      describe "if contact is not a student of the current account, but no student of any other school" do
        let(:key){"birthday"}
        let(:data){{
                      contact_id: 1234, 
                      birthday_at: Time.now, 
                      linked_accounts_names: %W(my-account),
                      'local_status_for_my-account' => 'prospect',
                      status: 'prospect'}.stringify_keys!}
        before do
          birthday_trigger
          PadmaContact.should_receive(:find).with(1234,select: [:email], account_name: nil).and_return(
          PadmaContact.new(id: 1234, email: 'dwaynemac@gmail.com'))
        end
        it "calls PadmaContact" do
          Trigger.catch_message(key,data)
        end
        it "should create a ScheduledEmail" do
          expect{Trigger.catch_message(key, data)}.to change{ScheduledMail.count}.by 1
        end
      end

      describe "if contact is not linked to current account" do
        let(:key){'birthday'}
        let(:data){{
          contact_id: 1234,
          birthday_at: Time.now,
          status: 'prospect'}.stringify_keys!
        }
        before do
          birthday_trigger
          PadmaContact.should_receive(:find).with(1234,select: [:email], account_name: nil).and_return(
            PadmaContact.new(id: 1234, email: 'dwaynemac@gmail.com')
          )
        end
        it "wont trigger emails" do
          expect{Trigger.catch_message(key,data)}.not_to change{ScheduledMail.count}
        end
      end

      describe "if contact is linked to current account without a status" do
        let(:key){"birthday"}
        let(:data){{
            contact_id: 1234,
            birthday_at: Time.now,
            linked_accounts_names: %W(my-account),
            status: 'prospect'}.stringify_keys!
        }
        before do
          birthday_trigger
          PadmaContact.should_receive(:find).with(1234,select: [:email], account_name: nil).and_return(
            PadmaContact.new(id: 1234, email: 'dwaynemac@gmail.com')
          )
        end

        it "triggers emails" do
          expect{Trigger.catch_message(key,data)}.to change{ScheduledMail.count}.by 1
        end
      end
    end
  end
end
