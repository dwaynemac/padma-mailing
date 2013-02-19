# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/

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

$(document).ready ->
  $("#add-filter").click ->
    $("#filters").append($("template#new_filter").html())
    bindTemplateInstance()
    return false