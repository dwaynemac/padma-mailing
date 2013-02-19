# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/

$(document).ready ->
  $("#add-filter").click ->
    $("#filters").append($("template#new_filter").html())
    bindTemplateInstance()
    return false

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
  $('.remove-filter').click ->
    removeThisFilter(this)
  suggested_options = $("template#new_filter").data('options')
  $(".key_select").change ->
    setOptions(suggested_options[$(this).val()],$(this).siblings('select.value_select'))
  $(".key_select").trigger('change')

prefillTemplate = () ->
  template_id = $("#select-template").val()
  el = $("template#new_trigger_template")
  el.find('div.control-group').prop('id', template_id)
  el.find('input[type=hidden] ').val(template_id)
  el.find('label span').text($("#select-template option:selected").text())