$(() ->
  model = {} # TODO use

  MAX_T = 4.0

  setUpBody = ->
    t = $('#tutorial')
    .width '100%'
    .height 800
    if window.location.hash == '#/simulation'
      $('#svg')
      .width '100%'
      .height 800
      setUpSimulation()
    else if window.location.hash == '#/calculator'
      $('#calculator')
      .width '100%'
      .height 800
      setUpCalculator()
    else
      t.split
        orientation: 'horizontal'
        limit: 100
        position: '50%'
      setUpCalculator()
      setUpSimulation()

  calculator = null
  setUpCalculator = ->
    elt = $('#calculator')
    calculator = Desmos.Calculator(elt)
    calculator.setState(
      graph:
        showGrid: true
        polarMode: false
        showXAxis: true
        showYAxis: true
        xAxisStep: 0
        yAxisStep: 0
        degreeMode: false
        xAxisArrows: "none"
        yAxisArrows: "none"
        xAxisLabel: ""
        yAxisLabel: ""
        xAxisNumbers: true
        yAxisNumbers: true
        polarNumbers: true
        projectorMode: false
        squareAxes: true
        viewport:
          xmin: 0.0
          ymin: -5.0
          xmax: MAX_T
          ymax: 5.0

      expressions:
        list: [
          {
            id: "graph1"
            latex: "p=A\\cdot\\cos\\left(t\\cdot\\sqrt{\\frac{k}{m}}\\right)"
            domain:
              min: 0
              max: 1

            hidden: false
            color: "#4F81BD"
            style: "normal"
            residualVariable: ""
            regressionParameters: {}
          }
          {
            id: "A"
            latex: "A=1"
            domain:
              min: 0
              max: 1

            hidden: false
            color: "#000000"
            style: "normal"
            residualVariable: ""
            regressionParameters: {}
            sliderMin: -10
            sliderMax: 10
            sliderHardMin: false
            sliderHardMax: false
            sliderAnimationPeriod: 8000
            sliderPlayDirection: 1
            sliderIsPlaying: false
          }
          {
            id: "m"
            latex: "m=1"
            domain:
              min: 0
              max: 1

            hidden: false
            color: "#9BBB59"
            style: "normal"
            residualVariable: ""
            regressionParameters: {}
            sliderMin: -10
            sliderMax: 10
            sliderHardMin: false
            sliderHardMax: false
            sliderAnimationPeriod: 8000
            sliderPlayDirection: 1
            sliderIsPlaying: false
          }
          {
            id: "k"
            latex: "k=10"
            domain:
              min: 0
              max: 1

            hidden: false
            color: "#8064A2"
            style: "normal"
            residualVariable: ""
            regressionParameters: {}
            sliderMin: -10
            sliderMax: 10
            sliderHardMin: false
            sliderHardMax: false
            sliderAnimationPeriod: 8000
            sliderPlayDirection: 1
            sliderIsPlaying: false
          }
          {
            id: "2"
            latex: "p_c=A\\cdot\\cos\\left(t_c\\cdot\\sqrt{\\frac{k}{m}}\\right)"
            domain:
              min: 0
              max: 1

            hidden: false
            color: "#4F81BD"
            style: "normal"
            residualVariable: ""
            regressionParameters: {}
          }
          {
            id: "t_c"
            latex: "t_c=0"
            domain:
              min: 0
              max: 1

            hidden: false
            color: "#9BBB59"
            style: "normal"
            residualVariable: ""
            regressionParameters: {}
          }
          {
            id: "4"
            latex: "\\left(t_c,p_c\\right)"
            domain:
              min: 0
              max: 1

            hidden: false
            color: "#8064A2"
            style: "point"
            residualVariable: ""
            regressionParameters: {}
          }
        ]
    )

    $('.splitter_panel')# Does not work for changes in vertical.
    .bind 'splitter.resize', () ->
      calculator.resize()

    model.calculator = calculator

  snapsvg = Snap('#svg')
  CIRCLE_EQUILIBRIUM = 300
  C_RADIUS = 50
  Y_OFFSET = 20
  setUpSimulation = ->
    snapsvg.rect(40, 30, 5, C_RADIUS * 2 + 20)
    #    spring = null
    #    Snap.load("/img/simple_spring.svg", (frag) =>
    #      spring = frag.select("g")
    #      snapsvg.append( spring )
    #      snapsvg.group(circle, spring)
    #    )
    circle = snapsvg.circle(CIRCLE_EQUILIBRIUM + C_RADIUS, C_RADIUS + Y_OFFSET, C_RADIUS)
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
    circle.attr
      transform: 'T' + [
          CIRCLE_EQUILIBRIUM + C_RADIUS,
          C_RADIUS
      ]
    pos = 0
    Graph_A = null
    move = (dx) ->
      @attr transform: @data('origTransform') + 't' + [
        dx
        0
      ]
      pos = (@node.getBoundingClientRect().left - 700) / 200
      Graph_A = (circle.node.getBoundingClientRect().left - 700) / 200
      model.calculator.setExpression
        id: 'A'
        latex: 'A=' + Graph_A / 10

    notDragging = true
    isBouncing = false
    currT = 0
    velocity = 0

    start = ->
      isBouncing = false
      velocity = 0
      currT = 0
      notDragging = false
      @data 'origTransform', @transform().local
      return

    stop = ->
      notDragging = true
      isBouncing = true
      currT = 0
      return

    # TODO rect.drag move, start, stop
    circle.drag move, start, stop

    getVal = (id) ->
      res = null
      calculator.getState().expressions.list.forEach((elem) ->
        res = elem if elem.id == id
      )
      return parseFloat(res.latex.substr(res.latex.indexOf('=') + 1))

    INTERVAL_MS = 60
    MILLI_PER_SEC = 1000
    setInterval(() ->
      return unless isBouncing
      currT += INTERVAL_MS / MILLI_PER_SEC
      currT = 0 if currT > MAX_T
      model.calculator.setExpression
        id: 't_c'
        latex: 't_c=' + currT.toFixed(2)
      #      K = parseFloat(calculator.getState().expressions.list[2].latex.substr(2))
      #      dx = CIRCLE_EQUILIBRIUM - circle.getBBox().x
      #      a = if Math.abs(dx) > 3.0 then K * dx else 0.0
      #      velocity += a
      p_c = 10 * getVal('A') * Math.cos(currT * Math.sqrt(getVal('k') / getVal('m')))
      circle.attr
        transform: 'T' + [
            CIRCLE_EQUILIBRIUM + C_RADIUS + p_c * 300,
            C_RADIUS
        ]
#      spring.node.attr
#        transform: spring.node.transform().local + 's' + (circle.getBBox().x / 2.0)
#      pos = (circle.node.getBoundingClientRect().left - 700) / 200
#      model.calculator.setExpression
#        id: 'A'
#        latex: 'A=' + pos / 2.0
    , INTERVAL_MS)

  setUpBody()
)