require 'spec_helper'

describe Api::V0::MergesController do

  let(:son_id){ 'contact-1' }
  let(:parent_id){ 'contact-2' }

  describe "#create" do
    before do
      @son = create(:scheduled_mail, contact_id: 'contact-1', data: {contact_id: 'contact-1'}.to_json)
      create(:scheduled_mail, contact_id: 'contact-2')
      create(:scheduled_mail, contact_id: 'contact-3')
    end

    context "with existing son_id" do
      before do
        post :create,
             merge: { son_id: son_id, parent_id: parent_id },
             app_key: ENV['app_key']
      end
      it { should respond_with 201 }
      it "moves son's scheduled mails to parent" do
        expect(ScheduledMail.where(contact_id: son_id).count).to eq 0
        expect(ScheduledMail.where(contact_id: parent_id).count).to eq 2
      end
      it "updates contact_id inside data too" do
        expect(JSON.parse(@son.reload.data)["contact_id"]).to eq parent_id
      end
      it "wont modify other contact's scheduled mails" do
        expect(ScheduledMail.where(contact_id: 'contact-3').count).to eq 1
      end
    end
  end

end
