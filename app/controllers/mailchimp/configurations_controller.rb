class Mailchimp::ConfigurationsController < ApplicationController
  before_filter :get_configuration
  before_filter :require_set_up, only: [:show]
  
  def show
    render text: "Mailchimp show"
  end

  def new
    @configuration = Mailchimp::Configuration.new
  end

  def create
    debugger
    @configuration = Mailchimp::Configuration.create(
      local_account_id: current_user.current_account.id,
      api_key: params[:mailchimp_configuration][:api_key]
    )
    redirect_to primary_list_mailchimp_configuration_path @configuration
  end

  def primary_list
    @lists = @configuration.mailchimp_lists
  end
  
  def update
    @configuration.update_attributes(params[:mailchimp_configuration])
    redirect_to mailchimp_configuration_path
  end

  def destroy
    @configuration.destroy
    redirect_to mailchimp_configuration_path
  end

  private
  
  def get_configuration
    @configuration = current_user.current_account.mailchimp_configuration
  end

  def require_set_up
    if @configuration.nil?
      redirect_to new_mailchimp_configuration_path
    elsif @configuration.primary_list.nil?
      redirect_to primary_list_mailchimp_configuration_path
    elsif @configuration.primary_list.segments.empty?
      redirect_to segments_lists_path
    end
  end
  
  #def configuration_params
   # params.require(:configuration).permit(:primary_list_id)
  #end
end
