# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/

jQuery ->

  $("[data-toggle='popover']").popover()

  $('#fileupload').fileupload
    dataType: "script"
    add: (e, data) ->
      file = data.files[0]
      data.context = $(tmpl("template-upload", file))
      $('#fileupload').append(data.context)
      data.submit()
    progressall: (e, data) ->
      progress = parseInt(data.loaded / data.total * 100, 10)
      $('.progress .bar').css 'width', progress + '%'
    error: (e, status, error) ->
      $.gritter.add {title: ":(", text:(e.responseText), class_name: "alert"}