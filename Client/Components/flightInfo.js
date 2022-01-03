
async function defineFlight(flightInfo, block) {
    var flight = await getFlight(flightInfo);
    insertFlightInfo(flight, block);
    return flight;
}

async function getFlight(flight) {
    if(flight.flight2 === undefined)
        var resp = await fetch(`http://localhost:5000/getFlight?id=${flight.flight}`);
    else
        var resp = await fetch(`http://localhost:5000/getFlight?id=${flight.flight}&id2=${flight.flight2}`);
    let selection = await resp.json();
    return {flight: selection, fare: flight.fare,travelers: flight.travelers};
}

function convertTime(time) {
    var hour = time.getHours();
    var min = time.getMinutes().toString();
    var AmOrPm = hour >= 12 ? 'PM' : 'AM';
    hour = hour % 12;
    if(hour===0)
        hour = 12;
    if(min.length<2)
        min = "0"+min;
    return hour.toString() + ":" + min + AmOrPm;
}

function insertFlightInfo(selection, block) {
    var dateDepart = new Date(selection.flight.scheduled_departure);
    var dateArrive = new  Date(selection.flight.scheduled_arrival);
    var weekday=new Array(7);
    weekday[0]="Sun";
    weekday[1]="Mon";
    weekday[2]="Tues";
    weekday[3]="Wed";
    weekday[4]="Thur";
    weekday[5]="Fri";
    weekday[6]="Sat";
    var month = dateDepart.getMonth()+1;
    var dayOfMonth = dateDepart.getDate();

    var boardTime = convertTime(dateDepart);
    var arriveTime = convertTime(dateArrive);


    block.getElementsByClassName("flightDate")[0].innerHTML = `${weekday[dateDepart.getDay()]} ${month}/${dayOfMonth}`;
    var airportCodes = block.getElementsByClassName("airport-code-bold");
    airportCodes[0].innerHTML = selection.flight.depart;
    airportCodes[1].innerHTML = selection.flight.arrive;
    var times = block.getElementsByClassName("flight-time");
    times[0].innerHTML = boardTime;
    times[1].innerHTML = arriveTime;

    var res = Math.abs(dateArrive - dateDepart) / 1000;
    var hoursBetween = Math.floor(res / 3600) % 24;
    var minutesBetween = Math.floor(res / 60) % 60;
    block.getElementsByClassName("flightTime")[0].innerHTML = selection.flight.duration;

    var connection = block.getElementsByClassName("connection")[0];
    if(selection.flight.conn1 === undefined)
        connection.innerHTML = "Nonstop";
    else
        connection.innerHTML = "1 stop";

    block.getElementsByClassName("fare")[0].innerHTML = selection.fare;


}

function priceInfo(block, flight, type='default') {
    var amount;
    var perPassenger;
    switch(type) {
        //CASE 'default': new flight being selected, get info from new flight
        case 'default':
            var price;
            var priceWithTax;
            switch (flight.fare) {
                case 'Economy':
                    price = flight.flight.econPrice;
                    priceWithTax = flight.flight.econWithTax;
                    break;
                case 'Economy Plus':
                    price = flight.flight.econPlusPrice;
                    priceWithTax = flight.flight.econPlusWithTax;
                    break;
                case 'Business':
                    price = flight.flight.businessPrice;
                    priceWithTax = flight.flight.businessWithTax;
            }
            block.getElementsByClassName("price-per-pass")[0].lastElementChild.innerHTML = "$" + price.toFixed(2);
            block.getElementsByClassName("taxes-per-pass")[0].lastElementChild.innerHTML = "$" + (priceWithTax - price).toFixed(2);
            block.getElementsByClassName("total-per-pass")[0].lastElementChild.innerHTML = "$" + priceWithTax.toFixed(2);
            block.getElementsByClassName("passengers")[0].lastElementChild.innerHTML = "x" + flight.travelers;
            block.getElementsByClassName("flight-total")[0].lastElementChild.innerHTML = "<sup>$</sup>" + (priceWithTax * flight.travelers).toFixed(2);
            break;

        //CASE 'change': flight is being changed, get info from old booking
        case 'change':
            //TODO store taxes separately in db (going backwards isn't entirely accurate)
            amount = JSON.parse(localStorage.getItem("flight")).amount;
            perPassenger = amount / JSON.parse(localStorage.getItem("flight")).travelers;
            block.getElementsByClassName("price-per-pass")[0].lastElementChild.innerHTML = "$" + (perPassenger - (0.0825 * perPassenger)).toFixed(2);
            block.getElementsByClassName("taxes-per-pass")[0].lastElementChild.innerHTML = "$" + (0.0825 * perPassenger).toFixed(2);
            block.getElementsByClassName("total-per-pass")[0].lastElementChild.innerHTML = "$" + perPassenger.toFixed(2);
            block.getElementsByClassName("passengers")[0].lastElementChild.innerHTML = "x" + JSON.parse(localStorage.getItem("flight")).travelers;
            block.getElementsByClassName("flight-total")[0].lastElementChild.innerHTML = "<sup>$</sup>" + amount;
            break;

        case 'cancel':
            //TODO store taxes separately in db (going backwards isn't entirely accurate)
            amount = JSON.parse(localStorage.getItem("flight")).amount;
            perPassenger = amount / JSON.parse(localStorage.getItem("flight")).travelers.length;
            block.getElementsByClassName("price-per-pass")[0].lastElementChild.innerHTML = "$" + (perPassenger - (0.0825 * perPassenger)).toFixed(2);
            block.getElementsByClassName("taxes-per-pass")[0].lastElementChild.innerHTML = "$" + (0.0825 * perPassenger).toFixed(2);
            block.getElementsByClassName("total-per-pass")[0].lastElementChild.innerHTML = "$" + perPassenger.toFixed(2);
            block.getElementsByClassName("passengers")[0].lastElementChild.innerHTML = "x" + JSON.parse(localStorage.getItem("flight")).travelers.length;
            block.getElementsByClassName("flight-total")[0].lastElementChild.innerHTML = "<sup>$</sup>" + amount;
            break;
        case 'cancelConf':
        case 'changeConf':
            amount = JSON.parse(localStorage.getItem("response")).payment.amount;
            perPassenger = amount/JSON.parse(localStorage.getItem("flight")).travelers.length;
            block.getElementsByClassName("price-per-pass")[0].lastElementChild.innerHTML = "$"+(perPassenger-(0.0825*perPassenger)).toFixed(2);
            block.getElementsByClassName("taxes-per-pass")[0].lastElementChild.innerHTML = "$"+(0.0825*perPassenger).toFixed(2);
            block.getElementsByClassName("total-per-pass")[0].lastElementChild.innerHTML = "$"+perPassenger.toFixed(2);
            block.getElementsByClassName("passengers")[0].lastElementChild.innerHTML = "x"+JSON.parse(localStorage.getItem("response")).travelers.length;
            block.getElementsByClassName("flight-total")[0].lastElementChild.innerHTML = "<sup>$</sup>"+amount;
            break;
    }
}
