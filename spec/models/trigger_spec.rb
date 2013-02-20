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
  end

end
