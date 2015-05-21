$(document).ready ->
  previous_event_name = undefined
  add_count = 0
  previous_event_name = ""
  $(".selectpicker").selectpicker showSubtext: true
  $(".selectpicker").addClass "set-background"
  $(".event_names .filter-option").text $('.event_names').data('placeholder-text')
  $(".select-template .filter-option").text $('#select-template').data('placeholder-text')
  $(document).on "nested:fieldAdded", (event) ->
    
    # this field was just inserted into your form
    bindFilterInstance()
    $(".key_select").trigger "change"
    $(".key_select").selectpicker "refresh"
    return

  $("#trigger_event_name").focus ->
    previous_event_name = $(this).val()

  $("#trigger_event_name").change ->
    $("#filters").html ""
    $("#templates").html ""
    prefillTemplate()
    enableContinue()
    if $(this).val() is "birthday"
      $("#alert-message").show()
    else
      $("#alert-message").hide()
    if $(this).val() is "trial_lesson" or $(this).val() is "membership"
      $("#add_more_filter").hide()
      return
    $("#add_more_filter").click()
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

  bindFilterInstance = ->
    suggested_options = undefined
    suggested_options = $("div#new_filter").data("options")["suggested_values"][$("#trigger_event_name").val()]
    setOptions Object.keys(suggested_options), $("#filters select.key_select:last")
    $(".key_select").selectpicker "refresh"
    $("#add_more_filter").show().css("display":"inline-block","marginBottom": 15 + "px")
    $("select.key_select").change ->
      select_box = $(this).siblings("select.value_select")
      $(select_box).empty()
      setOptions suggested_options[$(this).val()], select_box
      $(select_box).selectpicker "refresh"
      return

    return

  setOptions = (options, select) ->
    $.each options, (key, value) ->
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