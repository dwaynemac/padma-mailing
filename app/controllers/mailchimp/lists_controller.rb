class Mailchimp::ListsController < ApplicationController
  def segments
    @list = Mailchimp::List.find(params[:id])
  end

  def update
    @list = Mailchimp::List.find(params[:id])
    @list.update_attributes(params[:mailchimp_list])
    @list.mailchimp_configuration.update_attribute(:filter_method ,params[:filter_method])
    @list.mailchimp_configuration.update_synchronizer
    
    render text: "OK"
  end
end
