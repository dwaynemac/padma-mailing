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
    permitted_mailchimp_list_params = mailchimp_list_params
    permitted_mailchimp_list_params[:contact_attributes] = permitted_mailchimp_list_params[:contact_attributes].reject(&:empty?).join(",")
    permitted_mailchimp_list_params[:mailchimp_segments_attributes] = set_status(permitted_mailchimp_list_params[:mailchimp_segments_attributes])
    if @list.update_attributes(permitted_mailchimp_list_params)
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

  def receive_notifications
    list = Mailchimp::List.find(params[:id])
    list.add_webhook

    respond_to do |format|
      format.json { render json: nil, status: :ok }
      format.html { redirect_to mailchimp_configuration_path }
    end
  end

  def remove_notifications
    list = Mailchimp::List.find(params[:id])
    resp = list.remove_webhook
    
    if !list.receive_notifications
      respond_to do |format|
        format.json { render json: nil, status: :ok }
      end
    else
      respond_to do |format|
        format.json { render json: resp[:errors], status: 400 }
      end
    end
  end

  def update_single_notification
    list = Mailchimp::List.find(params[:id])
    notifications = list.decode(list.webhook_configuration)
    type = params[:key].scan(/(?<=\[).+?(?=\])/).first
    key = params[:key].scan(/(?<=\[).+?(?=\])/).last
    notifications[type][key] = params[:value] == "true"
    
    resp = list.update_notifications(notifications)


    if !resp["id"].nil?
      respond_to do |format|
        format.json { render json: nil, status: :ok }
      end
    else
      respond_to do |format|
        format.json { render json: resp[:errors], status: 400 }
      end
    end

  end

  def update_notifications
    list = Mailchimp::List.find(params[:id])
    permitted_notifications_params = notifications_params
    if params[:notifications][:events].nil?
      list.remove_webhook
      resp = { 
        "id" => nil, 
        errors: "#{I18n.t("mailchimp.list.show.notifications.events.title")}: #{I18n.t("mailchimp.webhook.errors.none_selected")}" 
      }
    elsif params[:notifications][:sources].nil?
      list.remove_webhook
      resp = { 
        "id" => nil, 
        errors: "#{I18n.t("mailchimp.list.show.notifications.sources.title")}: #{I18n.t("mailchimp.webhook.errors.none_selected")}"
      } 
    else
      %w(subscribe unsubscribe cleaned profile upemail campaign).each do |o|
        if params[:notifications][:events][o.to_sym].nil?
          permitted_notifications_params[:events][o.to_sym] = false
        else
          permitted_notifications_params[:events][o.to_sym] = true
        end
      end
      %w(admin user).each do |o|
        if params[:notifications][:sources][o.to_sym].nil?
          permitted_notifications_params[:sources][o.to_sym] = false
        else
          permitted_notifications_params[:sources][o.to_sym] = true
        end
      end
      resp = list.update_notifications(permitted_notifications_params)
    end

    if !resp["id"].nil?
      respond_to do |format|
        format.html { redirect_to mailchimp_configuration_path }
        format.json { render json: nil, status: :ok }
      end
    else
      flash.alert = resp[:errors]
      respond_to do |format|
        format.html { redirect_to mailchimp_configuration_path }
        format.json { render json: resp[:errors], status: 400 }
      end
    end
  end

  def preview_scope
    count = "no number has been returned"
    list = Mailchimp::List.find(params[:id])
    params[:app_key] = ENV["contacts_key"]
    params[:api_key] = list.mailchimp_configuration.api_key
    params[:preview] = true
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

  def status
    @list = Mailchimp::List.find(params[:id])
    @synchro = @list.mailchimp_configuration.get_synchronizer
  end

  def members
    @page = params[:page] || 1
    @per = params[:per] || 25
    @list = Mailchimp::List.find(params[:id])
    @only_unsubscribed = false
    if params[:unsubscribed] == "true"
      @only_unsubscribed = true
    end
  end

  def remove_member
    @list = Mailchimp::List.find(params[:id])
    res = @list.remove_member(params[:email])
    res = {status: false, message: "contact has no email"} if res.nil?

    if res[:status] == false
      flash.alert = res[:message]
    end

    redirect_to members_mailchimp_list_path(id: params[:id])
  end

  def subscribe
    @list = Mailchimp::List.find(params[:id])
    res = @list.subscribe_contact(params[:email])
    res = {status: false, message: "contact has no email"} if res.nil?

    if res[:status] == false
      flash.alert = res[:message]
    end

    redirect_to members_mailchimp_list_path(id: params[:id])
  end

  protected
  
  def mailchimp_error(exception)
    flash.alert = t("mailchimp.errors.rest_client",error_message: exception.response.to_str)
    redirect_to segments_mailchimp_list_path(id: @list.id)
  end

  def mailchimp_list_params
    params.require(:mailchimp_list).permit!
  end

  def notifications_params
    params.require(:notifications).permit!
  end

end
