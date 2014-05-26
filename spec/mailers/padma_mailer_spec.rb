require "spec_helper"

describe PadmaMailer do
  it "should be able to send a template mail" do
    @subject = "Hola Alex"
    recipient = "afalkear@gmail.com"
    account = FactoryGirl.create(:account)
    account.stub(:padma).and_return PadmaAccount.new email: 'asd@mail.com'
    template = Template.new(name: "new_template", subject: @subject, content: "this will be the content")
    template.account = account
    template.save!

    PadmaMailer.template(template, {}, recipient,'bcc@mail.com','from@mail.com').deliver
    last_email.to.should include(recipient)
    last_email.subject.should eq(@subject)
  end

  it "should use liquid to replace variables" do
    @subject = "Hola Luis"
    recipient = "luisperichon@gmail.com"
    account = FactoryGirl.create(:account)
    account.stub(:padma).and_return PadmaAccount.new email: 'asd@mail.com'

    template = Template.new(name: "new_template", subject: @subject, content: "Hola {{persona.nombre_completo}}")
    template.account = account
    template.save!

    data_hash = {
        'persona' => ContactDrop.new(PadmaContact.new(id: "1234", first_name: "Homer", last_name: "Simpson"))
    }

    PadmaMailer.template(template, data_hash, recipient,'bcc@mail.com','from@mail.com').deliver
    last_email.body.raw_source.should include "Homer Simpson"
  end
end
