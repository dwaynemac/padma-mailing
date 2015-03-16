module TriggersHelper

  # @param [TemplateTrigger] tt
  def explain_offset(tt)
    if tt.offset_number == 0
      "#{t('templates.templates.offset_connectors.on_the')} #{t("set_options.#{tt.offset_reference}")}"
    else
      connector = (tt.offset_number > 0)? t('templates.templates.offset_connectors.after') : t('templates.templates.offset_connectors.before')
      "#{tt.offset_number.try(:abs)} #{t("templates.templates.units.#{tt.offset_unit}")} #{connector} #{t("set_options.#{tt.offset_reference}")}"
    end
  end
end
