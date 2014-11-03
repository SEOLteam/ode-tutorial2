$(() ->
  SlideList = React.createClass
    render: ->
      data = @props.data

      b = []
      for one in data
        b.push React.createElement("div", {"className": "slide"},
            React.createElement("h1", null, (one.unit)),
            React.createElement("h3", null, (one.topic)),
            React.createElement("p", null, (one.p1)),
            React.createElement("p", null, (one.p2)),
            React.createElement("p", null, (one.p3))
          )

      React.createElement("div", null, (b))



  $.get("/data/shm_pilot.json", (data) ->
    React.render(React.createElement(SlideList, {"data": data}), $('#main_section')[0])

    $('#fullpage').fullpage
      sectionsColor: ['#FFFFFF'],
      slidesNavigation: true
  )

)