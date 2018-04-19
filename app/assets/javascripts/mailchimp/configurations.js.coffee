# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/
#

# This should go later to lists.js.coffee
#


$(document).ready ->
  $(".receive_notifications").on "click", ->
    $(".notifications").toggle()
    if $(".receive_notifications")[0].checked
      receive_notifications(this, $(".list_id")[0].innerHTML)
    else
      remove_notifications(this, $(".list_id")[0].innerHTML)

  $(".update_events_notifications").on "click", ->
    update_notifications(this, $(".list_id")[0].innerHTML, "events", this.name, this.checked)
  
  $(".update_sources_notifications").on "click", ->
    update_notifications(this, $(".list_id")[0].innerHTML, "sources", this.name, this.checked)

@receive_notifications = (element, list_id) ->
  $.post "/mailchimp/lists/"+list_id+"/receive_notifications.json"
  .done ->
    $.gritter.add {title: ":)", text: "updated", class_name: "success"}
  .fail ->
    $(element).prop("checked", !value)
    $.gritter.add {title: ":(", text: "#{xhr.responseText}" , class_name: "alert"}

@remove_notifications = (element, list_id) ->
  $.post "/mailchimp/lists/"+list_id+"/remove_notifications.json"
  .done ->
    $.gritter.add {title: ":)", text: "updated", class_name: "success"}
  .fail ->
    $(element).prop("checked", !value)
    $.gritter.add {title: ":(", text: "#{xhr.responseText}" , class_name: "alert"}

@update_notifications = (element, list_id, type, key, value) ->
  $.post "/mailchimp/lists/"+list_id+"/update_notifications.json",
    type: type
    key: key
    value: value
  .done ->
    $.gritter.add {title: ":)", text: "updated", class_name: "success"}
  .fail (xhr, status, error) ->
    $(element).prop("checked", !value)
    $.gritter.add {title: ":(", text: "#{xhr.responseText}" , class_name: "alert"}
