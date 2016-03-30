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
