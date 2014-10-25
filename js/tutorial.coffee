$('#tutorial').width('100%').height(800).split
  orientation: 'vertical'
  limit: 100
  position: '20%'

$('#right_pane').split
  orientation: 'horizontal'
  limit: 10

elt = document.getElementById('calculator')
calculator = Desmos.Calculator(elt)
calculator.setExpression
  id: 'graph1'
  latex: 'y=sin(x)'

calculator.setExpression
  id: 'ab'
  latex: '(a,b)'

calculator.setExpression
  id: 'a'
  latex: 'a=0'

calculator.setExpression
  id: 'b'
  latex: 'b=sin(a)'

s = Snap('#svg')
rect = s.rect(20, 20, 40, 40)
circle = s.circle(60, 150, 50)
pos = 0
move = (dx, dy) ->
  @attr transform: @data('origTransform') + ((if @data('origTransform') then 'T' else 't')) + [
    dx
    dy
  ]
  pos = (@node.getBoundingClientRect().left - 700) / 200
  calculator.setExpression
    id: 'a'
    latex: 'a=' + pos

  console.log 'box is', @node.getBBox()
  console.log 'x is', @node.getBBox().x
  return

start = ->
  @data 'origTransform', @transform().local
  return

stop = ->
  console.log 'finished dragging'
  return

rect.drag move, start, stop
circle.drag move, start, stop