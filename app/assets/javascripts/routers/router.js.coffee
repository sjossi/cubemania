class Cubemania.Routers.Router extends Backbone.Router
  routes:
    "": ""
    "puzzles/:puzzle/timer": "timerIndex"
    "puzzles/:puzzle/records": "recordsIndex"
    "users": "usersIndex"
    "users/:id": "usersShow"

  home: ->

  timerIndex: (puzzle_id) ->

  recordsIndex: (puzzle_id) ->
    records = new Cubemania.Collections.Records(puzzle_id)
    records.fetch()
    view = new Cubemania.Views.RecordsIndex(collection: records)
    $("#backbone-container").html(view.render().el)

  usersIndex: ->
    users = new Cubemania.Collections.Users()
    users.fetch()
    view = new Cubemania.Views.UsersIndex(collection: users)
    $("#backbone-container").html(view.render().el)

  usersShow: (id) ->
    model = new Cubemania.Models.User(id: id)
    model.fetch(async:false)
    view = new Cubemania.Views.UsersShow(model: model)
    $("#backbone-container").html(view.render().el)