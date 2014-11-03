$(() ->
  SlideList = React.createClass
    render: ->
      data = @props.data

      b = []
      for one in data
        b.push <div className = "slide">
            <h1>{one.unit}</h1>
            <h3>{one.topic}</h3>
            <p>{one.p1}</p>
            <p>{one.p2}</p>
            <p>{one.p3}</p>
          </div>

      <div>{b}</div>



  $.get("/data/shm_pilot.json", (data) ->
    React.render(<SlideList data=data />, $('#main_section')[0])

    $('#fullpage').fullpage
      sectionsColor: ['#FFFFFF'],
      slidesNavigation: true
  )

)