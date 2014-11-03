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
            <h4>{one.mc.q}</h4>
            <form>
            <input type="radio" name="one" value="a"> {one.mc.a} </input>
            <input type="radio" name="one" value="b"> {one.mc.b} </input>
            <input type="radio" name="one" value="c"> {one.mc.c} </input>
            <input type="radio" name="one" value="d"> {one.mc.d} </input>
            <input type="radio" name="one" value="e"> {one.mc.e} </input>
            <input type="submit" value="Check answer"></input>
            </form>


          </div>

      <div>{b}</div>



  $.get("/data/shm_pilot.json", (data) ->
    React.render(<SlideList data=data />, $('#main_section')[0])

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
