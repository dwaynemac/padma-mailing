class Mailchimp::SubscriptionsController < Mailchimp::PetalController

  skip_before_filter :check_petal_enabled, only: [:new, :create]

  def show
    render text: 'you are subscribed'
  end

  def new
    @monthly_value = '9 usd' # get value through api
  end

  def create
    ps = ::PetalSubscription.new account_name: current_user.current_account.name,
                                 petal_name: 'mailchimp'

    authorize! :create, ps

    result =  ps.create( account_name: current_user.current_account.name,
                         username: current_user.username)
    if result
      current_user.current_account.padma(false) # refresh cache of account
      redirect_to mailchimp_configuration_path, success: 'yes!'
    else
      redirect_to new_mailchimp_subscription_path, error: 'no!'
    end
  end

  def destroy
    # get PetalSubscription of this account_name and this petal_name
  end

end
