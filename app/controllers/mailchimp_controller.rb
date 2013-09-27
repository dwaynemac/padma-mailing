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
  end

  def new
    @mailchimp = MailchimpIntegration.new
  end

  def create
    @mailchimp = MailchimpIntegration.new
    @mailchimp.local_account_id = current_user.current_account.id
    @mailchimp.api_key = params[:mailchimp_integration][:api_key]
    if @mailchimp.lists.nil?
      redirect_to mailchimp_path, alert: 'error'
    else
      @mailchimp.save
      redirect_to mailchimp_path
    end
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
    @mailchimp = current_user.current_account.mailchimp_integration
    if @mailchimp.nil?
      redirect_to new_mailchimp_path
      return
    end
  end
    
end
