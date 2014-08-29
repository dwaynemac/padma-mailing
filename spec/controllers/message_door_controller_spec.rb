require 'spec_helper'

describe MessageDoorController do

  # TODO
  #   
  # genero este error
  #  (no hay account)
  #  NoMethodError (undefined method `padma' for nil:NilClass):
  #    app/controllers/application_controller.rb:49:in `set_timezone'
  #

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
