require "spec_helper"

describe PadmaMailer do
  let(:account){create(:account)}
  before do
    account.stub(:padma).and_return PadmaAccount.new email: 'asd@mail.com', timezone: 'Buenos Aires'
  end
  
  describe "#template" do
    before do
      @template = Template.new(name: "new_template", subject: 'subject', content: "this will be the content")
      @template.account = account
      @template.save!
    end
    it "should respect given FROM" do
      PadmaMailer.template(@template, {}, "test@mail.co",'bcc@mail.com','FROM NAME','from@mail.com').deliver
      last_email.from.should include("from@mail.com")
    end
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

  context "sending a trial_lesson mail" do
    context "with new liquid variables" do
      before do
        @subject = "Hola Luis"
        recipient = "luisperichon@gmail.com"
        @trial_at = Date.today.to_s

        template = Template.new(
                      name: "new_template", 
                      subject: @subject, 
                      content: "Queriamos recordarte que tu clase es el {{trial_lesson.date}} a las {{trial_lesson.time_slot.time}} y la dara el instructor {{trial_lesson.instructor.name}}")
        template.account = account
        template.save!

        data_hash = {
            'trial_lesson' => TrialLessonDrop.new(@trial_at, PadmaUser.new(email: "alex.falke@metododerose.org", username: "alex.falke"))
        }

        PadmaMailer.template(template, data_hash, recipient,
                             'bcc@mail.com', 'from@mail.com').deliver
      end

      it "should send the correct liquid variable: date" do
        last_email.body.raw_source.should include @trial_at
      end

      it "should send the correct liquid variable: instructor name" do
        last_email.body.raw_source.should include "Alex Falke"
      end

      it "should send the correct liquid variable: time slot" do
        last_email.body.raw_source.should include @trial_at
      end
    end
    
  end

  context "sending a interview_booking mail" do
    context "with new liquid variables" do
      before do
        @subject = "Hola Luis"
        recipient = "luisperichon@gmail.com"
        @interview_on = "3018-05-20 18:04:00"

        template = Template.new(
                      name: "new_template", 
                      subject: @subject, 
                      content: "Queriamos recordarte que tu entrevista es el {{interview_booking.date}} a las {{interview_booking.time}} y la dara el instructor {{interview_booking.instructor.name}}")
        template.account = account
        template.save!

        data_hash = {
            'interview_booking' => InterviewBookingDrop.new(
              @interview_on, 
              PadmaUser.new(email: "alex.falke@metododerose.org", username: "alex.falke"),
              PadmaUser.new(email: "luis.perichon@metododerose.org", username: "luis.perichon"),
              account.padma.timezone
            )
        }

        PadmaMailer.template(template, data_hash, recipient,
                             'bcc@mail.com', 'from@mail.com').deliver
      end

      it "should send the correct liquid variable: date" do
        last_email.body.raw_source.should include "20"
        last_email.body.raw_source.should include "05"
      end

      it "should send the correct liquid variable: instructor name" do
        last_email.body.raw_source.should include "Luis Perichon"
      end

      it "should send the correct liquid variable: time" do
        last_email.body.raw_source.should include "15:04"
      end
    end
    
  end
  
  context "with acounts-ws and contacts-ws online" do
    before do
      Rails.cache.clear
      PadmaContact.stub(:find).with(123,anything).and_return(
        PadmaContact.new( first_name: 'dw', last_name: 'mac', email: 'as@co.co' )
      )
      PadmaAccount.stub(:find).and_return(
        PadmaAccount.new(email: 'account@mail.com', full_name: 'a')
      )
    end
    it "replaces <div class=\"contact-snippet\" data-snippet=\"snippet_0\">{{contact.full_name}}</div> with contact's full name" do
      t = create(:template, name: 'template-name', subject: 'template-subject',
                content: "hello <div class=\"contact-snippet\" data-snippet=\"snippet_0\">{{contact.full_name}}</div><div class=\"contact-snippet\" data-snippet=\"snippet_0\">.</div>")

      expect do
        t.deliver(contact_id: 123,
                  to: 'mail@co.co',
                  user: create(:user, current_account: create(:account))
                 )
      end.to change{ScheduledMail.count}

      PadmaMailer.template(t,
                           ScheduledMail.last.data_hash,
                           'a@b.c',
                           'a@b.c',
                           'a@b.c').deliver
      expected_result = <<HTML_CODE
<!DOCTYPE html>
<html>
    <head>
      <meta content="text/html; charset=UTF-8" http-equiv="Content-Type" />
    </head>
    <body>
      hello dw mac.
    </body>
</html>
HTML_CODE
      expect(last_email.body.raw_source).to eq expected_result
    end
  end
  context "with acounts-ws and contacts-ws online" do
    before do
      PadmaContact.stub(:find).with(123,anything).and_return(
        PadmaContact.new( first_name: 'dw', last_name: 'mac', gender: 'male' )
      )
      PadmaAccount.stub(:find).and_return(
        PadmaAccount.new(email: 'account@mail.com')
      )
    end
    
    it "Hola <div data-snippet=\"snippet_0\" class=\"contact-snippet\">{{contact.first_name}}</div>, como andas<br>estas invitad<div data-snippet=\"snippet_1\" class=\"contact-snippet\">{{contact.a_u_o}}</div> a nuestra escuela.<br>Eso es todoo<br>" do
      t = create(:template, name: 'template-name', subject: 'template-subject',
                content: "Hola <div data-snippet=\"snippet_0\" class=\"contact-snippet\">{{contact.first_name}}</div>, como andas<br>estas invitad<div data-snippet=\"snippet_1\" class=\"contact-snippet\">{{contact.a_u_o}}</div> a nuestra escuela.<br>Eso es todoo<br>")

      expect do
        t.deliver(contact_id: 123,
                  to: 'mail@co.co',
                  user: create(:user, current_account: create(:account))
                 )
      end.to change{ScheduledMail.count}

      PadmaMailer.template(t,
                           ScheduledMail.last.data_hash,
                           'a@b.c',
                           'a@b.c',
                           'blah',
                           'a@b.c').deliver
      expected_result = <<HTML_CODE
<!DOCTYPE html>
<html>
    <head>
      <meta content="text/html; charset=UTF-8" http-equiv="Content-Type" />
    </head>
    <body>
      Hola dw, como andas<br>estas invitado a nuestra escuela.<br>Eso es todoo<br>
    </body>
</html>
HTML_CODE
      expect(last_email.body.raw_source).to eq expected_result
    end
  end
end
