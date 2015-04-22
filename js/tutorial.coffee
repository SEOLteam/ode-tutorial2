$(() ->
  getHashParams = ->
    hash = location.hash.split('?')
    defaults =
      showSpringParameters: true
      showSpringAnimation: true
      showTable: false
      showGraph: true
      showKSlider: true
      showMSlider: true
      showASlider: true
      periodMs: 50
    return defaults unless hash.length >= 2
    state = {}
    for pair in hash[1].split("&")
      [key, val] = pair.split("=").map(decodeURIComponent)
      if val == 'true'
        val = true
      else if val == 'false'
        val = false
      else
        possibleNumber = Number(val)
        val = possibleNumber unless isNaN(possibleNumber)
      state[key] = val
    $.extend(defaults, state)

  MAX_A = 0.5
  MAX_T = 4.0
  C_RADIUS = 8
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
    calculator

  snapsvg = null

  SpringAnimation = React.createClass(
    SPRING_MASS_Y: 50
    MAX_SPRING_WIDTH: 10
    HEIGHT: 180
    MID_LINE_WIDTH: 2

    updatePosition: (props) ->
      pos = props.pos
      sx = @width * (1 / 2 + pos / MAX_A / 4) / @springWidth
      sy = 1
      cy = @SPRING_MASS_Y - (@spring.node.getBoundingClientRect().top - @spring.node.getBoundingClientRect().bottom) / 2
      cx = 0
      @spring.attr
        transform: 'matrix(' + [sx, 0, 0, sy, cx - sx * cx, 2 * cy - sy * cy] + ')'
      $(@spring.node).find('path').attr('stroke-width', props.k / 10 + 1)
      @circle.attr
        transform: 'S' + [
          props.m,
          props.m
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
      snapsvg.rect((@width - @MID_LINE_WIDTH ) / 2, 0, @MID_LINE_WIDTH, @HEIGHT).
      attr(
        fill: "#41a647"
      )
      x_axis = snapsvg.text(@width / 2 + 20, @HEIGHT * 0.8, '→').attr(fill: "#41a647", transform: 'S' + [6.0, 1.0])
      snapsvg.text(@width / 2 + 80, @HEIGHT * 0.8, '+x').attr(fill: "#41a647")
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
        move = (dx) =>
          newA = prevA + dx * 2 / @width
          newA = Math.max(Math.min(newA, MAX_A), -MAX_A)
          owner.setState(A: newA)

        start = =>
          prevA = owner.state.A
          owner.setState(t_c: 0.0)
          owner.setState(isTimeStopped: true)
          @notDragging = false
          @circle.data 'origTransform', @circle.transform().local
          return

        stop = =>
          return

        @circle.drag move, start, stop

        @updatePosition(@_owner.state)
      )
    render: ->
      React.createElement('svg', className: 'simulation')
  )

  Graph = React.createClass(
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

  SpringParameters = React.createClass(
    createStartButton: ->
      startButtonText = switch
        when @props.A == 0 then 'DRAG MASS'
        when @props.isTimeStopped then 'START'
        else
          'RESET'
      React.createElement('div', className: 'control',
        React.createElement('button',
          disabled: @props.A == 0, className: 'start-reset-button', onClick: @_owner.timeButton, startButtonText)
      )

    handleChangeK: (event) ->
      @._owner.setState k: parseFloat(event.target.value)
    handleChangeM: (event) ->
      @._owner.setState m: parseFloat(event.target.value)
    handleChangeA: (event) ->
      @._owner.setState A: parseFloat(event.target.value)

    render: ->
      elems = []

      elems.push @createStartButton()

      if @props.showKSlider
        elems.push(
          React.createElement('div', className: 'control', [
            React.createElement('h5', null, "Spring k: #{@props.k} N/m"),
            React.createElement('input',
              type: 'range', disabled: !@props.isTimeStopped, min: '1', max: '100', step: '1.0', value: @props.k, onChange: @handleChangeK)
          ])
        )

      if @props.showMSlider
        elems.push(
          React.createElement('div', className: 'control', [
            React.createElement('h5', null, "Mass m: #{@props.m} kg"),
            React.createElement('input',
              type: 'range', disabled: !@props.isTimeStopped, min: '1', max: '7', step: '1.0', value: @props.m, onChange: @handleChangeM)
          ])
        )

      if @props.showASlider
        elems.push(
          React.createElement('div', className: 'control', [
            React.createElement('h5', null, "Starting Position A: #{@props.A.toFixed(2)} m"),
            React.createElement('input',
              type: 'range', disabled: !@props.isTimeStopped, min: -MAX_A, max: MAX_A, step: '0.001', value: @props.A, onChange: @handleChangeA)
          ])
        )

      React.createElement('div', null, elems)
  )

  SpringMass = React.createClass(
    clearPoints: ->
      @setState dataPoints: []

    recordPoint: ->
      dps = @state.dataPoints
      dps.push(
        t: @state.t_c,
        p: @pos,
        v: @vel,
        a: @acc
      )
      @setState dataPoints: dps

    updateHashParams: ->
      @setState(getHashParams())

    getInitialState: ->
      state =
        k: 50   # Spring constant
        m: 4    # Mass
        A: 0    # Amplitude
        t_c: 0  # Current time
        pos: 0  # Current position
        vel: 0
        acc: 0
        isTimeStopped: true
        startTime: null
        dataPoints: []
      $.extend(state, getHashParams())

    updateHashParams: ->
      @setState $.extend({}, @state, getHashParams())

    tick: (timestamp) ->
      if !@state.isTimeStopped
        if @state.startTime != null
          new_t_c = (timestamp - @state.startTime) / 1000
        else
          new_t_c = 0
          @setState startTime: timestamp
        @setState t_c: new_t_c
      window.requestAnimationFrame(@tick) if @isMounted()

    componentDidMount: ->
      window.requestAnimationFrame(@tick)
      @hashChange = window.addEventListener('hashchange', @updateHashParams());

    componentWillUnmount: ->
      window.removeEventListener(@hashChange)

    startBouncing: ->
      @setState isTimeStopped: false, t_c: 0, startTime: null
    timeButton: (event) ->
      if @state.isTimeStopped
        @startBouncing()
      else
        @setState isTimeStopped: true, t_c: 0, startTime: null

    getPeriod: ->
      2 * Math.PI * Math.sqrt(@state.m / @state.k)

    getPosition: ->
      @state.A * Math.cos(@state.A * Math.sqrt(@state.t_c / @state.m))

    createChildProps: ->
      @pos = @state['A'] * Math.cos(@state['t_c'] * Math.sqrt(@state['k'] / @state['m']))
      @vel = -Math.sqrt(@state['k'] / @state['m']) * @state['A'] * Math.sin(@state['t_c'] * Math.sqrt(@state['k'] / @state['m']))
      @acc = -@state['k'] / @state['m'] * @state['A'] * Math.cos(@state['t_c'] * Math.sqrt(@state['k'] / @state['m']))
      $.extend({}, @state,
        pos: @pos
        vel: @vel
        acc: @acc
      )

    createTable: ->
      pointElems = []
      pointElems.push(
        React.createElement('p', className: 'time',
          ["Time: ", React.createElement('span', id: 'seconds', @state.t_c.toFixed(1)), " sec"])
      )
      pointElems.push(React.createElement('button', onClick: @recordPoint, 'Record'))
      pointElems.push(React.createElement('button', onClick: @clearPoints, 'Clear'))
      tableRows = []
      if @state.dataPoints.length > 0
        tableRows.push(React.createElement('tr', null, [
          React.createElement('th', null, 'Time'),
          React.createElement('th', null, 'Position'),
          React.createElement('th', null, 'Velocity'),
          React.createElement('th', null, 'Acceleration')
        ]))
      for point in @state.dataPoints
        tableRows.push(React.createElement('tr', null, [
          React.createElement('td', null, point.t.toFixed(2)),
          React.createElement('td', null, point.p.toFixed(2)),
          React.createElement('td', null, point.v.toFixed(2)),
          React.createElement('td', null, point.a.toFixed(2))
        ]))
      pointElems.push(React.createElement('table', style: {margin: 'auto auto'}, tableRows))
      React.createElement('div', id: 'stopwatch', pointElems)

    render: ->
      elems = []

      props = @createChildProps()
      elems.push(React.createElement(SpringParameters, props)) if @state.showSpringParameters
      elems.push(React.createElement(SpringAnimation, props)) if @state.showSpringAnimation
      elems.push(@createTable()) if @state.showStopwatch
      elems.push(React.createElement(Graph, props)) if @state.showGraph

      React.createElement('div', null, elems)
  )

  React.render(React.createElement(SpringMass), document.getElementById('app'))
)