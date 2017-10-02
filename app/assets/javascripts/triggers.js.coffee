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
    #$("#add_more_filter").attr("disabled", false)
    prefillTemplate()
    enableContinue()
    if $(this).val() is "birthday"
      $("#alert-message").show()
    else
      $("#alert-message").hide()
    if $(this).val() is "trial_lesson" or $(this).val() is "membership"
      $(".filter-container").hide()
      return
    $(".filter-container").show()
    $(".add_more_condition").show()
    $(".add-filter").removeClass("no-more-options")
    $(".add-filter").show()
    $("select.select-filter").empty()
    $(".select-filter-container").hide()

    return

  $(".add-filter").click (e) ->
    e.preventDefault()
    already_used = $('.filter_key').map(->
      if $(this).text() != ''
        return $(this).val()
      return
    ).get()
    filter_options = Object.keys($("div#new_filter").data("options")["suggested_values"][$("#trigger_event_name").val()])
    setOptions filter_options, $("select.select-filter"), already_used, true
    $(".select-filter").selectpicker "refresh"
    $(this).hide()
    if already_used.length == Object.keys($("div#new_filter").data("options")["suggested_values"][$("#trigger_event_name").val()]).length - 1
      $(this).addClass("no-more-options")
    $(".select-filter-container").show()

  $(".select-filter").change ->
   $("#add_more_filters").click()
   $("select.select-filter").empty()
   $(".select-filter-container").hide()
   if $(".add-filter").hasClass("no-more-options")
     return
   else
     $(".add-filter").show()

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
    suggested_options = $("div#new_filter").data("options")["suggested_values"][$("#trigger_event_name").val()][$("select.select-filter :selected").val()]
    $($(".filter_key")[$(".filter_key").length - 2 ]).text(I18n.t("set_options.#{$("select.select-filter :selected").val()}"))
    $($(".filter_key")[$(".filter_key").length - 2 ]).val($("select.select-filter :selected").val())

    suggested_options_keys = Object.keys(suggested_options)
    setOptions suggested_options, $("#filters select.value_select:last")
    $("#filters select.value_select:last").selectpicker
      container: ".picker-container"
    $(".add_more_filter").show()

    $('.remove_this_filter').click ->
      $(this).parents('div.fields').remove()
      $("#add_more_filter").attr("disabled", false)
      $(".add-filter").removeClass("no-more-options")
      if !$(".select-filter-container").is(":visible")
        $(".add-filter").show()

    return

  setOptions = (options, select, do_not_use, blank_option) ->
    if blank_option
      $(select).prepend("<option value='' selected='selected'></option>")
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
