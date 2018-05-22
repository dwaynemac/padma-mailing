# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/
#

# This should go later to lists.js.coffee
#


$(document).ready ->
  $(".receive_notifications").on "click", ->
    receive_notifications(this, $(".list_id")[0].innerHTML)

  $(".remove_notifications").on "click", ->
    remove_notifications(this, $(".list_id")[0].innerHTML)
  
  $(".update_events_notifications").on "click", ->
    update_single_notification(this, $(".list_id")[0].innerHTML, "events", this.name, this.checked)
  
  $(".update_sources_notifications").on "click", ->
    update_single_notification(this, $(".list_id")[0].innerHTML, "sources", this.name, this.checked)

@receive_notifications = (element, list_id, value) ->
  #$(".spinner").toggle()
  $(".notifications_modal").show()
  $(".notifications_modal").removeClass("invisible")
  $.post "/mailchimp/lists/"+list_id+"/receive_notifications.json"
  #.done ->
  #  $(".notifications").toggle()
  #  $(".notifications").removeClass("invisible")
  #  $.gritter.add {title: ":)", text: "updated", class_name: "success"}
  #.fail (xhr, status, error) ->
  #  $(element).prop("checked", !value)
  #  $.gritter.add {title: ":(", text: "#{xhr.responseText}" , class_name: "alert"}
  #.always ->
  #  $(".spinner").toggle()

@remove_notifications = (element, list_id, value) ->
  $(".spinner").toggle()
  $.post "/mailchimp/lists/"+list_id+"/remove_notifications.json", ->
    $(".notifications").toggle()
  .done ->
    $.gritter.add {title: ":)", text: "updated", class_name: "success"}
    $(".remove_notifications").addClass("hidden")
    $(".receive_notifications").removeClass("hidden")
  .fail (xhr, status, error) ->
    $(".notifications").toggle()
    $.gritter.add {title: ":(", text: "#{xhr.responseText}" , class_name: "alert"}
  .always ->
    $(".spinner").toggle()

@update_single_notification = (element, list_id, type, key, value) ->
  $(".spinner").toggle()
  $.post "/mailchimp/lists/"+list_id+"/update_single_notification.json",
    type: type
    key: key
    value: value
  .done ->
    $.gritter.add {title: ":)", text: "updated", class_name: "success"}
  .fail (xhr, status, error) ->
    $(element).prop("checked", !value)
    $.gritter.add {title: ":(", text: "#{xhr.responseText}" , class_name: "alert"}
  .always ->
    $(".spinner").toggle()
