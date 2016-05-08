@cleanBootstrapDropdowns = ->
  $(".selectpicker").on "click", (e) ->
    console.log("picker!")
    $(".btn-group.bootstrap-select.open").removeClass("open")