$(document).ready ->
  previous_event_name = undefined
  add_count = 0
  previous_event_name = ""
  $(".selectpicker").selectpicker
    liveSearch: true
    showSubtext: true
    container: "body"
  $(".selectpicker").addClass "set-background"
  $(".event_names .filter-option").text $('.event_names').data('placeholder-text')
  $(".select-template .filter-option").text $('#select-template').data('placeholder-text')
  cleanBootstrapDropdowns()
  $("#filters").on "nested:fieldAdded", (event) ->
    # this field was just inserted into your form
    bindFilterInstance()
    $(".add_more_condition").show()
    $(event.field).find('.key_select').trigger 'change'
    $(event.field).find('.key_select').selectpicker 'refresh'
    return

  $(".conditions").on "nested:fieldAdded", (event) ->
    bindConditionInstance()
    $(event.field).find(".condition_key_select").trigger "change"
    $(event.field).find(".condition_key_select").selectpicker "refresh"

  $("#trigger_event_name").focus ->
    previous_event_name = $(this).val()

  $("#trigger_event_name").change ->
    $("#filters").html ""
    $("#templates").html ""
    $("#add_more_filter").attr("disabled", false)
    prefillTemplate()
    enableContinue()
    if $(this).val() is "birthday"
      $("#alert-message").show()
    else
      $("#alert-message").hide()
    if $(this).val() is "trial_lesson" or $(this).val() is "membership"
      $(".add_more_filter").hide()
      return
    $(".add_more_filter").click()

    return

  $("#select-template").change ->
    prefillTemplate()
    refreshOffsetReference()
    enableSubmitTrigger()
    return

  $("#continue-part2").on "click", ->
    if $("#trigger_event_name").val() is ""
      false
    else
      $(".part2").show()
      $(this).hide()
    return

  $(".submit_trigger").on "click", ->
    if $("#select-template").val() is ""
      disableSubmitTrigger()
      false


  prefillTemplate = ->
    template_id = undefined
    $("select.offset_reference").empty()
    template_id = $("#select-template").val()
    $("#template_id").val template_id
    setOptions $("div#new_trigger_template").data("options")["offset_references"][$("#trigger_event_name").val()], $("select.offset_reference")
    refreshOffsetReference()
    return

  bindConditionInstance = ->
    suggested_options = undefined
    suggested_options = $("div#new_condition").data("options")["suggested_values"]
    setOptions Object.keys(suggested_options), $(".conditions select.condition_key_select:last")
    $("select.condition_key_select").change ->
      select_box = $(this).parent().find("select.condition_value_select")
      $(select_box).empty()
      setOptions suggested_options[$(this).val()], select_box
      $(select_box).selectpicker
        container: "body"
      $(select_box).addClass "set-background"
      $(select_box).selectpicker "refresh"
      return
    $(".remove_this_condition").click ->
      $(this).parents("div.fields").remove()
    return


  bindFilterInstance = ->
    suggested_options = undefined
    suggested_options = $("div#new_filter").data("options")["suggested_values"][$("#trigger_event_name").val()]
    already_used = []
    suggested_options_keys = Object.keys(suggested_options)
    if $(".key_select option:selected").length > 0 || suggested_options_keys.length == 1
      already_used = $(".key_select option:selected").map(-> $(this).val()).get() unless suggested_options_keys.length == 1
      # from now on there will be no more options available
      if already_used.length == (suggested_options_keys.length - 1)
        $("#add_more_filter").attr("disabled", true)
      
    setOptions suggested_options_keys, $("#filters select.key_select:last"), already_used
    $(".key_select").selectpicker "refresh"
    $(".add_more_filter").show()
    $("select.key_select").change ->
      select_box = $(this).parent().next().next().find("select.value_select")
      $(select_box).empty()
      setOptions suggested_options[$(this).val()], select_box
      $(select_box).selectpicker
        container: ".picker-container"
      $(select_box).addClass "set-background"
      $(select_box).selectpicker "refresh"
      $(this).prop("disable", true)
      
      return

    $('.remove_this_filter').click ->
      $(this).parents('div.fields').remove()
      $("#add_more_filter").attr("disabled", false)

    return

  setOptions = (options, select, do_not_use) ->
    $.each options, (key, value) ->
      if do_not_use == null || ($.inArray(value, do_not_use) == -1 && do_not_use != value)
        $(select).append $("<option></option>").attr("value", value).text(I18n.t("set_options.#{value}",{defaultValue: value}))
       return
    return

  refreshOffsetReference = ->
    $(".offset_reference").selectpicker "refresh"
    return

  disableContinueButton = ->
    $("#continue-part2").attr "disabled", true
    return

  enableContinue = ->
    $("#continue-part2").attr "disabled", false
    return

  disableSubmitTrigger = ->
    $(".submit_trigger").attr "disabled", true
    return

  enableSubmitTrigger = ->
    $(".submit_trigger").attr "disabled", false
    return

  disableContinueButton()
  disableSubmitTrigger()
  return
