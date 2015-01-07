class Mailchimp::ListsController < ApplicationController
  def segments
    @list = Mailchimp::List.find(params[:id])
  end

  def update
    @list = Mailchimp::List.find(params[:id])
    if @list.update_attributes(params[:mailchimp_list])
      @list.mailchimp_configuration
           .update_attribute(:filter_method ,params[:filter_method]) # no validation here.
      @list.mailchimp_configuration.update_synchronizer

      redirect_to @list.mailchimp_configuration
    else
      flash.alert = t('mailchimp.list.update.couldnt_update_segments')
      render 'segments'
    end
  end
end
