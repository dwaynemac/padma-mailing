class TemplatesFoldersController < ApplicationController

  load_and_authorize_resource

  def create
    @templates_folder = current_user.current_account.templates_folders.create(params[:templates_folder])
    respond_to do |format|
      format.html do
        redirect_to templates_path(folder_id: @templates_folder.parent_templates_folder_id), notice: "ok!"
      end
    end
  end

  def update
    @templates_folder.update_attributes(params[:templates_folder])
    respond_to do |format|
      format.html do
        redirect_to templates_path(folder_id: @templates_folder.parent_templates_folder_id), notice: "ok!"
      end
      format.json { render json: { templates_folder: @templates_folder.attributes } } 
    end
  end
  
  def destroy
    @templates_folder.destroy
    respond_to do |format|
      format.html do
        redirect_to templates_path(folder_id: @templates_folder.parent_templates_folder_id), notice: "ok!"
      end
    end
  end


end
