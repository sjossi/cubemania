class Cubemania.Scrambler
  scramble: (puzzle) ->
    switch puzzle
      when "2x2x2" then cube [["R", "L"], ["F", "B"], ["U", "D"]], 25
      when "3x3x3" then cube [["R", "L"], ["F", "B"], ["U", "D"]], 25
      when "4x4x4" then cube [["R", "L", "Rw", "Lw"], ["F", "B", "Fw", "Bw"], ["D", "U", "Dw", "Uw"]], 40
      when "5x5x5" then cube [["R", "L", "Rw", "Lw"], ["F", "B", "Fw", "Bw"], ["D", "U", "Dw", "Uw"]], 60
      when "6x6x6" then cube [["R", "L", "2R", "2L", "3R", "3L"], ["F", "B", "2F", "2B", "3F", "3B"], ["D", "U", "2D", "2U", "3D", "3U"]], 80
      when "7x7x7" then cube [["R", "L", "2R", "2L", "3R", "3L"], ["F", "B", "2F", "2B", "3F", "3B"], ["D", "U", "2D", "2U", "3D", "3U"]], 100

  cube = (turns, length) ->
    variants = ['', "'", '2']
    axis = rand turns.length
    ((axis = (axis + rand(turns.length - 1) + 1) % turns.length
    turns[axis].sample() + variants.sample()) for x in [1..length]).join " "

  rand = (n) ->
    Math.floor(Math.random() * n)