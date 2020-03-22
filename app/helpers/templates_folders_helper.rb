module TemplatesFoldersHelper

  def folder_icon
    "<span class='glyphicon glyphicon-folder-open'></span>".html_safe
  end

  def breadcrums(folder=nil)
    folder = @current_folder if folder.nil?
    ret = ""
    if folder
      if folder.parent
        ret << breadcrums(folder.parent) 
        ret << " / "
      end
      ret << rip_name(folder).html_safe
    end
  end

  def link_to_folder(folder)
    link_to folder.name, templates_path(folder_id: folder.id)
  end

  def rip_name(folder)
    content_tag :span,
      class: "rest_in_place",
      data: {
        url: url_for(folder),
        object: "templates_folder",
        attribute: "name"
      } do
      folder.name
    end
  end
end
