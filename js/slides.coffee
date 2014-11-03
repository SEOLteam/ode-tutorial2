$(() ->


  SlideList = React.createClass
    render: ->
      data = @props.data

      b = []
      for one in data
        b.push React.createElement("div", {"className": "slide"}, React.createElement("h1", null, "content"))

      React.createElement("div", null, (b))



  $.get("/data/slides.json", (data) ->
    React.render(React.createElement(SlideList, {"data": data}), $('#main_section')[0])

    $('#fullpage').fullpage
      sectionsColor: ['#8FB98B'],
      slidesNavigation: true
  )

)