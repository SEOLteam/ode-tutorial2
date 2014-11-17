$(() ->
  getPage = ->
    location.hash.split('?')[0].substr(2)

  getHashParams = ->
    hash = location.hash.split('?')
    return {} unless len(hash) > 2
    state = {}
    for pair in hash[1].split("&")
      [key, val] = pair.split("=").map(decodeURIComponent)
      state[key] = val
    state

  MAX_T = 4.0

  calculator = null
  setUpCalculator = (calcNode) ->
#    elt = $(calcNode)
    calculator = Desmos.Calculator(calcNode,
      keypad: false
      graphpaper: true
      expressions: false
      settingsMenu: false
      zoomButtons: false
      expressionsTopbar: false
      solutions: false
      border: true
      lockViewport: true
    )
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
        xAxisLabel: "Time (t)"
        yAxisLabel: "Position (x)"
        xAxisNumbers: true
        yAxisNumbers: true
        polarNumbers: true
        projectorMode: true
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
    calculator # TODO NOOO!!

  snapsvg = null
  CIRCLE_EQUILIBRIUM = 300
  C_RADIUS = 50
  Y_OFFSET = 20
  setUpSimulation = (node) ->
    snapsvg = Snap(node)
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

  #    INTERVAL_MS = 60
  #    MILLI_PER_SEC = 1000
  #    setInterval(() ->
  #      return unless isBouncing
  #      currT = 0 if currT > MAX_T
  #      model.calculator.setExpression
  #        id: 't_c'
  #        latex: 't_c=' + currT.toFixed(2)
  #      K = parseFloat(calculator.getState().expressions.list[2].latex.substr(2))
  #      dx = CIRCLE_EQUILIBRIUM - circle.getBBox().x
  #      a = if Math.abs(dx) > 3.0 then K * dx else 0.0
  #      velocity += a
  #      p_c = 10 * getVal('A') * Math.cos(currT * Math.sqrt(getVal('k') / getVal('m')))
  #      circle.attr
  #        transform: 'T' + [
  #          CIRCLE_EQUILIBRIUM + C_RADIUS + p_c * 300,
  #          C_RADIUS
  #        ]
  #      spring.node.attr
  #        transform: spring.node.transform().local + 's' + (circle.getBBox().x / 2.0)
  #      pos = (circle.node.getBoundingClientRect().left - 700) / 200
  #      model.calculator.setExpression
  #        id: 'A'
  #        latex: 'A=' + pos / 2.0

  #setUpBody()

  Simulation = React.createClass(
    componentDidMount: ->
      setUpSimulation(@getDOMNode())
    render: ->
      React.createElement('svg', style: {width: '100%', height: '400px'})
  )

  Calculator = React.createClass(
    updateExpression: (id, val) ->
      @desmosCalc.setExpression
        id: id
        latex: "#{id}=#{val.toFixed(2)}"

    componentWillReceiveProps: (nextProps) ->
      if @desmosCalc
        @updateExpression id, nextProps[id] for id in ['t_c', 'A', 'k', 'm'] when nextProps[id] != @props[id]

    componentDidMount: ->
      @desmosCalc = setUpCalculator(@getDOMNode())

    render: ->
      React.createElement('div', className: 'calculator')
  )

  SpringMass = React.createClass(
    getInitialState: ->
      k: 10   # Spring constant
      m: 10   # Mass
      A: 1    # Amplitude
      t_c: 0  # Current time
      p: 0    # Current position
      page: getPage()

    tick: ->
      new_t_c = @state.t_c + @props.periodMs / 1000 # Milliseconds per second
      new_t_c = 0.0 if new_t_c > 4.0
      @setState t_c: new_t_c

    componentDidMount: ->
      @interval = setInterval(@tick, @props.periodMs)

    componentWillUnmount: ->
      clearInterval @interval

    handleChangeK: (event) ->
      @setState(k: parseFloat(event.target.value))
    handleChangeM: (event) ->
      @setState(m: parseFloat(event.target.value))
    handleChangeA: (event) ->
      @setState(A: parseFloat(event.target.value))

    render: ->
      elems = []
      k_slider = []
      k_slider.push(React.createElement('h5', null, 'Spring Constant'))
      k_slider.push(React.createElement('input', type: 'range', min: '0', max: '10', value: @state.k, onChange: @handleChangeK))

      m_slider = []
      m_slider.push(React.createElement('h5', null, 'Mass'))
      m_slider.push(React.createElement('input', type: 'range', min: '0', max: '10', step: '0.5', value: @state.m, onChange: @handleChangeM))

      A_slider = []
      A_slider.push(React.createElement('h5', null, 'Amplitude'))
      A_slider.push(React.createElement('input', type: 'range', min: '0', max: '10', step: '0.1', value: @state.A, onChange: @handleChangeA))

      elems.push(
        React.createElement('div', className: 'slider', k_slider)
        React.createElement('div', className: 'slider', m_slider)
        React.createElement('div', className: 'slider', A_slider)
      )
      if @state.page == 'calculator'
        elems.push(React.createElement(Calculator, @state))
      else if @state.page == 'simulation'
        elems.push(React.createElement(Simulation, @state))
      else
        elems.push(React.createElement(Simulation, @state))
        elems.push(React.createElement(Calculator, @state))
      React.createElement('div', null,
        elems
      )
  )

  React.render(React.createElement(SpringMass, display: location.hash, periodMs: 50), document.getElementById('app'));
)