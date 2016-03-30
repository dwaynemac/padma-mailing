class Mailchimp::ListsController < Mailchimp::PetalController

  def segments
    @list = Mailchimp::List.find(params[:id])
  end

  def update
    @list = Mailchimp::List.find(params[:id])
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
