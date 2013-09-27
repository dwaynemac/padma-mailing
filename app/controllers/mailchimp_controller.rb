class MailchimpController < ApplicationController

  SYSTEM_LISTS = [:students, :p_prospects, :former_students]

  before_filter :require_api_key, except: [:new, :create]

  def show
    @mailchimp_lists = [{"id" => "", "name" => ""}] + @mailchimp.lists
  end

  def check
    @students = @mailchimp.students if @mailchimp.students_list_id
    @p_former_students = @mailchimp.p_former_students if @mailchimp.p_former_students_list_id
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
