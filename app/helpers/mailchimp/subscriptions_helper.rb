module Mailchimp::SubscriptionsHelper

  def mailchimp_enabled?
    'mailchimp'.in?(current_user.current_account.padma.enabled_petals||[])
  end

end
