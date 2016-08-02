# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/

$(document).ready ->
  $('[data-toggle="tooltip"]').tooltip()

  $(".table-striped").on 'nested:fieldAdded', (e) ->
    $(e.field[0].childNodes[1].childNodes[0]).val($("#new_segment_name").val())
    $("#new_segment_name").val(" ")
    $(".selectpicker").selectpicker 
      showSubtext: true
      container: "form"
    $(".selectpicker").addClass "set-background"
    cleanBootstrapDropdowns()

  $("#filter_method_all").on "change", ->
    get_contact_scope("all")
  $("#filter_method_segments").on "change", ->
    get_contact_scope("segments")

@get_contact_scope = (filter_method) ->
  $(".spinner").show()
  $.post "/mailchimp/lists/get_scope.json?"+$('form').last().serialize(),
    id: $("form").last().attr("id").replace(/edit_mailchimp_list_/, "")
    filter_method: filter_method
    #data: $('form').last().serialize()
  , (data) ->
    $("#scope-count").text(data)
  .success ->
    $(".spinner").hide()
  .fail ->
    $(".spinner").hide()
    $("#scope-count").text("FAILED")
