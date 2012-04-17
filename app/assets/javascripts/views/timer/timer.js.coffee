class Cubemania.Views.Timer extends Backbone.View
  template: JST["timer/timer"]

  events:
    "click a.toggle": "toggleManual"
    "focus textarea": "disableTimer"
    "focus input[type=text]": "disableTimer"
    "blur textarea": "enableTimer"
    "blur input[type=text]": "enableTimer"
    #"submit #new_single": "createSingle" # richtig hier?

  initialize: ->
    @timer = new Cubemania.Timer()
    @scramble = "adsa"
    @timerEnabled = true

  updateDisplay: =>
    @$(".time").html(formatTime(@timer.currentTime()))

  render: ->
    $(@el).html(@template(currentTime: @timer.currentTime(), scramble: @scramble))
    this

  startTimer: (event) =>
    if event.keyCode == 32 and !@timer.isRunning() and @timerEnabled
      if @justStopped
        @justStopped = false
      else
        @$(".time").removeClass("starting")
        @timer.start() # if timeSinceStopped() > 2000
        @intervalId = setInterval(@updateDisplay, 23)
      event.preventDefault()

  stopTimer: (event) =>
    if event.keyCode == 32 and @timerEnabled
      if @timer.isRunning()
        @timer.stop()
        @justStopped = true
        @updateDisplay()
        clearInterval(@intervalId)
        @createSingle(@timer.currentTime())
        intervalId = null
      else
        @$(".time").addClass("starting")
      event.preventDefault()

  toggleManual: (event) ->
    event.preventDefault()
    $("#new_single").toggle()
    $(".time").toggle()
    ct = event.currentTarget
    $(ct).toggleText("Changed your mind?", "Set times manually")
    if $(ct).text() == "Changed your mind?"
      $("#single_human_time").focus()
    else
      $("#single_human_time").blur()

  enableTimer: () ->
    @timerEnabled = true

  disableTimer: () ->
    @timerEnabled = false

  createSingle: (time) ->
    @collection.addSingle({time: time})