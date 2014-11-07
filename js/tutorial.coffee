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

  calculator = null
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
      id: 'k'
      latex: 'k=1'

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

  snapsvg = Snap('#svg')
  CIRCLE_EQUILIBRIUM = 400
  setUpSimulation = ->
    C_RADIUS = 50
    rect = snapsvg.rect(40, 30, 5, C_RADIUS * 2 + 20)
    spring = null
    Snap.load("/img/simple_spring.svg", (frag) =>
      spring = frag.select("g")
      snapsvg.append( spring )
      snapsvg.group(circle, spring)
    )
    circle = snapsvg.circle(CIRCLE_EQUILIBRIUM + C_RADIUS, 50 + 80 / 2.0, C_RADIUS)
#    slider2 = snapsvg.slider(
#      sliderId: "k_slider"
#      capSelector: "#cap"
#      filename: "img/slider2.svg"
#      x: "40"
#      y: "200"
#      min: "0"
#      max: "400"
##      onDragEndFunc: myDragEndFunc
##      onDragStartFunc: myDragStartFunc
##      onDragFunc: myDragFunc
#    )
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

    velocity = 0

    start = ->
      velocity = 0
      notDragging = false
      @data 'origTransform', @transform().local
      return

    stop = ->
      notDragging = true
      console.log 'finished dragging'
      return

    # TODO rect.drag move, start, stop
    circle.drag move, start, stop

    setInterval(() ->
      return null unless notDragging
      K = parseFloat(calculator.getState().expressions.list[2].latex.substr(2)) / 1000
      dx = CIRCLE_EQUILIBRIUM - circle.getBBox().x
      a = if Math.abs(dx) > 3.0 then K * dx else 0.0
      velocity += a
      circle.attr
        transform: circle.transform().local + 't' + [
          velocity,
          0
        ]
#      spring.node.attr
#        transform: spring.node.transform().local + 's' + (circle.getBBox().x / 2.0)
      pos = (circle.node.getBoundingClientRect().left - 700) / 200
      model.calculator.setExpression
        id: 'a'
        latex: 'a=' + pos
    , 20)

  setUpBody()
  setUpCalculator()
  setUpSimulation()
)