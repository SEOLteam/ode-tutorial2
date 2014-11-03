$(() ->
  model = {}

  setUpBody = ->
    $('#tutorial')
    .width '100%'
    .height 800
    .split
        orientation: 'vertical'
        limit: 100
        position: '20%'

    $('#right_pane').split
      orientation: 'horizontal'
      limit: 10

  setUpCalculator = ->
    elt = $('#calculator')
    calculator = Desmos.Calculator(elt)
    calculator.setExpression
      id: 'graph1'
      latex: 'y=sin(x)'

    calculator.setExpression
      id: 'ab'
      latex: '(a,b)'

    calculator.setExpression
      id: 'a'
      latex: 'a=0'

    calculator.setExpression
      id: 'b'
      latex: 'b=sin(a)'

    $('.splitter_panel')# Does not work for changes in vertical.
    .bind 'splitter.resize', () ->
      calculator.resize()

    model.calculator = calculator

  setUpSimulation = ->
    s = Snap('#svg')
    C_RADIUS = 50
    rect = s.rect(400, 50, 5, 80)
    circle = s.circle(400 + 5 / 2.0, 50 + 80 / 2.0, C_RADIUS)
    circle.attr({
      fill: "#bada00",
      stroke: "#000",
      strokeWidth: 2
    });
    pos = 0
    move = (dx) ->
      @attr transform: @data('origTransform') + 't' + [
        dx
        0
      ]
      pos = (@node.getBoundingClientRect().left - 700) / 200
      model.calculator.setExpression
        id: 'a'
        latex: 'a=' + pos

    notDragging = true

    start = ->
      notDragging = false
      @data 'origTransform', @transform().local
      return

    stop = ->
      notDragging = true
      console.log 'finished dragging'
      return

    # TODO rect.drag move, start, stop
    circle.drag move, start, stop

    #spring = Snap.load("/img/simple_spring.svg")
    velocity = 0
    setInterval(() ->
      return null unless notDragging
      K = 0.007
      x = circle.getBBox().x
      dx = rect.getBBox().x - x - C_RADIUS
      a = K * dx
      velocity += a
      velocity = 0 if Math.abs(velocity) < 0.5
      circle.data 'origTransform', circle.transform().local
      circle.attr
        transform: circle.data('origTransform') + ((if circle.data('origTransform') then 'T' else 't')) + [
          velocity,
          0
        ]
      pos = (circle.node.getBoundingClientRect().left - 700) / 200
      model.calculator.setExpression
        id: 'a'
        latex: 'a=' + pos
    , 100)

  setUpBody()
  setUpCalculator()
  setUpSimulation()
)