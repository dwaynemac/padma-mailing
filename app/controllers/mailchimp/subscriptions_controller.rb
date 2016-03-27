class Mailchimp::SubscriptionsController < Mailchimp::PetalController

  skip_before_filter :check_petal_enabled, only: [:new, :create]

  def show
    authorize! :read, PetalSubscription
    @monthly_value = '--- valor a confirmar ---' # get value through api
  end

  def new
    @monthly_value = '--- valor a confirmar ---' # get value through api
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
    
    petals = PetalSubscription.paginate(account_name: current_user.current_account.name)

    if petals
      mailchimp_subscription = petals.select{|ps| ps.petal_name == 'mailchimp' }.first
      PetalSubscription.delete(mailchimp_subscription.id, username: current_user.username, account_name: current_user.current_account.name).nil?
      current_user.current_account.padma(false) # refresh cache of account
      current_user.current_account.mailchimp_configuration.try(:destroy)
    end

    redirect_to mailchimp_subscription_path
  end

end
