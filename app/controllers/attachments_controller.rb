class AttachmentsController < ApplicationController
  def index
  end

  def show
  end

  def create
    @template = Template.find(params[:template_id])
    @template.attachments.create(attachment_params)
    redirect_to template_path(@template.id)
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

  def attachment_params
    params.require(:attachment).permit!
  end
end
