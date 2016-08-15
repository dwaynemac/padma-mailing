class AttachmentsController < ApplicationController
  def index
  end

  def show
  end

  def destroy
    template = Template.find(params[:template_id])
    @attachment = template.attachments.find(params[:id])
    @attachment.destroy

    respond_to do |format|
       format.js { render layout: false }
       format.html { redirect_to template_url(@attachment.template.id) }
    end
  end
end