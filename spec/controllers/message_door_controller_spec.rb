require 'spec_helper'

describe MessageDoorController do

  # TODO
  #   
  # genero este error
  #  (no hay account)
  #  NoMethodError (undefined method `padma' for nil:NilClass):
  #    app/controllers/application_controller.rb:49:in `set_timezone'
  #

  before do
    Delayed::Worker.delay_jobs = false
    # if account is enabled
    PadmaAccount.stub(:find).and_return PadmaAccount.new(name: 'stubbedAccount', enabled: true)
  end

  describe "real life example" do
    before do
      PadmaContact.stub(:find).and_return PadmaContact.new email: 'dwa@asd.com'
      account = create(:account, name: 'testing')
      template = create(:template, account: account )
      t = create(:trigger, event_name: 'subscription_change', account: account)
      create(:templates_trigger, trigger: t, template: template,
             offset_number: 0, offset_reference: 'changed_at',
             offset_unit: 'days')

      get :catch,
          secret_key: ENV['messaging_secret'],
          key_name: 'subscription_change',
          data: ActiveSupport::JSON.encode({
            account_name: 'testing',
            changed_at: '2115-01-16',
            communication_id: 147359,
            contact_id: '54b96053d212ef7f5b00039b',
            created_at: '2115-01-16T19:03:07Z',
            id: 50151,
            level_cache: nil,
            observations: 'a',
            posted_to_messaging: false,
            public: nil,
            updated_at: '2115-01-16T19:03:07Z',
            username: 'developer',
            type: 'Enrollment'})
    end
    it { should respond_with 200 }
    it "should schedule mail" do
      expect(ScheduledMail.count).to eq 1
    end
  end

  describe "GET /message_door (#catch)" do
    let(:data){{ type: 'Enrollment',
            changed_at: '2014-8-23',
            account_name: 'recoleta',
            contact_id: '1234'
          }}
    context "with NON-valid secret_key" do
      let(:sk){'as'}
      before do
        get :catch,
            secret_key: sk,
            key_name: 'subscription_change',
            data: ActiveSupport::JSON.encode(data)
      end
      it { should respond_with 403 }
    end
    context "with VALID secret_key" do
      let(:sk){ENV['messaging_secret']}
      before do
        get :catch,
            secret_key: sk,
            key_name: 'subscription_change',
            data: ActiveSupport::JSON.encode(data)
      end
      it { should respond_with 200 }
    end
  end
end
