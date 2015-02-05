/**
 * Created by Haichuan on 11/30/2014.
 */
function activateStopwatch() {
    "use strict";

    var lap = 0;
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

        clearInterval(Interval);
        Interval = setInterval(startTimer, 10);
    };

    buttonStop.onclick = function() {
        clearInterval(Interval);
    };

    buttonLap.onclick = function() {
        var i = lap % 5;
        if(tenths < 9){
            if (seconds < 9){ appendLog[i].innerHTML = (lap+1) + '. ' + "0" + seconds + ':' + "0" + tenths; }
            if (seconds > 9){ appendLog[i].innerHTML = (lap+1) + '. ' + seconds + ':' + "0" + tenths; }
        }

        if (tenths > 9){
            if (seconds < 9){ appendLog[i].innerHTML = (lap+1) + '. ' + "0" + seconds + ':' + tenths; }
            if (seconds > 9){ appendLog[i].innerHTML = (lap+1) + '. ' + seconds + ':'  + tenths; }
        }

        // Remove current class from all
        appendLog.forEach(function(element) {
            element.className = 'log'
        });
        // Apply current class
        appendLog[i].className = appendLog[i].className + ' ' + 'current';

        lap++;
    };

    buttonReset.onclick = function() {
        clearInterval(Interval);
        tenths = "00";
        seconds = "00";
        appendTens.innerHTML = tenths;
        appendSeconds.innerHTML = seconds;

        lap = 0;
        var i = 1;
        appendLog.forEach(function(element) {
            element.innerHTML = i + '. 00:00';
            i++;
        })
    };



    function startTimer () {
        tenths++;

        if(tenths < 9){
            appendTens.innerHTML = "0" + tenths;
        }

        if (tenths > 9){
            appendTens.innerHTML = tenths;

        }

        if (tenths > 99) {
            console.log("seconds");
            seconds++;
            appendSeconds.innerHTML = "0" + seconds;
            tenths = 0;
            appendTens.innerHTML = "0" + 0;
        }

        if (seconds > 9){
            appendSeconds.innerHTML = seconds;
        }

    }

    function writeLap () {

    }

    function clearLaps () {

    }

}