# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/

$(document).ready ->
  $('[data-toggle="tooltip"]').tooltip()

@addSegment = ->
  new_fields = $('#templateForm .mailchimp_segment_fields:first').clone()
  $('.mailchimp_segment_fields:last').after(new_fields)

@removeSegment = (e) ->
  $($(e).parents('.mailchimp_segment_fields')[0]).remove()
