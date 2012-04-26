class Cubemania.Views.Flash extends Cubemania.BaseView

  events:
    "click .close": "slideUp"

  initialize: ->
    @message = ""
    @bindTo Cubemania.currentPuzzle, "change", @slideUp, this

  show: (message) ->
    @message = message
    $(@el).show()
    @render()

  hide: ->
    @message = ""
    $(@el).hide()
    @render()

  slideUp: ->
    $(@el).slideUp("fast");

  render: ->
    $(@el).html("<p>#{@message}</p><a class='close'>X</a>")
    this
