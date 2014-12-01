/**
 * Created by Haichuan on 11/30/2014.
 */
window.onload = function () {

    var seconds = 00;
    var tenths = 00;
    var appendTens = document.getElementById("tenths")
    var appendSeconds = document.getElementById("seconds")
    var buttonStart = document.getElementById('button-start');
    var buttonStop = document.getElementById('button-stop');
    var buttonReset = document.getElementById('button-reset');
    var Interval ;

    buttonStart.onclick = function() {

        clearInterval(Interval);
        Interval = setInterval(startTimer, 10);
    }

    buttonStop.onclick = function() {
        clearInterval(Interval);
    }


    buttonReset.onclick = function() {
        clearInterval(Interval);
        tenths = "00";
        seconds = "00";
        appendTens.innerHTML = tenths;
        appendSeconds.innerHTML = seconds;
    }



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