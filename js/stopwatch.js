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
    var buttonReset = document.getElementById('button-reset');
    var buttonRecord = document.getElementById('button-record');
    var Interval ;

    var records = [];
    records.push(document.getElementById('rec-row-1'));
    records.push(document.getElementById('rec-row-2'));
    records.push(document.getElementById('rec-row-3'));
    records.push(document.getElementById('rec-row-4'));

    var recordTable = document.getElementById('record-table');

    buttonStart.onclick = function() {

        clearInterval(Interval);
        Interval = setInterval(startTimer, 10);
    };

    buttonStop.onclick = function() {
        clearInterval(Interval);
    };


    buttonReset.onclick = function() {
        clearInterval(Interval);
        tenths = "00";
        seconds = "00";
        appendTens.innerHTML = tenths;
        appendSeconds.innerHTML = seconds;
    };

    buttonRecord.onclick = function() {
        var i = lap % 4;

        // Update Index
        recordTable.rows[i+1].cells.item(0).innerHTML = (lap+1) + '. ';

        // Update Time
        if (tenths < 9) {
            if (seconds < 9) {
                recordTable.rows[i + 1].cells.item(1).innerHTML = '0' + seconds + ':' + '0' + tenths;
            }
            if (seconds > 9) {
                recordTable.rows[i + 1].cells.item(1).innerHTML = seconds + ':' + '0' + tenths;
            }
        }
        else if (tenths > 9) {
            if (seconds < 9) {
                recordTable.rows[i + 1].cells.item(1).innerHTML = '0' + seconds + ':' + tenths;
            }
            if (seconds > 9) {
                recordTable.rows[i + 1].cells.item(1).innerHTML = seconds + ':' + tenths;
            }
        }



        //if(tenths < 9){
        //    if (seconds < 9){ appendLog[i].innerHTML = (lap+1) + '. ' + "0" + seconds + ':' + "0" + tenths; }
        //    if (seconds > 9){ appendLog[i].innerHTML = (lap+1) + '. ' + seconds + ':' + "0" + tenths; }
        //}
        //
        //if (tenths > 9){
        //    if (seconds < 9){ appendLog[i].innerHTML = (lap+1) + '. ' + "0" + seconds + ':' + tenths; }
        //    if (seconds > 9){ appendLog[i].innerHTML = (lap+1) + '. ' + seconds + ':'  + tenths; }
        //}

        // Update Position
        //debugger
        console.log(this.state.p)
        recordTable.rows[i + 1].cells.item(2).innerHTML = this.state.p;
        //// Remove current class from all
        //appendLog.forEach(function(element) {
        //    element.className = 'log'
        //});
        //// Apply current class
        //appendLog[i].className = appendLog[i].className + ' ' + 'current';

        lap++;
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


}