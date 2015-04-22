$(function() {
  var C_RADIUS, Graph, MAX_A, MAX_T, SpringAnimation, SpringMass, SpringParameters, calculator, getHashParams, setUpCalculator, snapsvg;
  getHashParams = function() {
    var defaults, hash, key, pair, possibleNumber, state, val, _i, _len, _ref, _ref1;
    hash = location.hash.split('?');
    defaults = {
      showSpringParameters: true,
      showSpringAnimation: true,
      showTable: false,
      showGraph: true,
      showKSlider: true,
      showMSlider: true,
      showASlider: true,
      periodMs: 50
    };
    if (!(hash.length >= 2)) {
      return defaults;
    }
    state = {};
    _ref = hash[1].split("&");
    for (_i = 0, _len = _ref.length; _i < _len; _i++) {
      pair = _ref[_i];
      _ref1 = pair.split("=").map(decodeURIComponent), key = _ref1[0], val = _ref1[1];
      if (val === 'true') {
        val = true;
      } else if (val === 'false') {
        val = false;
      } else {
        possibleNumber = Number(val);
        if (!isNaN(possibleNumber)) {
          val = possibleNumber;
        }
      }
      state[key] = val;
    }
    return $.extend(defaults, state);
  };
  MAX_A = 0.5;
  MAX_T = 4.0;
  C_RADIUS = 8;
  calculator = null;
  setUpCalculator = function(calcNode) {
    calculator = Desmos.Calculator(calcNode, {
      keypad: false,
      graphpaper: true,
      expressions: false,
      settingsMenu: false,
      zoomButtons: false,
      expressionsTopbar: false,
      solutions: false,
      border: true,
      lockViewport: true
    });
    calculator.setState({
      graph: {
        showGrid: true,
        polarMode: false,
        showXAxis: true,
        showYAxis: true,
        xAxisStep: 0,
        yAxisStep: 0,
        degreeMode: false,
        xAxisArrows: "none",
        yAxisArrows: "none",
        xAxisLabel: "Time (t)",
        yAxisLabel: "Position (x)",
        xAxisNumbers: true,
        yAxisNumbers: true,
        polarNumbers: true,
        projectorMode: true,
        squareAxes: true,
        viewport: {
          xmin: 0.0,
          ymin: -10.0,
          xmax: MAX_T,
          ymax: 10.0
        }
      },
      expressions: {
        list: [
          {
            id: "1",
            latex: "p=A\\cdot\\cos\\left(t\\cdot\\sqrt{\\frac{k}{m}}\\right)",
            domain: {
              min: 0,
              max: 1
            },
            hidden: false,
            color: "#4F81BD",
            style: "normal",
            residualVariable: "",
            regressionParameters: {}
          }, {
            id: "2",
            latex: "p_c=A\\cdot\\cos\\left(t_c\\cdot\\sqrt{\\frac{k}{m}}\\right)",
            domain: {
              min: 0,
              max: 1
            },
            hidden: false,
            color: "#4F81BD",
            style: "normal",
            residualVariable: "",
            regressionParameters: {}
          }, {
            id: "3",
            latex: "\\left(t_c,p_c\\right)",
            domain: {
              min: 0,
              max: 1
            },
            hidden: false,
            color: "#8064A2",
            style: "point",
            residualVariable: "",
            regressionParameters: {}
          }
        ]
      }
    });
    return calculator;
  };
  snapsvg = null;
  SpringAnimation = React.createClass({
    SPRING_MASS_Y: 50,
    MAX_SPRING_WIDTH: 10,
    HEIGHT: 180,
    MID_LINE_WIDTH: 2,
    updatePosition: function(props) {
      var cx, cy, pos, sx, sy;
      pos = props.pos;
      sx = this.width * (1 / 2 + pos / MAX_A / 4) / this.springWidth;
      sy = 1;
      cy = this.SPRING_MASS_Y - (this.spring.node.getBoundingClientRect().top - this.spring.node.getBoundingClientRect().bottom) / 2;
      cx = 0;
      this.spring.attr({
        transform: 'matrix(' + [sx, 0, 0, sy, cx - sx * cx, 2 * cy - sy * cy] + ')'
      });
      $(this.spring.node).find('path').attr('stroke-width', props.k / 10 + 1);
      return this.circle.attr({
        transform: 'S' + [props.m, props.m] + 'T' + [this.width * (1 / 2 + pos / MAX_A / 4), this.SPRING_MASS_Y + C_RADIUS + 12]
      });
    },
    componentWillReceiveProps: function(nextProps) {
      if (!(this.spring && this.circle)) {
        return;
      }
      return this.updatePosition(nextProps);
    },
    componentDidMount: function() {
      var x_axis;
      this.width = this.getDOMNode().offsetWidth;
      snapsvg = Snap(this.getDOMNode());
      snapsvg.rect(0, 0, 4, this.HEIGHT);
      snapsvg.rect((this.width - this.MID_LINE_WIDTH) / 2, 0, this.MID_LINE_WIDTH, this.HEIGHT).attr({
        fill: "#41a647"
      });
      x_axis = snapsvg.text(this.width / 2 + 20, this.HEIGHT * 0.8, '→').attr({
        fill: "#41a647",
        transform: 'S' + [6.0, 1.0]
      });
      snapsvg.text(this.width / 2 + 80, this.HEIGHT * 0.8, '+x').attr({
        fill: "#41a647"
      });
      return Snap.load("img/simple_spring.svg", (function(_this) {
        return function(frag) {
          var move, owner, pos, prevA, start, stop;
          _this.spring = frag.select("g");
          snapsvg.append(_this.spring);
          _this.springWidth = _this.spring.node.getBoundingClientRect().right - _this.spring.node.getBoundingClientRect().left;
          _this.circle = snapsvg.circle(0, 0, C_RADIUS);
          _this.circle.attr({
            fill: "#797293",
            stroke: "#CCC3E2",
            strokeWidth: 2
          });
          pos = 0;
          prevA = null;
          owner = _this._owner;
          move = function(dx) {
            var newA;
            newA = prevA + dx * 2 / _this.width;
            newA = Math.max(Math.min(newA, MAX_A), -MAX_A);
            return owner.setState({
              A: newA
            });
          };
          start = function() {
            prevA = owner.state.A;
            owner.setState({
              t_c: 0.0
            });
            owner.setState({
              isTimeStopped: true
            });
            _this.notDragging = false;
            _this.circle.data('origTransform', _this.circle.transform().local);
          };
          stop = function() {};
          _this.circle.drag(move, start, stop);
          return _this.updatePosition(_this._owner.state);
        };
      })(this));
    },
    render: function() {
      return React.createElement('svg', {
        className: 'simulation'
      });
    }
  });
  Graph = React.createClass({
    updateExpression: function(id, val) {
      return this.desmosCalc.setExpression({
        id: id,
        latex: "" + id + "=" + (val.toFixed(2))
      });
    },
    componentWillReceiveProps: function(nextProps) {
      var id, _i, _len, _ref, _results;
      if (this.desmosCalc) {
        _ref = ['t_c', 'A', 'k', 'm'];
        _results = [];
        for (_i = 0, _len = _ref.length; _i < _len; _i++) {
          id = _ref[_i];
          if (nextProps[id] !== this.props[id]) {
            _results.push(this.updateExpression(id, nextProps[id]));
          }
        }
        return _results;
      }
    },
    componentDidMount: function() {
      var id, _i, _len, _ref, _results;
      this.desmosCalc = setUpCalculator(this.getDOMNode());
      _ref = ['t_c', 'A', 'k', 'm'];
      _results = [];
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        id = _ref[_i];
        _results.push(this.updateExpression(id, this.props[id]));
      }
      return _results;
    },
    render: function() {
      return React.createElement('div', {
        className: 'calculator'
      });
    }
  });
  SpringParameters = React.createClass({
    createStartButton: function() {
      var startButtonText;
      startButtonText = (function() {
        switch (false) {
          case this.props.A !== 0:
            return 'DRAG MASS';
          case !this.props.isTimeStopped:
            return 'START';
          default:
            return 'RESET';
        }
      }).call(this);
      return React.createElement('div', {
        className: 'control'
      }, React.createElement('button', {
        disabled: this.props.A === 0,
        className: 'start-reset-button',
        onClick: this._owner.timeButton
      }, startButtonText));
    },
    handleChangeK: function(event) {
      return this._owner.setState({
        k: parseFloat(event.target.value)
      });
    },
    handleChangeM: function(event) {
      return this._owner.setState({
        m: parseFloat(event.target.value)
      });
    },
    handleChangeA: function(event) {
      return this._owner.setState({
        A: parseFloat(event.target.value)
      });
    },
    render: function() {
      var elems;
      elems = [];
      elems.push(this.createStartButton());
      if (this.props.showKSlider) {
        elems.push(React.createElement('div', {
          className: 'control'
        }, [
          React.createElement('h5', null, "Spring k: " + this.props.k + " N/m"), React.createElement('input', {
            type: 'range',
            disabled: !this.props.isTimeStopped,
            min: '1',
            max: '100',
            step: '1.0',
            value: this.props.k,
            onChange: this.handleChangeK
          })
        ]));
      }
      if (this.props.showMSlider) {
        elems.push(React.createElement('div', {
          className: 'control'
        }, [
          React.createElement('h5', null, "Mass m: " + this.props.m + " kg"), React.createElement('input', {
            type: 'range',
            disabled: !this.props.isTimeStopped,
            min: '1',
            max: '7',
            step: '1.0',
            value: this.props.m,
            onChange: this.handleChangeM
          })
        ]));
      }
      if (this.props.showASlider) {
        elems.push(React.createElement('div', {
          className: 'control'
        }, [
          React.createElement('h5', null, "Starting Position A: " + (this.props.A.toFixed(2)) + " m"), React.createElement('input', {
            type: 'range',
            disabled: !this.props.isTimeStopped,
            min: -MAX_A,
            max: MAX_A,
            step: '0.001',
            value: this.props.A,
            onChange: this.handleChangeA
          })
        ]));
      }
      return React.createElement('div', null, elems);
    }
  });
  SpringMass = React.createClass({
    clearPoints: function() {
      return this.setState({
        dataPoints: []
      });
    },
    recordPoint: function() {
      var dps;
      dps = this.state.dataPoints;
      dps.push({
        t: this.state.t_c,
        p: this.pos,
        v: this.vel,
        a: this.acc
      });
      return this.setState({
        dataPoints: dps
      });
    },
    updateHashParams: function() {
      return this.setState(getHashParams());
    },
    getInitialState: function() {
      var state;
      state = {
        k: 50,
        m: 4,
        A: 0,
        t_c: 0,
        pos: 0,
        vel: 0,
        acc: 0,
        isTimeStopped: true,
        startTime: null,
        dataPoints: []
      };
      return $.extend(state, getHashParams());
    },
    updateHashParams: function() {
      return this.setState($.extend({}, this.state, getHashParams()));
    },
    tick: function(timestamp) {
      var new_t_c;
      if (!this.state.isTimeStopped) {
        if (this.state.startTime !== null) {
          new_t_c = (timestamp - this.state.startTime) / 1000;
        } else {
          new_t_c = 0;
          this.setState({
            startTime: timestamp
          });
        }
        this.setState({
          t_c: new_t_c
        });
      }
      if (this.isMounted()) {
        return window.requestAnimationFrame(this.tick);
      }
    },
    componentDidMount: function() {
      window.requestAnimationFrame(this.tick);
      return this.hashChange = window.addEventListener('hashchange', this.updateHashParams());
    },
    componentWillUnmount: function() {
      return window.removeEventListener(this.hashChange);
    },
    startBouncing: function() {
      return this.setState({
        isTimeStopped: false,
        t_c: 0,
        startTime: null
      });
    },
    timeButton: function(event) {
      if (this.state.isTimeStopped) {
        return this.startBouncing();
      } else {
        return this.setState({
          isTimeStopped: true,
          t_c: 0,
          startTime: null
        });
      }
    },
    getPeriod: function() {
      return 2 * Math.PI * Math.sqrt(this.state.m / this.state.k);
    },
    getPosition: function() {
      return this.state.A * Math.cos(this.state.A * Math.sqrt(this.state.t_c / this.state.m));
    },
    createChildProps: function() {
      this.pos = this.state['A'] * Math.cos(this.state['t_c'] * Math.sqrt(this.state['k'] / this.state['m']));
      this.vel = -Math.sqrt(this.state['k'] / this.state['m']) * this.state['A'] * Math.sin(this.state['t_c'] * Math.sqrt(this.state['k'] / this.state['m']));
      this.acc = -this.state['k'] / this.state['m'] * this.state['A'] * Math.cos(this.state['t_c'] * Math.sqrt(this.state['k'] / this.state['m']));
      return $.extend({}, this.state, {
        pos: this.pos,
        vel: this.vel,
        acc: this.acc
      });
    },
    createTable: function() {
      var point, pointElems, tableRows, _i, _len, _ref;
      pointElems = [];
      pointElems.push(React.createElement('p', {
        className: 'time'
      }, [
        "Time: ", React.createElement('span', {
          id: 'seconds'
        }, this.state.t_c.toFixed(1)), " sec"
      ]));
      pointElems.push(React.createElement('button', {
        onClick: this.recordPoint
      }, 'Record'));
      pointElems.push(React.createElement('button', {
        onClick: this.clearPoints
      }, 'Clear'));
      tableRows = [];
      if (this.state.dataPoints.length > 0) {
        tableRows.push(React.createElement('tr', null, [React.createElement('th', null, 'Time'), React.createElement('th', null, 'Position'), React.createElement('th', null, 'Velocity'), React.createElement('th', null, 'Acceleration')]));
      }
      _ref = this.state.dataPoints;
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        point = _ref[_i];
        tableRows.push(React.createElement('tr', null, [React.createElement('td', null, point.t.toFixed(2)), React.createElement('td', null, point.p.toFixed(2)), React.createElement('td', null, point.v.toFixed(2)), React.createElement('td', null, point.a.toFixed(2))]));
      }
      pointElems.push(React.createElement('table', {
        style: {
          margin: 'auto auto'
        }
      }, tableRows));
      return React.createElement('div', {
        id: 'stopwatch'
      }, pointElems);
    },
    render: function() {
      var elems, props;
      elems = [];
      props = this.createChildProps();
      if (this.state.showSpringParameters) {
        elems.push(React.createElement(SpringParameters, props));
      }
      if (this.state.showSpringAnimation) {
        elems.push(React.createElement(SpringAnimation, props));
      }
      if (this.state.showStopwatch) {
        elems.push(this.createTable());
      }
      if (this.state.showGraph) {
        elems.push(React.createElement(Graph, props));
      }
      return React.createElement('div', null, elems);
    }
  });
  return React.render(React.createElement(SpringMass), document.getElementById('app'));
});
