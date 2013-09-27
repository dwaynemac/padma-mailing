require 'mailchimp'

class MailchimpController < ApplicationController
  def show
    m = Mailchimp.new current_user.current_account

    @mailchimp_lists = m.lists

  end
end
