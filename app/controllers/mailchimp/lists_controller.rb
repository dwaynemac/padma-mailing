class Mailchimp::ListsController < ApplicationController
  def segments
    @list = Mailchimp::List.find(params[:id])
  end
  def update
    debugger
    @list = Mailchimp::List.find(params[:id])
    @list.update_attributes(params[:mailchimp_list])
    render text: "OK"
  end
end
