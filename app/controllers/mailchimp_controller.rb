class MailchimpController < ApplicationController

  SYSTEM_LISTS = [:students, :p_prospects, :former_students]

  def show
    @mailchimp = current_user.current_account.mailchimp_integration
    if @mailchimp.nil?
      redirect_to new_mailchimp_path
    else
      respond_to do |format|
        format.html do
          @mailchimp_lists = [{"id" => "", "name" => ""}] + @mailchimp.lists
        end
      end
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
    current_user.current_account.mailchimp_integration.update_attributes(params[:mailchimp_integration])
    redirect_to mailchimp_path
  end

  def destroy
    current_user.current_account.mailchimp_integration.destroy
    redirect_to mailchimp_path
  end
    
end
