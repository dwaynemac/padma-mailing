# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/

$(document).ready ->

  $("#trigger_event_name").trigger('change')

  previous_event_name = ''
  $("#trigger_event_name").focus ->
    previous_event_name = $(this).val()
  $("#trigger_event_name").change ->
    if !$('#filters:empty').length or !$('#templates:empty').length
      if confirm("filters and templates will be reseted.")
        $("#filters").html('')
        $("#templates").html('')
      else
        $(this).val(previous_event_name)

  $("#add-filter").click ->
    bindTemplateInstance()

  $("#add-template").click ->
    if $("#select-template").val() == ''
      return false
    prefillTemplate()
    $("#select-template option:selected").hide()
    $("#select-template").prop('value','')
    $("#templates").append($("template#new_trigger_template").html())
    $(".remove-template").click -> removeThisTemplate(this)
    return false

# Transforms array to <option>..</option>
# @param [Array] array_options. Each element can be a string or an Array [value,label]
# @return [String] html options
toSelectOptions = (array_options) ->
  select_options = ""
  for i in array_options
    if typeof i == 'string'
      select_options = select_options+"<option>"+i+"</option>"
    else
      select_options = select_options+"<option value='"+i[0]+"'>"+i[1]+"</option>"
  return select_options

removeThisTemplate = (e) ->
  div = $(e).parents('div.control-group:first')
  id = div.prop('id')
  div.remove()
  $("#select-template option[value="+id+"]").show()

removeThisFilter = (e) ->
  $(e).parents('div.control-group:first').remove()

setOptions = (options,select) ->
  select.html(toSelectOptions(options))

bindTemplateInstance = () ->
  suggested_options = $("template#new_filter").data('options')['suggested_values'][$('#trigger_event_name').val()]
  setOptions(Object.keys(suggested_options),$("template#new_filter .key_select"))

  $("#filters").append($("template#new_filter").html())

  $('.remove-filter').click ->
    removeThisFilter(this)
  $(".key_select").change ->
    setOptions(suggested_options[$(this).val()],$(this).siblings('select.value_select'))
  $(".key_select").trigger('change')

prefillTemplate = () ->
  template_id = $("#select-template").val()
  el = $("template#new_trigger_template")
  el.find('div.control-group').prop('id', template_id)
  el.find('input[type=hidden] ').val(template_id)
  setOptions($("template#new_trigger_template").data('options')['offset_references'][$('#trigger_event_name').val()],el.find('#trigger_templates_triggerses_attributes__offset_reference'))
  el.find('label span').text($("#select-template option:selected").text())