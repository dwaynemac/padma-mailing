@cleanBootstrapDropdowns = ->
  $(".selectpicker").on "click", (e) ->
    $(".btn-group.bootstrap-select.open").removeClass("open")