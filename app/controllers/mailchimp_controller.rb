class MailchimpController < ApplicationController
  include ActiveModel::ForbiddenAttributesProtection

  before_filter :get_mailchimp
  before_filter :require_set_up, only: [:show]

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

    @mailchimp.api.lists.list['data'].each do |list_hash|
      List.create(
        api_id: list_hash['id'],
        name: list_hash['name'],
        mailchimp_id: @mailchimp.id
      )
    end
    
    redirect_to primary_list_mailchimp_path @mailchimp
  end

  def primary_list
    @lists = @mailchimp.lists
  end
  
  def update
    @mailchimp.update_attributes(mailchimp_params)
    redirect_to mailchimp_path
  end

  def destroy
    @mailchimp.destroy
    redirect_to mailchimp_path
  end

  private
  
  def get_mailchimp
    @mailchimp = current_user.current_account.mailchimp
  end

  def require_set_up
    if @mailchimp.nil?
      redirect_to new_mailchimp_path
    elsif @mailchimp.primary_list.nil?
      redirect_to primary_list_mailchimp_path
    end
  end
  
  def mailchimp_params
    params.require(:mailchimp).permit(:primary_list_id)
  end  
end
