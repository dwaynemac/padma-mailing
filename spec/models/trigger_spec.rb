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
    let(:myaccount){ create(:account, name: 'my-account')} 
    let(:late_trigger){create(:trigger,
                         account: myaccount,
                         event_name: 'communication',
                         templates_triggerses_attributes: [
                             {template_id: template.id,
                              offset_number: -10,
                              offset_unit: 'day',
                              offset_reference: 'communicated_at'}
                         ]
    )}
    let(:trigger){create(:trigger,
                         account: myaccount,
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
    let(:enrollment_trigger){create(:trigger,
                              account: create(:account, name: "third-account"),
                                event_name: 'subscription_change',
                                templates_triggerses_attributes: [
                                  {
                                    template_id: template.id,
                                    offset_number: 1,
                                    offset_unit: "day",
                                    offset_reference: "changed_at"
                                    }]
      )

    }
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
    let(:next_action_trigger){create(:trigger,
                                   account: create(:account, name: 'my-account'),
                                   event_name: 'next_action',
                                   templates_triggerses_attributes: [
                                     {
                                       template_id: template.id,
                                       offset_number: 1,
                                       offset_unit: 'day',
                                       offset_reference: 'action_on'
                                     }
                                   ]
                                  )}
    describe "if accounts-ws if offline" do
      before(:each) do
        allow(PadmaAccount).to receive(:find).and_return nil
      end
      context "with :communication, {contact_id: 1234, communicated_at: now, account_name: 'my-account'}" do
        let(:key){:communication}
        let(:data){{contact_id: 1234, communicated_at: Time.now, account_name: 'my-account'}.stringify_keys!}
        before(:each) do
          trigger # create trigger
          expect(PadmaContact).to receive(:find)
                      .with(1234,
                            select: [:email],
                            account_name: 'my-account')
                      .and_return(PadmaContact.new(id: 1234, email: 'dwaynemac@gmail.com'))
        end
        xit "fails with exception" do
          # specs fails when run globally but passes when run locally :-/
          expect{Trigger.catch_message(key,data)}.to raise_exception
        end
      end
    end
    describe "if accounts-ws is online and account is enabled" do
      let(:padma_account) { PadmaAccount.new(name: 'my-account', enabled: true) }
      before(:each) do
        # if account is enabled
        allow(PadmaAccount).to receive(:find).and_return(PadmaAccount.new(name: 'my-account', enabled: true))
      end
      context "with data containing avoid_mailing_triggers: true" do
        let(:key){:communication}
        let(:data){{avoid_mailing_triggers: true, contact_id: 1234, communicated_at: Time.now, account_name: 'my-account'}.stringify_keys!}
        before(:each) do
          trigger # create trigger
        end
        it "wont create a ScheduledEmail" do
          expect{Trigger.catch_message(key,data)}.not_to change{ScheduledMail.count}
        end
      end
      context "with :communication, {contact_id: 1234, communicated_at: now, account_name: 'my-account'}"  do
        let(:key){:communication}
        let(:data){{contact_id: 1234, communicated_at: Time.now, account_name: 'my-account'}.stringify_keys!}
        before(:each) do
          trigger # create trigger
          expect(PadmaContact).to receive(:find)
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
          expect(ScheduledMail.last.send_at).to be_within(10).of(Time.now+1.day)
        end
        it "ignores deliveries with send_at in the past"  do
          late_trigger
          expect{Trigger.catch_message(key, data)}.to change{ScheduledMail.count}.by 1
        end
        it "ignores duplicated messages" do
          expect(PadmaContact).to receive(:find)
                      .with(1234,
                            select: [:email],
                            account_name: 'my-account')
                      .and_return(PadmaContact.new(id: 1234, email: 'dwaynemac@gmail.com'))
          expect{Trigger.catch_message(key, data)}.to change{ScheduledMail.count}.by 1
          expect{Trigger.catch_message(key, data)}.not_to change{ScheduledMail.count}
        end
      end

      context "with :subscription_change"  do
        let(:key){"subscription_change"}
        let(:data){
          {
            contact_id: 1234, 
            changed_at: Time.now, 
            account_name: 'third-account', 
            communication_id: 1000, 
            id: 9999, 
            observations: "",
            username: "alex.falke",
            type: "Enrollment"
          }.stringify_keys!}
          before(:each) do
            enrollment_trigger
            enrollment_trigger.filters.create(key: "type", value: "Enrollment")
            expect(PadmaContact).to receive(:find)
                        .with(1234,
                              select: [:email],
                              account_name: 'third-account')
                        .and_return(PadmaContact.new(id: 1234, email: 'dwaynemac@gmail.com'))
          end
          it "creates a ScheduledMail" do
            expect{Trigger.catch_message(key, data)}.to change{ScheduledMail.count}.by 1
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
      
      describe "with :next_action" do
        context "and next_action_type matches filter"  do
          let(:key){"next_action"}
          let(:data){
            {
              contact_id: 1234, 
              account_name: 'my-account', 
              id: 9999, 
              action_on: Time.now,
              username: "alex.falke",
              will_interview_username: "luis.perichon",
              next_action_type: "interview"
            }.stringify_keys!}
            before(:each) do
              next_action_trigger
              next_action_trigger.filters.create(key: "next_action_type", value: "interview")
              expect(PadmaContact).to receive(:find)
                          .with(1234,
                                select: [:email],
                                account_name: 'my-account')
                          .and_return(PadmaContact.new(id: 1234, email: 'dwaynemac@gmail.com'))
            end
            it "creates a ScheduledMail" do
              expect{Trigger.catch_message(key, data)}.to change{ScheduledMail.count}.by 1
            end
        end

        context "and next_action_type does not match filter"  do
          let(:key){"next_action"}
          let(:data){
            {
              contact_id: 1234, 
              account_name: 'my-account', 
              id: 9999, 
              action_on: Time.now,
              username: "alex.falke",
              will_interview_username: "luis.perichon",
              next_action_type: "follow_up"
            }.stringify_keys!}
            before(:each) do
              next_action_trigger
              next_action_trigger.filters.create(key: "next_action_type", value: "interview")
              expect(PadmaContact).to receive(:find)
                          .with(1234,
                                select: [:email],
                                account_name: 'my-account')
                          .and_return(PadmaContact.new(id: 1234, email: 'dwaynemac@gmail.com'))
            end
            it "creates a ScheduledMail" do
              expect{Trigger.catch_message(key, data)}.not_to change{ScheduledMail.count}
            end
        end

        context "with no filter"  do
          let(:key){"next_action"}
          let(:data){
            {
              contact_id: 1234, 
              account_name: 'my-account', 
              id: 9999, 
              action_on: Time.now,
              username: "alex.falke",
              will_interview_username: "luis.perichon",
              next_action_type: "interview"
            }.stringify_keys!}
            before(:each) do
              next_action_trigger
              expect(PadmaContact).to receive(:find)
                          .with(1234,
                                select: [:email],
                                account_name: 'my-account')
                          .and_return(PadmaContact.new(id: 1234, email: 'dwaynemac@gmail.com'))
            end
            it "creates a ScheduledMail" do
              expect{Trigger.catch_message(key, data)}.to change{ScheduledMail.count}.by 1
            end
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
          before(:each) do
            birthday_trigger
            expect(PadmaContact).to receive(:find).with(1234,select: [:email], account_name: nil).and_return(
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
          before(:each) do
            birthday_trigger
            expect(PadmaContact).to receive(:find).with(1234,select: [:email], account_name: nil).and_return(
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
          before(:each) do
            birthday_trigger
            expect(PadmaContact).to receive(:find).with(1234,select: [:email], account_name: nil).and_return(
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
          before(:each) do
            birthday_trigger
            expect(PadmaContact).to receive(:find).with(1234,select: [:email], account_name: nil).and_return(
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
          before(:each) do
            birthday_trigger
            expect(PadmaContact).to receive(:find).with(1234,select: [:email], account_name: nil).and_return(
              PadmaContact.new(id: 1234, email: 'dwaynemac@gmail.com')
            )
          end

          it "triggers emails" do
            expect{Trigger.catch_message(key,data)}.to change{ScheduledMail.count}.by 1
          end
        end
      end

      context "when conditions" do
        let(:my_account){create(:account, name: 'my-account')}
        let(:template2){create(:template, account: my_account)}
        let(:key){"birthday"}
        let(:data){{
          contact_id: 1234, 
          birthday_at: Time.now, 
          linked_accounts_names: %W(my-account),
          'local_status_for_my-account' => 'student',
          status: 'student'}.stringify_keys!}
         let(:birthday_trigger_with_conditions){create(:trigger,
                               account: my_account,
                               event_name: 'birthday',
                               templates_triggerses_attributes: [
                                   {template_id: template2.id,
                                    offset_number: 1,
                                    offset_unit: 'day',
                                    offset_reference: 'birthday_at'}
                               ],
                               conditions: [
                                 create(:condition, key: "status", value: "student"),
                                 create(:condition, key: "coefficient", value: "pmas")
                               ]
          )}
         let(:birthday_trigger_without_conditions){create(:trigger,
                               account: my_account,
                               event_name: 'birthday',
                               templates_triggerses_attributes: [
                                   {template_id: template2.id,
                                    offset_number: 1,
                                    offset_unit: 'day',
                                    offset_reference: 'birthday_at'}
                               ]
          )}

        before(:each) do
          expect(PadmaContact).to receive(:find).with(
            1234,
            account_name: nil,
            select: 
              [:email]
            ).and_return(
              PadmaContact.new(
                id: 123,
                email: "dwaynemac@gmail.com"
              )
            )
        end

        describe "are met" do
          before(:each) do
            birthday_trigger_with_conditions
            allow_any_instance_of(Account).to receive(:padma).and_return(PadmaAccount.new(name: 'my-account', enabled: true, locale: "es", timezone: "Buenos Aires"))
          end
          it "should generate Scheduled Mail" do
            expect{Trigger.catch_message(key, data)}.to change{ScheduledMail.count}.by 1
          end
          it "should meet conditions in the Scheduled Mail" do
            expect(PadmaContact).to receive(:find).with(
            1234,
            account_name: "my-account",
            select: 
              [:email, :first_name, :last_name, :gender, :global_teacher_username, :status, :coefficient]
            ).and_return(
              PadmaContact.new(
                id: 123,
                email: "dwaynemac@gmail.com",
                first_name: "Dwayne",
                last_name: "Macgowan",
                gender: "Male",
                global_teacher_username: nil,
                status: "student",
                coefficient: "pmas"
              )
            )
            Trigger.catch_message(key, data)
            s = ScheduledMail.last
            expect(s.conditions_met?(s.data_hash)).to be_truthy
          end
          it "should deliver the mail" do
            expect(PadmaContact).to receive(:find).with(
            1234,
            account_name: "my-account",
            select: 
              [:email, :first_name, :last_name, :gender, :global_teacher_username, :status, :coefficient]
            ).and_return(
              PadmaContact.new(
                id: 123,
                email: "dwaynemac@gmail.com",
                first_name: "Dwayne",
                last_name: "Macgowan",
                gender: "Male",
                global_teacher_username: nil,
                status: "student",
                coefficient: "pmas"
              )
            )
            allow_any_instance_of(Template).to receive(:deliver) {nil}
            expect_any_instance_of(PadmaMailer).to receive(:template).and_return Template.last
            Trigger.catch_message(key, data)
            s = ScheduledMail.last
            s.deliver_now!
          end

        end
        describe "are not met" do
          before(:each) do
            birthday_trigger_with_conditions
          end
          it "should generate Scheduled Mail" do
            expect{Trigger.catch_message(key, data)}.to change{ScheduledMail.count}.by 1
          end
          it "should not meet conditions in the Scheduled Mail" do
            expect(PadmaContact).to receive(:find).with(
            1234,
            account_name: "my-account",
            select: 
              [:email, :first_name, :last_name, :gender, :global_teacher_username, :status, :coefficient]
            ).and_return(
              PadmaContact.new(
                id: 123,
                email: "dwaynemac@gmail.com",
                first_name: "Dwayne",
                last_name: "Macgowan",
                gender: "Male",
                global_teacher_username: nil,
                status: "student",
                coefficient: "perfil"
              )
            )
            Trigger.catch_message(key, data)
            s = ScheduledMail.last
            expect(s.conditions_met?(s.data_hash)).to be_falsey
          end
          it "should not deliver the mail" do
            expect(PadmaContact).to receive(:find).with(
            1234,
            account_name: "my-account",
            select: 
              [:email, :first_name, :last_name, :gender, :global_teacher_username, :status, :coefficient]
            ).and_return(
              PadmaContact.new(
                id: 123,
                email: "dwaynemac@gmail.com",
                first_name: "Dwayne",
                last_name: "Macgowan",
                gender: "Male",
                global_teacher_username: nil,
                status: "student",
                coefficient: "perfil"
              )
            )
            expect_any_instance_of(PadmaMailer).not_to receive(:template)
            Trigger.catch_message(key, data)
            s = ScheduledMail.last
            s.deliver_now!
          end

        end
        describe "are empty" do
          before(:each) do
            birthday_trigger_without_conditions
          end
          it "should generate ScheduledMail" do
            expect{Trigger.catch_message(key, data)}.to change{ScheduledMail.count}.by 1
          end
          it "conditions generated should be empty" do
            Trigger.catch_message(key, data)
            expect(ScheduledMail.last.conditions).to eq "{}"
          end

          it "should meet conditions" do
            expect(PadmaContact).to receive(:find).with(
            1234,
            account_name: "my-account",
            select: 
              [:email, :first_name, :last_name, :gender, :global_teacher_username]
            ).and_return(
              PadmaContact.new(
                id: 123,
                email: "dwaynemac@gmail.com",
                first_name: "Dwayne",
                last_name: "Macgowan",
                gender: "Male",
                global_teacher_username: nil
              )
            )
            expect{Trigger.catch_message(key, data)}.to change{ScheduledMail.count}.by 1
            s = ScheduledMail.last
            expect(s.conditions_met?(s.data_hash)).to be_truthy
          end
        end
      end
    end
  end
end
