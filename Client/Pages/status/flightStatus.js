
const query = window.location.search;
const urlParams = new URLSearchParams(query);
var from = urlParams.get('from');
var to = urlParams.get('to');
var date = localStorage.getItem("date");
var flightNum = urlParams.get('flightNum');
let flights = [];
let table = document.getElementById("flightsTable").getElementsByTagName('tbody')[0];

document.getElementById("depart").innerHTML = from;
document.getElementById("arrive").innerHTML = to;
getCities(from)
    .then((value)=>document.getElementById("departCity").innerHTML = value);
getCities(to)
    .then((value)=>document.getElementById("arriveCity").innerHTML = value);
initialDateInsert();
findFlights();

function initialDateInsert() {
    var year = date.substr(0,4);
    var month = date.substr(5,2);
    var day = date.substr(8);
    document.getElementById("date").value = `${month}/${day}/${year}`;
}

function changeDate() {
    date = document.getElementById("alt-date").value;
    while (table.childNodes.length > 2) {
        table.removeChild(table.lastChild);
    }
    findFlights();
}

async function getCities(airportCode) {
    try {
        const response = await fetch(`http://localhost:5000/city?airport_code=${airportCode}`);
        return await response.json();
    } catch(err) {
        console.log(err.message);
    }
}
async function findFlights() {
    try {
        const response = await fetch("http://localhost:5000/findFlights/?"+$.param({
            from: from,
            to: to,
            date: date,
            flightNum: flightNum,
            travelers: 1
        }));
        let resp = await response.json();
        flights = resp;
        if(flights[0].length === 0 && flights[1].length === 0) {
            noFlights();
            return;
        }
        showFlights();
    }
    catch (err) {
        console.log(err.message);
    }
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
function insertFlightNode(row, time, airport) {
    var cell = row.insertCell();
    cell.classList.add("flight-node");
    var givenTime = document.createElement("DIV");
    givenTime.innerHTML = time;
    var givenAirport = document.createElement("DIV");
    givenAirport.innerHTML = airport;
    cell.appendChild(givenTime);
    cell.appendChild(givenAirport);
}

function insertInfo(row, data) {
    var flightID = row.insertCell();
    flightID.innerHTML = data.id;

    //Depart time
    var departTime = convertTime(new Date(data.scheduled_departure));
    insertFlightNode(row, departTime, data.depart);

    var status =  row.insertCell();
    status.innerHTML = data.depart_flight_status;
    if(data.depart_flight_status === "Scheduled")
        status.style.color = "green";
    else if(data.depart_flight_status === "Delayed")
        status.style.color = "yellow";
    //Arrive time
    var arriveTime;
    if(data.conn1 === undefined) {
        arriveTime  = convertTime(new Date(data.scheduled_arrival));
        insertFlightNode(row, arriveTime, data.arrive);
    }
    else {
        arriveTime = convertTime(new Date(data.initial_scheduled_arrival));
        insertFlightNode(row, arriveTime, data.conn1);
    }

    if(data.conn1 !== undefined)
    {
        var connectingFlight = table.insertRow();
        insertInfo(connectingFlight, {
            id: data.conn1_id,
            scheduled_departure: data.conn1_scheduled_departure,
            scheduled_arrival: data.scheduled_arrival,
            depart_city: data.conn1_city,
            depart_flight_status: data.conn1_flight_status,
            depart: data.conn1,
            arrive_city: data.arrive_city,
            arrive: data.arrive,
        });
        connectingFlight.style.borderTop = "gray dotted 2px";
        row.style.backgroundColor = "#f7f7f7";
        connectingFlight.style.backgroundColor = "#f7f7f7";
    }

}

function noFlights() {
    document.getElementsByClassName("container")[1].style.display = "none";
    document.getElementsByClassName("error-text")[0].style.display = "block";
}

function pickFlight(flight, fare) {
    var flight_picked = {"flight":flight.id, "fare":fare, "travelers": travelers};
    if(flight.conn1_id !== undefined)
        flight_picked.flight2 = flight.conn1_id;
    localStorage.setItem("flight", JSON.stringify(flight_picked));
}

function showFlights() {
    document.getElementsByClassName("container")[1].style.display = "block";
    document.getElementsByClassName("error-text")[0].style.display = "none";
    flights.forEach(function(type, i) {
        type.forEach(function(flight) {
            var row = table.insertRow();
            insertInfo(row, flight);
        });
    });
}

$(document).ready(()=>{
    var today = new Date();
    var max = new Date();
    max.setDate(max.getDate()+61);
    $('#date').datepicker({
    dateFormat: "mm/dd/yy",
    minDate: today,
    maxDate: max,
    altFormat: "yy-mm-dd",
    altField: "#alt-date"
})});