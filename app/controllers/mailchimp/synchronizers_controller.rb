class Mailchimp::SynchronizersController < Mailchimp::PetalController

  def sync_now
    @configuration = current_user.current_account.mailchimp_configuration
    Mailchimp::Configuration.

  end
end
