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
            React.createElement("p", null, (one.p3)),
            React.createElement("h4", null, (one.mc.q)),
            React.createElement("form", null,
            React.createElement("input", {"type": "radio", "name": "one", "value": "a"}, " ", (one.mc.a), " "),
            React.createElement("input", {"type": "radio", "name": "one", "value": "b"}, " ", (one.mc.b), " "),
            React.createElement("input", {"type": "radio", "name": "one", "value": "c"}, " ", (one.mc.c), " "),
            React.createElement("input", {"type": "radio", "name": "one", "value": "d"}, " ", (one.mc.d), " "),
            React.createElement("input", {"type": "radio", "name": "one", "value": "e"}, " ", (one.mc.e), " "),
            React.createElement("input", {"type": "submit", "value": "Check answer"})
            )
          )

      React.createElement("div", null, (b))



  $.get("/data/shm_pilot.json", (data) ->
    React.render(React.createElement(SlideList, {"data": data}), $('#main_section')[0])

    $('#fullpage').fullpage
      sectionsColor: ['#FFFFFF'],
      slidesNavigation: true
  )
)

#            <div class="btn-group btn-group-justified">
#            <div class="btn-group">
#            <button type="button" class="btn btn-default">Left</button>
#            </div>
#            <div class="btn-group">
#            <button type="button" class="btn btn-default">Middle</button>
#            </div>
#            <div class="btn-group">
#            <button type="button" class="btn btn-default">Right</button>
#            </div>
#            </div>
