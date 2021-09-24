require "rails_helper"

describe PadmaMailer do
  let(:account){create(:account)}
  before do
    allow(account).to receive(:padma).and_return PadmaAccount.new email: 'asd@mail.com', timezone: 'Buenos Aires'
  end
  
  describe "#template" do
    before do
      @template = Template.new(name: "new_template", subject: 'subject', content: "this will be the content")
      @template.account = account
      @template.save!
    end
    it "should respect given FROM" do
      PadmaMailer.template(@template, {}, "test@mail.co",'bcc@mail.com','FROM NAME','from@mail.com').deliver
      expect(last_email.from).to include("from@mail.com")
    end
  end
  
  it "should be able to send a template mail" do
    @subject = "Hola Alex"
    recipient = "afalkear@gmail.com"
    template = Template.new(name: "new_template", subject: @subject, content: "this will be the content")
    template.account = account
    template.save!

    PadmaMailer.template(template, {}, recipient,'bcc@mail.com','from@mail.com').deliver
    expect(last_email.to).to include(recipient)
    expect(last_email.subject).to eq(@subject)
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
    expect(last_email.body.raw_source).to include "Homer Simpson"
    expect(last_email.body.raw_source).to include "Alex Falke"
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
        expect(last_email.body.raw_source).to include @trial_at
      end

      it "should send the correct liquid variable: instructor name" do
        expect(last_email.body.raw_source).to include "Alex Falke"
      end

      it "should send the correct liquid variable: time slot" do
        expect(last_email.body.raw_source).to include @trial_at
      end
    end
    
  end

  context "sending a next action mail" do
    context "with new liquid variables" do
      before do
        @subject = "Hola Luis"
        recipient = "luisperichon@gmail.com"
        @action_on = "3018-05-20 18:04:00"

        template = Template.new(
                      name: "new_template", 
                      subject: @subject, 
                      content: "Queriamos recordarte que tu entrevista es el {{next_action.date}} a las {{next_action.time}} y la dara el instructor {{next_action.instructor.name}}")
        template.account = account
        template.save!

        data_hash = {
            'next_action' => NextActionDrop.new(
              @action_on, 
              PadmaUser.new(email: "alex.falke@metododerose.org", username: "alex.falke"),
              PadmaUser.new(email: "luis.perichon@metododerose.org", username: "luis.perichon"),
              account.padma.timezone
            )
        }

        PadmaMailer.template(template, data_hash, recipient,
                             'bcc@mail.com', 'from@mail.com').deliver
      end

      it "should send the correct liquid variable: date" do
        expect(last_email.body.raw_source).to include "20"
        expect(last_email.body.raw_source).to include "05"
      end

      it "should send the correct liquid variable: instructor name" do
        expect(last_email.body.raw_source).to include "Luis Perichon"
      end

      it "should send the correct liquid variable: time" do
        expect(last_email.body.raw_source).to include "15:04"
      end
    end
    
  end
  
  it "should replace snippets flawlessly" do
    content = "Hola, te esperamos el día <div class=\"next_action-snippet\" data-snippet=\"snippet_3\">{{next_action.date}}</div> a las <div class=\"next_action-snippet\" data-snippet=\"snippet_4\">{{next_action.time}}</div> para tener una entrevista con:<div class=\"next_action-snippet\" data-snippet=\"snippet_6\">{{next_action.instructor.name}}</div> Además, voy a probar hacerlo manualmente: date: {{next_action.date}} time: {{next_action.time}} instructor name: {{next_action.instructor.name}} instructor mail: {{next_action.instructor.email}}"
    @subject = "Hola"
    action_on = "3018-05-20 18:04:00"
    recipient = "luisperichon@gmail.com"
    template = Template.new(name: "new_template", subject: @subject, content: content)
    template.account = account
    template.save!
        
    data_hash = {
            'next_action' => NextActionDrop.new(
              action_on, 
              PadmaUser.new(email: "alex.falke@metododerose.org", username: "alex.falke"),
              PadmaUser.new(email: "luis.perichon@metododerose.org", username: "luis.perichon"),
              "UTC"
            )
        }
    
    PadmaMailer.template(template, data_hash, recipient,
                         'bcc@mail.com', 'from@mail.com').deliver
    expect(last_email.body.raw_source).to eq "<!DOCTYPE html>\r\n<html>\r\n    <head>\r\n      <meta content=\"text/html; charset=UTF-8\" http-equiv=\"Content-Type\" />\r\n    </head>\r\n    <body>\r\n      Hola, te esperamos el día 3018-05-20 a las 18:04 para tener una entrevista con:Luis Perichon Además, voy a probar hacerlo manualmente: date: 3018-05-20 time: 18:04 instructor name: Luis Perichon instructor mail: luis.perichon@metododerose.org\r\n    </body>\r\n</html>\r\n"
  end

  context "with acounts-ws and contacts-ws online" do
    before do
      Rails.cache.clear
      allow(PadmaContact).to receive(:find).with(123,anything).and_return(
        PadmaContact.new( first_name: 'dw', last_name: 'mac', email: 'as@co.co' )
      )
      allow(PadmaAccount).to receive(:find).and_return(
        PadmaAccount.new(email: 'account@mail.com', full_name: 'a', locale: "es", timezone: "Buenos Aires")
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
      expected_result = "<!DOCTYPE html>\r\n<html>\r\n    <head>\r\n      <meta content=\"text/html; charset=UTF-8\" http-equiv=\"Content-Type\" />\r\n    </head>\r\n    <body>\r\n      hello dw mac.\r\n    </body>\r\n</html>\r\n"
      expect(last_email.body.raw_source).to eq expected_result
    end
  end
  context "with acounts-ws and contacts-ws online" do
    before do
      allow(PadmaContact).to receive(:find).with(123,anything).and_return(
        PadmaContact.new( first_name: 'dw', last_name: 'mac', gender: 'male' )
      )
      allow(PadmaAccount).to receive(:find).and_return(
        PadmaAccount.new(email: 'account@mail.com', locale: "es", timezone: "Buenos Aires")
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
      expected_result = "<!DOCTYPE html>\r\n<html>\r\n    <head>\r\n      <meta content=\"text/html; charset=UTF-8\" http-equiv=\"Content-Type\" />\r\n    </head>\r\n    <body>\r\n      Hola dw, como andas<br>estas invitado a nuestra escuela.<br>Eso es todoo<br>\r\n    </body>\r\n</html>\r\n"
      expect(last_email.body.raw_source).to eq expected_result
    end
  end
end
