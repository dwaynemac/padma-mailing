require "spec_helper"

describe PadmaMailer do
  let(:account){create(:account)}
  before do
    account.stub(:padma).and_return PadmaAccount.new email: 'asd@mail.com'
  end
  it "should be able to send a template mail" do
    @subject = "Hola Alex"
    recipient = "afalkear@gmail.com"
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

    template = Template.new(name: "new_template", subject: @subject, content: "Hola {{persona.nombre_completo}} y {{persona.instructor.nombre}}")
    template.account = account
    template.save!

    data_hash = {
        'persona' => ContactDrop.new(PadmaContact.new(id: "1234", first_name: "Homer", last_name: "Simpson"), PadmaUser.new(email: "alex.falke@metododerose.org", username: "alex.falke"))
    }

    PadmaMailer.template(template, data_hash, recipient,
                         'bcc@mail.com', 'from@mail.com').deliver
    last_email.body.raw_source.should include "Homer Simpson"
    last_email.body.raw_source.should include "Alex Falke"
  end

  context "with acounts-ws and contacts-ws online" do
    before do
      PadmaContact.stub(:find).with(123,anything).and_return(
        PadmaContact.new( first_name: 'dw', last_name: 'mac' )
      )
      PadmaAccount.stub(:find).and_return(
        PadmaAccount.new(email: 'account@mail.com')
      )
    end
    it "replaces {{contact.full_name}} with contact's full name" do
      t = create(:template, name: 'template-name', subject: 'template-subject',
                content: "hello {{contact.full_name}}")

      expect do
        t.deliver(contact_id: 123,
                  user: create(:user, current_account: create(:account))
                 )
      end.to change{ScheduledMail.count}

      PadmaMailer.template(t,
                           ScheduledMail.last.data_hash,
                           'a@b.c',
                           'a@b.c',
                           'a@b.c').deliver
      expect(last_email.body.raw_source).to match 'dw mac'
    end
  end
end
