class Mailchimp::SubscriptionsController < Mailchimp::PetalController

  skip_before_filter :check_petal_enabled

  def new
  end

end
