class RefactorOffsetToTriggerTemplateRelationship < ActiveRecord::Migration
  def up
    add_column :templates_triggers, :offset_number, :integer
    add_column :templates_triggers, :offset_reference, :string
    add_column :templates_triggers, :offset_unit, :string

    Trigger.all.each do |trigger|
      trigger.templates_triggerses.each do |tt|
        tt.offset_number = trigger.offset_number
        tt.offset_unit = trigger.offset_unit
        tt.offset_reference = trigger.offset_reference
        tt.save
      end
    end

    remove_columns :triggers, :offset_number, :offset_reference, :offset_unit
  end

  def down
    add_column :triggers, :offset_number, :integer
    add_column :triggers, :offset_reference, :string
    add_column :triggers, :offset_unit, :string

    TemplatesTriggers.all.each do |template_trigger|
      template_trigger.template.offset_number = template_trigger.offset_number
      template_trigger.template.offset_unit = template_trigger.offset_unit
      template_trigger.template.offset_reference = template_trigger.offset_reference
      template_trigger.template.save
    end

    remove_columns :templates_triggers, :offset_number, :offset_reference, :offset_unit
  end
end
