(function ($) {
    $('#tutorial').width('100%').height(800).split({orientation: 'vertical', limit: 100, position: '20%'});
    $('#right_pane').split({orientation: 'horizontal', limit: 10});
    var elt = document.getElementById('calculator');
    var calculator = Desmos.Calculator(elt);
    calculator.setExpression({id: 'graph1', latex: 'y=sin(x)'});
    calculator.setExpression({id: 'ab', latex: '(a,b)'});
    calculator.setExpression({id: 'a', latex: 'a=0'});
    calculator.setExpression({id: 'b', latex: 'b=sin(a)'});
    //var s = Snap("#svg");
    // Lets create big circle in the middle:
    //var bigCircle = s.circle(150, 150, 100);
    var s = Snap("#svg");

    var rect = s.rect(20, 20, 40, 40);
    var circle = s.circle(60, 150, 50);

    var pos = 0;

    var move = function (dx, dy) {
        this.attr({
            transform: this.data('origTransform') + (this.data('origTransform') ? "T" : "t") + [dx, dy]
        });
        pos = (this.node.getBoundingClientRect().left - 700) / 200;
        calculator.setExpression({id: 'a', latex: 'a=' + pos});
        console.log('box is', this.node.getBBox());
        console.log('x is', this.node.getBBox().x);
    }

    var start = function () {
        this.data('origTransform', this.transform().local);
    }
    var stop = function () {
        console.log('finished dragging');
    }

    rect.drag(move, start, stop);
    circle.drag(move, start, stop);
})(jQuery);