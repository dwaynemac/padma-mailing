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
  $(".select-template .filter-option").text $('.select-template').data('placeholder-text')
  cleanBootstrapDropdowns()
  $("#filters").on "nested:fieldAdded", (event) ->
    # this field was just inserted into your form
    bindFilterInstance()
    #$(".add_more_condition").show()
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
    prefillTemplate()
    refreshOffsetReference()
    $(".filter-and-condition-container").show()
    if $(this).val() is "birthday"
      $("#alert-message").show()
    else
      $("#alert-message").hide()
    if $(this).val() is "trial_lesson" or $(this).val() is "membership"
      $(".filter-container").hide()
      return
    $(".filter-container").show()
    #$(".add_more_condition").show()
    resetAndShowFilter()

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


  $(".add-condition").click (e) ->
    e.preventDefault()
    already_used = $('.condition_key').map(->
      if $(this).text() != ''
        return $(this).val()
      return
    ).get()
    condition_options = Object.keys($("div#new_condition").data("options")["suggested_values"])
    setOptions condition_options, $("select.select-condition"), already_used, true
    $(".select-condition").selectpicker "refresh"
    $(this).hide()
    if already_used.length == Object.keys($("div#new_condition").data("options")["suggested_values"]).length - 1
      $(this).addClass("no-more-options")
    $(".select-condition-container").show()

  $(".select-condition").change ->
   $("#add_more_conditions").click()
   $("select.select-condition").empty()
   $(".select-condition-container").hide()
   if $(".add-condition").hasClass("no-more-options")
     return
   else
     $(".add-condition").show()


  $(".select-template").change ->
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
    if $(".select-template").val() is ""
      disableSubmitTrigger()
      false


  prefillTemplate = ->
    template_id = undefined
    $("select.offset_reference").empty()
    template_id = $(".select-template").val()
    $("#template_id").val template_id
    setOptions $("div#new_trigger_template").data("options")["offset_references"][$("#trigger_event_name").val()], $("select.offset_reference")
    refreshOffsetReference()
    return

  bindConditionInstance = ->
    suggested_options = undefined
    suggested_options = $("div#new_condition").data("options")["suggested_values"][$("select.select-condition :selected").val()]
    $($(".condition_key")[$(".condition_key").length - 2 ]).text(I18n.t("set_options.#{$("select.select-condition :selected").val()}"))
    $($(".condition_key")[$(".condition_key").length - 2 ]).val($("select.select-condition :selected").val())
    #$(".conditions .condition_key_input:last").val($("select.select-condition :selected").val())

    setOptions [$("select.select-condition :selected").val()], $(".conditions select.condition_key_input:last")
    setOptions suggested_options, $(".conditions select.condition_value_select:last")
    $(".conditions select.condition_value_select:last").selectpicker
      container: ".picker-container"
    $(".add_more_condition").show()
    
    $(".remove_this_condition").click ->
      $(this).parents("div.fields").remove()
      $(".add-condition").removeClass("no-more-options")
      if !$(".select-condition-container").is(":visible")
        $(".add-condition").show()
    return


  bindFilterInstance = ->
    suggested_options = undefined
    suggested_options = $("div#new_filter").data("options")["suggested_values"][$("#trigger_event_name").val()][$("select.select-filter :selected").val()]
    $($(".filter_key")[$(".filter_key").length - 2 ]).text(I18n.t("set_options.#{$("select.select-filter :selected").val()}"))
    $($(".filter_key")[$(".filter_key").length - 2 ]).val($("select.select-filter :selected").val())

    #$("#filters .filter_key_input:last").val($("select.select-filter :selected").val())
    setOptions [$("select.select-filter :selected").val()], $("#filters select.filter_key_input:last")
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

  resetAndShowFilter = ->
    $(".add-filter").removeClass("no-more-options")
    $(".add-filter").show()
    $("select.select-filter").empty()
    $(".select-filter-container").hide()

  refreshOffsetReference = ->
    $(".offset_reference").selectpicker "refresh"
    return

  disableContinueButton = ->
    $("#continue-part2").attr "disabled", true
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
