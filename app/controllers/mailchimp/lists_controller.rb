class Mailchimp::ListsController < Mailchimp::PetalController
  rescue_from RestClient::InternalServerError, with: :mailchimp_error

  def segments
    unique_attributes = %w(telephone email identification address date_attribute custom_attribute social_network_id)
    @list = Mailchimp::List.find(params[:id])
    @filter_method = @list.mailchimp_configuration.filter_method.blank? ? "all" : @list.mailchimp_configuration.filter_method
    @contact_attributes = (ContactAttribute::AVAILABLE_TYPES - unique_attributes).map{ |att| [t(att), att]} + 
                              (ContactAttribute.custom_keys(account_name: current_user.current_account.name)).map{|att| [att, att] }
    @default_attributes = [
      I18n.t('attributes.phone'), 
      I18n.t('attributes.gender'), 
      I18n.t('attributes.status'), 
      I18n.t('attributes.address'),
      I18n.t('attributes.coefficient'),
      I18n.t('attributes.followed_by'),
      I18n.t('attributes.teacher'),
      I18n.t('attributes.tags')
    ]
  end

  def update
    @list = Mailchimp::List.find(params[:id])
    params[:mailchimp_list][:contact_attributes] = params[:mailchimp_list][:contact_attributes].reject(&:empty?).join(",")
    params[:mailchimp_list][:mailchimp_segments_attributes] = set_status(params[:mailchimp_list][:mailchimp_segments_attributes])
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

  # there is no status attribute, but student, prospect and exstudent attributes.
  # as there is a select in the form, only one can be used in the select
  # and we set the correct status here
  def set_status(mailchimp_segment_attributes)
    mailchimp_segment_attributes.each do |k, v|
      statuses = v[:student]
      v.delete :student
      statuses.reject(&:blank?).each do |status|
        v[status] = true
      end
      v[:coefficient] = v[:coefficient].reject(&:blank?).join(",")
    end
    mailchimp_segment_attributes
  end

  def get_scope
    count = "no number has been returned"
    list = Mailchimp::List.find(params[:id])
    params[:app_key] = ENV["contacts_key"]
    params[:api_key] = list.mailchimp_configuration.api_key
    params[:mailchimp_segments] = params[:data][:mailchimp_list][:mailchimp_segments_attributes].values
    params.delete :data
    response = Typhoeus.get("#{Contacts::HOST}/v0/mailchimp_synchronizers/get_scope", params: params)
    
    if response.success?
      count = response.body
    end
    
    respond_to do |format|
      format.json { render json: count }
    end
  end

  protected
  
  def mailchimp_error(exception)
    flash.alert = t("mailchimp.errors.rest_client",error_message: exception.response.to_str)
    redirect_to segments_mailchimp_list_path(id: @list.id)
  end
end
