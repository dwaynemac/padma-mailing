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
      container: "body"
    $(".selectpicker").addClass "set-background"
    cleanBootstrapDropdowns()

  $("form.sync-contacts input[type=radio]").on "change", ->
    get_contact_scope($("#filter_method_all").is(":checked"))

  $(".mailchimp-section").on "change", "select", ->
    if $("#filter_method_all").is(":checked")
      return
    get_contact_scope($("#filter_method_all").is(":checked"))

  $(".add_nested_fields.mailchimp-segments").on "click", ->
    if $("#filter_method_all").is(":checked")
      return
    $("#scope-count").text("")
    $(".spinner").show()
    setTimeout (->
      get_contact_scope(false)
      return
    ), 500

  $(".remove_nested_fields.mailchimp-segments").on "click", ->
    if $("#filter_method_all").is(":checked")
      return
    $("#scope-count").text("")
    $(".spinner").show()
    setTimeout (->
      get_contact_scope(false)
      return
    ), 500
  
@get_contact_scope = (all) ->
  $("#scope-container").removeClass("alert-success alert-info alert-warning alert-danger")
  $("#scope-count").text("")
  $(".mailchimp-paid-info").hide()
  $(".spinner").show()
  
  a = $('form').last().serializeArray()
  res = {}
  for index, item of a
    iname = item["name"].replace(/\[\]/, "")
    if !res.hasOwnProperty(iname) && item["value"] != undefined && item["value"] != ""
      if /student|coefficient/i.test(iname)
        res[iname] = [item["value"].replace(/exstudent/, "former_student")]
      else
        res[iname] = item["value"]
    else if item["value"] != undefined && item["value"] != ""
      res[iname].push(item["value"].replace(/exstudent/, "former_student"))
    
  $.post "/mailchimp/lists/get_scope.json",
    id: $("form").last().attr("id").replace(/edit_mailchimp_list_/, "")
    filter_method: if all then "all" else "segments"
    data: res
  , (data) ->
    $("#scope-count").text(data)
    if data > 2000
      $("#scope-container").addClass("alert-danger")
      $(".mailchimp-paid-info").show()
    else
      $("#scope-container").addClass("alert-success")
  .success ->
    $(".spinner").hide()
  .fail ->
    $(".spinner").hide()
    $("#scope-count").text("FAILED")
    $("#scope-container").addClass("alert-danger")
