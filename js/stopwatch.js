/**
 * Created by haichuanyu on 2/5/15.
 */
/**
 * Created by Haichuan on 11/30/2014.
 */
function activateStopwatch() {
    "use strict";

    var lap = 0;
    var startTime = 0;
    var seconds = 0;
    var tenths = 0;
    var appendTens = document.getElementById("tenths");
    var appendSeconds = document.getElementById("seconds");
    var buttonStart = document.getElementById('button-start');
    var buttonStop = document.getElementById('button-stop');
    var buttonLap = document.getElementById('button-lap');
    var buttonReset = document.getElementById('button-reset');
    var Interval ;
    var appendLog = [];
    appendLog.push(document.getElementById("log-1"));
    appendLog.push(document.getElementById("log-2"));
    appendLog.push(document.getElementById("log-3"));
    appendLog.push(document.getElementById("log-4"));
    appendLog.push(document.getElementById("log-5"));


    buttonStart.onclick = function() {
        startTime = window.performance.now();

        clearInterval(Interval);
        Interval = setInterval(startTimer, 10);
    };

    buttonStop.onclick = function() {
        clearInterval(Interval);
    };

    buttonLap.onclick = function() {
        if(lap < 5) {
            if (tenths < 9) {
                if (seconds < 9) { appendLog[lap].innerHTML = (lap + 1) + '. ' + "0" + seconds + ':' + "0" + tenths; }
                if (seconds > 9) { appendLog[lap].innerHTML = (lap + 1) + '. ' + seconds + ':' + "0" + tenths; }
            }

            if (tenths > 9) {
                if (seconds < 9) { appendLog[lap].innerHTML = (lap + 1) + '. ' + "0" + seconds + ':' + tenths; }
                if (seconds > 9) { appendLog[lap].innerHTML = (lap + 1) + '. ' + seconds + ':' + tenths; }
            }

            // Remove current class from all log entries
            appendLog.forEach(function(element) {
                element.className = 'log'
            });
            // Apply current class to current entry
            appendLog[lap].className = appendLog[lap].className + ' ' + 'current';
        }
        else {
            var prev, curr;
            appendLog.reverse();

            appendLog.forEach(function(element){
                curr = element.innerHTML;
                element.innerHTML = prev;
                prev = curr;
            });

            if (tenths < 9) {
                if (seconds < 9) { appendLog[0].innerHTML = (lap + 1) + '. ' + "0" + seconds + ':' + "0" + tenths; }
                if (seconds > 9) { appendLog[0].innerHTML = (lap + 1) + '. ' + seconds + ':' + "0" + tenths; }
            }

            if (tenths > 9) {
                if (seconds < 9) { appendLog[0].innerHTML = (lap + 1) + '. ' + "0" + seconds + ':' + tenths; }
                if (seconds > 9) { appendLog[0].innerHTML = (lap + 1) + '. ' + seconds + ':' + tenths; }
            }

            appendLog.reverse();
        }

        lap++;
    };

    buttonReset.onclick = function() {
        clearInterval(Interval);
        tenths = 0;
        seconds = 0;
        appendTens.innerHTML = "00";
        appendSeconds.innerHTML = "00";

        lap = 0;
        var i = 1;
        appendLog.forEach(function(element) {
            element.className = 'log';
            element.innerHTML = i + '. 00:00';
            i++;
        });

        // Apply current class
        appendLog[0].className = appendLog[lap].className + ' ' + 'current';
    };


    function startTimer () {
        var elapsed = window.performance.now() - startTime;
        tenths = parseInt((elapsed % 1000)/10);
        seconds = parseInt(elapsed/1000);



        if (tenths < 9) {
            appendTens.innerHTML = "0" + tenths;
        }

        if (tenths > 9) {
            appendTens.innerHTML = tenths;

        }

        if (seconds < 9) {
            appendSeconds.innerHTML = "0" + seconds;
        }

        if (seconds > 9) {
            appendSeconds.innerHTML = seconds;
        }

    }
}