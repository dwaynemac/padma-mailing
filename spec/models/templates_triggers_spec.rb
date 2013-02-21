require 'spec_helper'

describe TemplatesTriggers do
  it { should belong_to :trigger }
  it { should belong_to :template }
  it { should validate_presence_of :template }

  context "if offset_number is set" do
    let(:trigger){TemplatesTriggers.new(offset_number: 1)}
    it "should require offset_unit" do
      trigger.valid?
      trigger.errors[:offset_unit].should include "can't be blank"
    end
  end
  context "if offset_number is NOT set" do
    let(:trigger){TemplatesTriggers.new}
    it "should require offset_unit" do
      trigger.valid?
      trigger.errors[:offset_unit].should_not include "can't be blank"
    end
  end

  describe "#valid_offset_unit?" do

    it "considers 'asdf' invalid" do
      TemplatesTriggers.new(offset_unit: 'asdf').valid_offset_unit?.should be_false
    end

    it "considers 'hour' valid" do
      TemplatesTriggers.new(offset_unit: 'hour').valid_offset_unit?.should be_true
    end

    it "considers 'hours' valid" do
      TemplatesTriggers.new(offset_unit: 'hours').valid_offset_unit?.should be_true
    end

    it "considers 'month' valid" do
      TemplatesTriggers.new(offset_unit: 'month').valid_offset_unit?.should be_true
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
end
