class TemplatesFoldersController < ApplicationController
  load_and_authorize_resource only: [:destroy]
  authorize_resource only: [:create, :update]

  def create
    @templates_folder = current_user.current_account.templates_folders.create(templates_folders_params)
    respond_to do |format|
      format.html do
        if @templates_folder.persisted?
          redirect_to templates_path(folder_id: @templates_folder.parent_templates_folder_id), notice: "ok!"
        else
          redirect_to templates_path(folder_id: @templates_folder.parent_templates_folder_id), alert: "error"
        end
      end
    end
  end

  def update
    @templates_folder.update_attributes(templates_folders_params)
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

  private

  def templates_folders_params
    params.require(:templates_folder).permit(
      :parent_templates_folder_id,
      :name
    )
  end
end
