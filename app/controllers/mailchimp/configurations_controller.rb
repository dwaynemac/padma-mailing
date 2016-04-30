class Mailchimp::ConfigurationsController < Mailchimp::PetalController
  rescue_from RestClient::InternalServerError, with: :mailchimp_error

  before_filter :get_configuration
  before_filter :require_set_up, only: [:show]
  
  def show
    # @configuration setted by get_configuration
  end

  def new
    @configuration = Mailchimp::Configuration.new
  end

  def create
    @configuration = Mailchimp::Configuration.new(
      local_account_id: current_user.current_account.id,
      api_key: params[:mailchimp_configuration][:api_key]
    )
    if @configuration.save
      redirect_to primary_list_mailchimp_configuration_path @configuration
    else
      flash.alert = @configuration.errors.messages.to_a.flatten.join(' ')
      render :new
    end
  end

  def sync_now
    if @configuration.run_synchronizer
      flash.notice = t('mailchimp.configurations.sync_now.success')
    else
      flash.alert = t('mailchimp.configurations.sync_now.failed')
    end
    redirect_to mailchimp_configuration_path
  end

  def primary_list
    @configuration.sync_mailchimp_lists_locally # fetch mailchimp lists
    @lists = @configuration.reload.mailchimp_lists
  end
  
  def update
    @configuration.update_attributes(params[:mailchimp_configuration])
    @configuration.update_synchronizer
    redirect_to mailchimp_configuration_path
  end

  def destroy
    @configuration.destroy
    redirect_to mailchimp_configuration_path
  end

  protected
  
  def mailchimp_error(exception)
    flash.alert = t("mailchimp.errors.rest_client",error_message: exception.response.to_str)
    redirect_to segments_mailchimp_list_path(id: @list.id)
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
    elsif (@configuration.primary_list.mailchimp_segments.empty? && @configuration.filter_method != 'all')
      redirect_to segments_mailchimp_list_path @configuration.primary_list 
    end
  end

  
end
