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
      $.gritter.add {title: ":(", text: (e.responseText), class_name: "alert"}
      $(".upload-file-name").empty()
      $(".bar").width( 0 )
  
  if typeof Quill == 'function'
    toolbarOptions = [
      ['bold', 'italic'],
      ['blockquote'],
      [{ 'list': 'ordered'}, { 'list': 'bullet' }],
      [{ 'indent': '-1'}, { 'indent': '+1' }],
      [{ 'header': [1, 2, 3, 4, 5, 6, false] }],
      [{ 'color': [] }, { 'background': [] }],
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
   
    # Populate Custom dropdowns
    get_drop_down_items = (identifier) ->
      select = $(identifier)[0]
      i = 0
      res = {}
      while i < select.options.length
        res[select.options[i].innerHTML] = select.options[i].value
        i++
      res

    # Create DropDowns in quill
    # Contacts
    contactDropDown = new QuillToolbarDropDown(
      label: 'Contact'
      rememberSelection: false
    )
    # Next Actions
    nextactionDropDown = new QuillToolbarDropDown(
      label: 'Follow Up'
      rememberSelection: false
    )
    # Instructors
    instructorDropDown = new QuillToolbarDropDown(
      label: 'Instructor'
      rememberSelection: false
    )
    # Trial Lessons
    triallessonDropDown = new QuillToolbarDropDown(
      label: 'Trial lesson'
      rememberSelection: false
    )

    # Set items on created DropDowns
    # Contacts
    contactDropDown.setItems(get_drop_down_items('#contact-select'))
    # Next Actions
    nextactionDropDown.setItems(get_drop_down_items('#next-action-select'))
    # Instructors
    instructorDropDown.setItems(get_drop_down_items('#instructor-select'))
    # Trial lessons
    triallessonDropDown.setItems(get_drop_down_items('#trial-lesson-select'))

    return_selected_value = (label, value, quill) ->
      {index, range} = quill.selection.savedRange
      quill.deleteText(index, length)
      quill.insertText(index, value)
      quill.setSelection(index + value.length)

    # Set actions on dropdown select
    # Contacts
    contactDropDown.onSelect = (label, value, quill) ->
      return_selected_value(label, value, quill)
    # Next Actions
    nextactionDropDown.onSelect = (label, value, quill) ->
      return_selected_value(label, value, quill)
    # Instructors
    instructorDropDown.onSelect = (label, value, quill) ->
      return_selected_value(label, value, quill)
    # Trial lessons
    triallessonDropDown.onSelect = (label, value, quill) ->
      return_selected_value(label, value, quill)

    quill_options =
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
    quill = new Quill('#quill-editor-container', quill_options)

    # Attach custom drop downs to quill
    # Contacts
    contactDropDown.attach(quill)
    # Next Actions
    nextactionDropDown.attach(quill)
    # Instructors
    instructorDropDown.attach(quill)
    # Trial lessons
    triallessonDropDown.attach(quill)

    form = $('.edit_template, .new_template')[0]
    form.onsubmit = ->
      # populate hidden input
      about = $('#wysiwyg')[0]
      about.value = quill.root.innerHTML
