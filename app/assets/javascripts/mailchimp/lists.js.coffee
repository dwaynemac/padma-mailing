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

  $("form").last().on "change", ->
    get_contact_scope($("#filter_method_all").is(":checked"))
  
@get_contact_scope = (all) ->
  $("#scope-container").removeClass("alert-success alert-info alert-warning alert-danger")
  $("#scope-count").text("")
  $(".spinner").show()
  $.post "/mailchimp/lists/get_scope.json?"+$('form').last().serialize(),
    id: $("form").last().attr("id").replace(/edit_mailchimp_list_/, "")
    filter_method: all ? "all" : "segments"
    #data: $('form').last().serialize()
  , (data) ->
    $("#scope-count").text(data)
    if data > 2000
      $("#scope-container").addClass("alert-danger")
    else
      $("#scope-container").addClass("alert-success")
  .success ->
    $(".spinner").hide()
  .fail ->
    $(".spinner").hide()
    $("#scope-count").text("FAILED")
    $("#scope-container").addClass("alert-danger")
