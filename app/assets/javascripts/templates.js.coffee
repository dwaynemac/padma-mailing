# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/

jQuery ->

  $("[data-toggle='popover']").popover()

  toolbarOptions = [
    ['bold', 'italic', 'underline', 'strike'],
    ['blockquote', 'code-block'],
    [{ 'header': 1 }, { 'header': 2 }],
    [{ 'list': 'ordered'}, { 'list': 'bullet' }],
    [{ 'script': 'sub'}, { 'script': 'super' }],
    [{ 'indent': '-1'}, { 'indent': '+1' }],
    [{ 'direction': 'rtl' }],
    [{ 'size': ['small', false, 'large', 'huge'] }],
    [{ 'header': [1, 2, 3, 4, 5, 6, false] }],
    [{ 'color': [] }, { 'background': [] }],
    [{ 'font': [] }],
    [{ 'align': [] }],
    ['image'],
    ['clean']
  ]

  imageHandler = ->
    range = quill.getSelection()
    value = prompt('please copy paste the image url here.')
    if value
      quill.insertEmbed range.index, 'image', value, Quill.sources.USER
    return
 
  options =
    modules: {
      toolbar: {
        container: toolbarOptions
        handlers: {
          image: imageHandler
        }
      }
    }
    placeholder: 'Write here ...'
    theme: 'snow'
  quill = new Quill('#quill-editor-container', options)

  form = $('.edit_template')[0]
  form.onsubmit = ->
    # populate hidden input
    about = $('#wysiwyg')[0]
    about.value = quill.root.innerHTML

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
      $.gritter.add {title: ":(", text: (e.responseText), class_name: "alert"}
      $(".upload-file-name").empty()
      $(".bar").width( 0 )
