require "spec_helper"

describe PadmaMailer do
  it "should be able to send a template mail" do
    @subject = "Hola Alex"
    recipient = "afalkear@gmail.com"
    account = FactoryGirl.create(:account)
    template = Template.new(name: "new_template", subject: @subject, content: "this will be the content")
    template.account = account
    template.save!

    PadmaMailer.mail_template(template, recipient).deliver
    last_email.to.should include(recipient)
    last_email.subject.should eq(@subject)
  end
end
