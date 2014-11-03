$(() ->


  SlideList = React.createClass
    render: ->
      data = @props.data

      b = []
      for one in data
        b.push <div className = "slide"><h1>content</h1></div>

      <div>{b}</div>



  $.get("/data/slides.json", (data) ->
    React.render(<SlideList data=data />, $('#main_section')[0])

    $('#fullpage').fullpage
      sectionsColor: ['#8FB98B'],
      slidesNavigation: true
  )

)