class Mailchimp::ListsController < Mailchimp::PetalController

  def segments
    unique_attributes = %w(telephone email identification address date_attribute custom_attribute social_network_id)
    @list = Mailchimp::List.find(params[:id])
    @contact_attributes = (ContactAttribute::AVAILABLE_TYPES - unique_attributes).map{ |att| [t(att), att]} + 
                              (ContactAttribute.custom_keys(account_name: current_user.current_account.name)).map{|att| [att, att] }
    @default_attributes = [
      I18n.t('attributes.phone'), 
      I18n.t('attributes.gender'), 
      I18n.t('attributes.status'), 
      I18n.t('attributes.address'),
      I18n.t('attributes.coefficient'),
      I18n.t('attributes.followed_by')
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
end
