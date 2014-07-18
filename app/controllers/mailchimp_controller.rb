class MailchimpController < ApplicationController

  before_filter :require_api_key, except: [:new, :create]

  def show
    @mailchimp_lists = [{"id" => "", "name" => ""}] + @mailchimp.lists
  end

  def check
    @contacts = case params[:list_sys_name]
      when 'students'
        @mailchimp.students
      when 'p_former_students'
        @mailchimp.p_former_students
      when 'all'
        @mailchimp.all
      else
        nil
    end
    @list_id = case params[:list_sys_name]
      when 'students'
        @mailchimp.students_list_id
      when 'p_former_students'
        @mailchimp.p_former_students_list_id
      when 'all'
        @mailchimp.all_list_id
      else
        nil
    end

    mailchimp_emails = @mailchimp.list_members(@list_id).map{|member| member["email"] }
    contacts_emails  = @contacts.map{|c| c.email}

    @extra_emails = mailchimp_emails - contacts_emails
  end

  def new
    @mailchimp = Mailchimp.new
  end

  def create
    @mailchimp = Mailchimp.new
    @mailchimp.local_account_id = current_user.current_account.id
    @mailchimp.api_key = params[:mailchimp][:api_key]
    @mailchimp.save

    redirect_to mailchimp_path
  end

  def update
    @mailchimp.update_attributes(params[:mailchimp_integration])
    redirect_to mailchimp_path
  end

  def destroy
    @mailchimp.destroy
    redirect_to mailchimp_path
  end

  private

  def require_api_key
    @mailchimp = current_user.current_account.mailchimp
    if @mailchimp.nil?
      redirect_to new_mailchimp_path
      return
    end
  end
    
end
