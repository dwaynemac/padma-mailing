require 'spec_helper'

describe TemplatesTriggers do
  let(:trigger){ create(:trigger) }
  let(:template){ create(:template) }
  
  before(:each) do
    allow(PadmaAccount).to receive(:find).and_return(
      PadmaAccount.new(
        full_name: 'acc-name', 
        branded_name: 'DeROSE Method | acc-name', 
        email: "acc-mail@mail.co"
      )
    )
  end
  
  it { should belong_to :trigger }
  it { should belong_to :template }
  it { should validate_presence_of :template }

  context "if offset_number is set" do
    let(:trigger){TemplatesTriggers.new(offset_number: 1)}
    it "should require offset_unit" do
      trigger.valid?
      trigger.errors[:offset_unit].should include I18n.t('errors.messages.blank')
    end
  end
  context "if offset_number is NOT set" do
    let(:trigger){TemplatesTriggers.new}
    it "should require offset_unit" do
      trigger.valid?
      expect(trigger.errors[:offset_unit]).to_not include I18n.t('errors.messages.blank')
    end
  end

  describe "#valid_offset_unit?" do

    it "considers 'asdf' invalid" do
      TemplatesTriggers.new(offset_unit: 'asdf').valid_offset_unit?.should be_falsey
    end

    it "considers 'hour' valid" do
      TemplatesTriggers.new(offset_unit: 'hour').valid_offset_unit?.should be_truthy
    end

    it "considers 'hours' valid" do
      TemplatesTriggers.new(offset_unit: 'hours').valid_offset_unit?.should be_truthy
    end

    it "considers 'month' valid" do
      TemplatesTriggers.new(offset_unit: 'month').valid_offset_unit?.should be_truthy
    end

    it "considers 'years' valid" do
      TemplatesTriggers.new(offset_unit: 'years').valid_offset_unit?.should be_truthy
    end
  end

  describe "#valid_offset_number?" do
    it "considers '0' invalid" do
      TemplatesTriggers.new(offset_number: 0).valid_offset_number?.should be_falsey
    end
    it "considers '1' valid" do
      TemplatesTriggers.new(offset_number: 1).valid_offset_number?.should be_truthy
    end
    it "considers '-1' valid" do
      TemplatesTriggers.new(offset_number: -1).valid_offset_number?.should be_truthy
    end
  end
  
  describe "#delivery_time" do
    let(:tt){TemplatesTriggers.new(offset_unit: 'days', offset_number: 1, offset_reference: 'communicated_at')}
    context "with a data with needed data" do
      context "with a valid time" do
        let(:data){{communicated_at: "2013-02-21 18:56:46 -0300"}}
        it "returns Time" do
          tt.delivery_time(data).should be_a(Time)
        end
      end
      context "with an invalid time" do
        let(:data){{communicated_at: "whatever"}}
        it "returns nil" do
          tt.delivery_time(data).should be_nil
        end
      end
    end
    context "with a data without needed data" do
      let(:data){{some: 'thing', else: 'here'}}
      it "returns nil" do
        tt.delivery_time(data).should be_nil
      end
    end
  end
  
  describe "get_from_display_name" do
    describe "if from_display_name is blank" do
      let(:tt){TemplatesTriggers.new(trigger: trigger, template_id: template.id, from_display_name: nil)}
      it "should return account's branded name" do
        expect(tt.get_from_display_name).to eq "DeROSE Method | acc-name"
      end
    end
    describe "if from_display_name is a META var" do
      xit "should fetch META's current_value"
    end
    describe "if from_display_name is simple text" do
      let(:tt){TemplatesTriggers.new(trigger: trigger, from_display_name: "dwayne")}
      it "should return from_display_name" do
        expect(tt.get_from_display_name).to eq "dwayne"
      end
    end
  end
  
  describe "get_from_email_address" do
    describe "if from_email_address is blank" do
      let(:tt){TemplatesTriggers.new(trigger: trigger, template: template, from_email_address: nil)}
      it "should return account's email" do
        expect(tt.get_from_email_address).to eq "acc-mail@mail.co"
      end
    end
    describe "if from_display_name is a META var" do
      xit "should fetch META's current_value"
    end
    describe "if from_email_address is simple text" do
      let(:tt){TemplatesTriggers.new(trigger: trigger, from_email_address: "text@sa.co")}
      it "should return from_email_address" do
        expect(tt.get_from_email_address).to eq "text@sa.co"
      end
    end
  end
end
