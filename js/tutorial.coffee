$(() ->
  getHashParams = ->
    hash = location.hash.split('?')
    return {} unless hash.length >= 2
    state = {}
    for pair in hash[1].split("&")
      [key, val] = pair.split("=").map(decodeURIComponent)
      try
        val = eval(val)
      catch evalFailed
      state[key] = val
    state


  MAX_A = 0.5
  MAX_T = 4.0
  POSITION_SCALE = 300
  C_RADIUS = 8
  Y_OFFSET = -35
  calculator = null
  setUpCalculator = (calcNode) ->
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
          ymin: -10.0
          xmax: MAX_T
          ymax: 10.0

      expressions:
        list: [
          {
            id: "1"
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
            id: "3"
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

  Simulation = React.createClass(
    SPRING_MASS_Y: 70
    MAX_SPRING_WIDTH: 10
    HEIGHT: 180

    updatePosition: (props) ->
      pos = props['A'] * Math.cos(props['t_c'] * Math.sqrt(props['k'] / props['m']))
      sx = @width * (1 / 2 + pos / MAX_A / 4) / @springWidth
      sy = 1
      cy = @SPRING_MASS_Y - (@spring.node.getBoundingClientRect().top - @spring.node.getBoundingClientRect().bottom) / 2
      cx = 0
      @spring.attr
        transform: 'matrix(' + [sx, 0, 0, sy, cx - sx * cx, 2 * cy - sy * cy] + ')'
      $(@spring.node).find('path').attr('stroke-width', props.k / 10 + 1)
      @circle.attr
        transform: 'S' + [
          Math.pow(50*props.m, 1/3),
          Math.pow(50*props.m, 1/3)
        ] + 'T' + [
          @width * (1 / 2 + pos / MAX_A / 4),
          @SPRING_MASS_Y + C_RADIUS + 12
        ]

    componentWillReceiveProps: (nextProps) ->
      return unless @spring and @circle
      @updatePosition(nextProps)

    componentDidMount: ->
      @width = @getDOMNode().offsetWidth
      snapsvg = Snap(@getDOMNode())
      snapsvg.rect(0, 0, 4, @HEIGHT)
      Snap.load("img/simple_spring.svg", (frag) =>
        @spring = frag.select("g")
        snapsvg.append(@spring)
        @springWidth = @spring.node.getBoundingClientRect().right - @spring.node.getBoundingClientRect().left
        @circle = snapsvg.circle(0, 0, C_RADIUS)
        @circle.attr({
          fill: "#797293",
          stroke: "#CCC3E2",
          strokeWidth: 2
        });
        pos = 0
        prevA = null
        owner = @_owner
        move = (dx) ->
          owner.setState(A: parseFloat((prevA + dx / POSITION_SCALE).toFixed(2)))

        isBouncing = false
        currT = 0
        velocity = 0

        start = =>
          prevA = owner.state.A
          owner.setState(t_c: 0.0)
          owner.setState(isTimeStopped: true)
          isBouncing = false
          velocity = 0
          currT = 0
          @notDragging = false
          @circle.data 'origTransform', @circle.transform().local
          return

        stop = =>
          owner.setState isTimeStopped: false
          isBouncing = true
          currT = 0
          return

        # TODO rect.drag move, start, stop
        @circle.drag move, start, stop

        @updatePosition(@_owner.state)
      )
    render: ->
      React.createElement('svg', className: 'svg')
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
      @updateExpression id, @props[id] for id in ['t_c', 'A', 'k', 'm']

    render: ->
      React.createElement('div', className: 'calculator')
  )

  SpringMass = React.createClass(
    getInitialState: ->
      k: 50   # Spring constant
      m: 4   # Mass
      A: 0.5    # Amplitude
      t_c: 0  # Current time
      p: 0    # Current position
      isTimeStopped: true

    getDefaultProps: ->
      defaults =
        showKSlider: true
        showMSlider: true
        showASlider: true
        showStopwatch: false
        showAnimation: true
        showGraph: true
        periodMs: 50
      $.extend(defaults, getHashParams())

    tick: ->
      return if @state.isTimeStopped
      new_t_c = @state.t_c + @props.periodMs / 1000 # Milliseconds per second
      @setState t_c: new_t_c

    componentDidMount: ->
      activateStopwatch() if @props.showStopwatch
      @interval = setInterval(@tick, @props.periodMs)

    componentWillUnmount: ->
      clearInterval @interval

    handleChangeK: (event) ->
      @setState k: parseFloat(event.target.value)
    handleChangeM: (event) ->
      @setState m: parseFloat(event.target.value)
    handleChangeA: (event) ->
      @setState A: parseFloat(event.target.value)
    timeButton: (event) ->
      if @state.isTimeStopped
        @setState isTimeStopped: false
      else
        @setState isTimeStopped: true, t_c: 0

    getPeriod: ->
      2 * Math.PI * Math.sqrt(@state.m / @state.k)

    getPosition: ->
      @state.A * Math.cos(@state.A * Math.sqrt(@state.t_c / @state.m))

    render: ->
      elems = []

      elems.push(
        React.createElement('div', className: 'control',
          React.createElement('button', className: 'start-reset-button', onClick: @timeButton, if @state.isTimeStopped then 'START' else 'RESET')
        )
      )

      if @props.showKSlider
        elems.push(
          React.createElement('div', className: 'control', [
            React.createElement('h5', null, "Spring K: #{@state.k} N/m"),
            React.createElement('input',
              type: 'range', disabled: !@state.isTimeStopped, min: '1', max: '100', step: '1.0', value: @state.k, onChange: @handleChangeK)
          ])
        )

      if @props.showMSlider
        elems.push(
          React.createElement('div', className: 'control', [
            React.createElement('h5', null, "Mass m: #{parseFloat(@state.m).toFixed(2)} kg"),
            React.createElement('input',
              type: 'range', disabled: !@state.isTimeStopped, min: '1', max: '10', step: '0.25', value: @state.m, onChange: @handleChangeM)
          ])
        )

      if @props.showASlider
        elems.push(
          React.createElement('div', className: 'control', [
            React.createElement('h5', null, "Amplitude A: #{parseFloat((@state.A) * 10 + 1).toFixed(2)} cm"),
            React.createElement('input',
              type: 'range', disabled: !@state.isTimeStopped, min: 0, max: MAX_A, step: '0.02', value: @state.A, onChange: @handleChangeA)
          ])
        )

      # Stopwatch
      if @props.showStopwatch
        elems.push(React.createElement('div', id: 'stopwatch',
          React.createElement('p', className: 'time',
            React.createElement('span', id: 'seconds', '00')
            ':'
            React.createElement('span', id: 'tenths', '00')
          )
          React.createElement('button', id: 'button-start', 'Start')
          React.createElement('button', id: 'button-stop', 'Stop')
          React.createElement('button', id: 'button-reset', 'Reset')
        ))

      if @props.showAnimation
        ruler = React.createElement('img', src: 'img/ruler_long.svg')
        elems.push(React.createElement(Simulation, @state), React.createElement('div', className: 'ruler', ruler))

      if @props.showGraph
        elems.push(
          React.createElement(Calculator, @state),
        )

      elems.push(
        React.createElement('div', null, "Position: #{}")
      )

      React.createElement('div', null,
        elems
      )
  )

  React.render(React.createElement(SpringMass), document.getElementById('app'))
)