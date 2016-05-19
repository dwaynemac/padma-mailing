class Mailchimp::SubscriptionsController < Mailchimp::PetalController
  rescue_from RestClient::InternalServerError, with: :mailchimp_error

  skip_before_filter :check_petal_enabled, only: [:new, :create]

  before_filter :get_petal, only: [:new]
  before_filter :get_petal_subscription, only: [:show, :destroy]

  def show
    authorize! :read, PetalSubscription
    @monthly_value = "#{@petal_subscription.cents.to_f/100} #{@petal_subscription.currency}"
  end

  def new
    @monthly_value = "#{@petal.cents.to_f/100} #{@petal.currency}"
  end

  def create
    authorize! :create, PetalSubscription
    ps = PetalSubscription.new account_name: current_user.current_account.name,
                               petal_name: 'mailchimp'

    authorize! :create, ps

    created_id =  ps.create( account_name: current_user.current_account.name,
                             username: current_user.username)
    if created_id
      current_user.current_account.padma(false) # refresh cache of account
      redirect_to mailchimp_configuration_path, success: 'yes!'
    else
      redirect_to new_mailchimp_subscription_path, error: 'no!'
    end
  end

  def destroy
    authorize! :destroy, PetalSubscription
    
    if @petal_subscription
      PetalSubscription.delete(@petal_subscription.id, username: current_user.username, account_name: current_user.current_account.name).nil?
      current_user.current_account.padma(false) # refresh cache of account
      current_user.current_account.mailchimp_configuration.try(:destroy) # remove mailchimpconfiguration
    end

    redirect_to mailchimp_subscription_path
  end

  protected

  def mailchimp_error(exception)
    redirect_to mailchimp_configuration_path, error: exception.response.to_str
  end

  def get_petal
    @petal = Rails.cache.read("mailchimp_for_#{current_user.current_account.name}")
    if @petal.nil?
      @petal = Petal.find('mailchimp', account_name: current_user.current_account.name)
      Rails.cache.write("mailchimp_for_#{current_user.current_account.name}", @petal)
    end
    @petal
  end

  def get_petal_subscription
    petals = PetalSubscription.paginate(account_name: current_user.current_account.name)
    @petal_subscription = petals.select{|ps| ps.petal_name == 'mailchimp' }.first
  end

end
