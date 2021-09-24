require 'rails_helper'

describe Filter do


  it { should belong_to :trigger }
  it { should validate_presence_of :key }
  it { should validate_presence_of :value }

  context "for birthday trigger" do
    let(:trigger){create(:trigger, event_name: 'birthday')}

    it "wont convert local_status to local_status_for_AccountName" do
      f = create(:filter, trigger: trigger, key: 'local_status', value: 'student')
      expect(f.key).to eq "local_status_for_#{trigger.account.name}"
    end

    it "wont convert local_coefficient to local_coefficient_for_AccountName" do
      f = create(:filter, trigger: trigger, key: 'local_coefficient', value: 'perfil')
      expect(f.key).to eq "local_coefficient_for_#{trigger.account.name}"
    end
  end

  context "for other triggers" do
    let(:trigger){create(:trigger)}

    it "does NOT convert local_status to local_status_for_AccountName" do
      f = create(:filter, trigger: trigger, key: 'local_status', value: 'student')
      expect(f.key).not_to eq "local_status_for_#{trigger.account.name}"
    end

    it "does NOT convert local_coefficient to local_coefficient_for_AccountName" do
      f = create(:filter, trigger: trigger, key: 'local_coefficient', value: 'perfil')
      expect(f.key).not_to eq "local_coefficient_for_#{trigger.account.name}"
    end
  end

end
