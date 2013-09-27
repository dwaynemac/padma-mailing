require 'mailchimp'

class MailchimpController < ApplicationController

  SYSTEM_LISTS = [:students, :p_prospects, :former_students]

  def show
    m = Mailchimp.new current_user.current_account
    @mailchimp_lists = m.lists
    @local_list_names = ['']+SYSTEM_LISTS
  end

  def update
    lss = current_user.current_account.list_syncs.destroy_all
    params[:mailchimp_sync][:local_list_for].each_pair do |mailchimp_id,local_name|
      ListSync.create(
        local_account_id: current_user.current_account.id,
        mailchimp_list_id: mailchimp_id,
        local_list_name: local_name
      )
    end
    redirect_to mailchimp_path
  end
    
end
