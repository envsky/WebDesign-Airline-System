
const query = window.location.search;
const urlParams = new URLSearchParams(query);
var from = urlParams.get('from');
var to = urlParams.get('to');
var date = localStorage.getItem("date");
var fare = urlParams.get('fare');
var travelers = urlParams.get('travelers');
if(travelers===null)
    travelers = JSON.parse(localStorage.getItem("flight")).travelers;

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
            travelers: travelers
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

function insertInfo(row, data, isChangeBooking) {
    //Depart time
    var departing = row.insertCell();
    var departTime = new Date(data.scheduled_departure);
    departing.innerHTML = convertTime(departTime);
    //Arrive time
    var arriving = row.insertCell();
    var arriveTime  = new Date(data.scheduled_arrival);
    arriving.innerHTML = convertTime(arriveTime);
    var stops = row.insertCell();
    if(data.conn1 === undefined)
        stops.innerHTML = "Nonstop";
    else
        stops.innerHTML = "1 stop";
    //Flight time

    var flightLength = row.insertCell();
    flightLength.innerHTML = data.duration;
    //Fare pricing
    var economy = row.insertCell();
    economy.classList.add("ecoCol");
    var linkEcon;
    // console.log(data.economy_available);
    if(data.economy_available===0 || data.conn1_economy_available===0) {
        if(isChangeBooking) {
            linkEcon = document.createElement("a");
            linkEcon.href = "./priceReconcile.html";
            linkEcon.innerHTML = "Standby";
            linkEcon.onclick = function() {pickFlight(data, "Economy", true);}
        } else {
            linkEcon = document.createElement("span");
            linkEcon.innerHTML = "Unavailable";
            economy.classList.add("unavailable");
        }
    } else {
        linkEcon = document.createElement("a");
        if(isChangeBooking)
            linkEcon.href = "./priceReconcile.html";
        else
            linkEcon.href = "./price.html";
        linkEcon.onclick = function() {pickFlight(data, "Economy", false);}
        linkEcon.innerHTML = "$"+data.econPrice.toFixed(0);
    }
    economy.appendChild(linkEcon);

    var economyPlus = row.insertCell();
    economyPlus.classList.add("ecoPlusCol");
    var linkEconPlus;
    if(data.economy_plus_available===0 || data.conn1_economy_plus_available===0) {
        if(isChangeBooking) {
            linkEconPlus = document.createElement("a");
            linkEconPlus.href = "./priceReconcile.html";
            linkEconPlus.innerHTML = "Standby";
            linkEconPlus.onclick = function() {pickFlight(data, "Economy Plus", true);}
        } else {
            linkEconPlus = document.createElement("span");
            linkEconPlus.innerHTML = "Unavailable";
            economyPlus.classList.add("unavailable");
        }
    } else {
        linkEconPlus = document.createElement("a");
        if(isChangeBooking)
            linkEconPlus.href = "./priceReconcile.html";
        else
            linkEconPlus.href = "./price.html";
        linkEconPlus.onclick = function() {pickFlight(data, "Economy Plus", false)};
        linkEconPlus.innerHTML = "$"+data.econPlusPrice.toFixed(0);
    }
    economyPlus.appendChild(linkEconPlus);

    var business = row.insertCell();
    business.classList.add("businessCol");
    var linkBusiness;
    if(data.business_available===0 || data.conn1_business_available===0) {
        if(isChangeBooking) {
            linkBusiness = document.createElement("a");
            linkBusiness.href = "./priceReconcile.html";
            linkBusiness.innerHTML = "Standby";
            linkBusiness.onclick = function() {pickFlight(data, "Business", true);}
        } else {
            linkBusiness = document.createElement("span");
            linkBusiness.innerHTML = "Unavailable";
            business.classList.add("unavailable");
        }
    }
    else
    {
        linkBusiness = document.createElement("a");
        if(isChangeBooking)
            linkBusiness.href = "./priceReconcile.html";
        else
            linkBusiness.href = "./price.html";
        linkBusiness.onclick = function() {pickFlight(data, "Business", false)};
        linkBusiness.innerHTML = "$"+data.businessPrice.toFixed(0);
    }
    business.appendChild(linkBusiness);


}

function noFlights() {
    document.getElementsByClassName("container")[1].style.display = "none";
    document.getElementsByClassName("error-text")[0].style.display = "block";
}

function pickFlight(flight, fare, isStandby) {

    var flight_picked = {flight: flight.id, fare: fare};
    //If this is a new booking
    if(localStorage.getItem("changeInfo") === null)
    {
        flight_picked.travelers = travelers;
        flight_picked.isStandby = false;
        if(flight.conn1_id !== undefined)
            flight_picked.flight2 = flight.conn1_id;

        localStorage.setItem("flight", JSON.stringify(flight_picked));
    }
    //Otherwise, it's a change booking
    else
    {
        flight_picked.travelers = JSON.parse(localStorage.getItem("flight")).travelers;
        if(isStandby)
            flight_picked.isStandby=true;
        else
            flight_picked.isStandby=false;
        if(flight.conn1_id !== undefined)
            flight_picked.flight2 = flight.conn1_id;
        localStorage.setItem("newFlight", JSON.stringify(flight_picked));
    }
}

function showFlights() {
    document.getElementsByClassName("container")[1].style.display = "block";
    document.getElementsByClassName("error-text")[0].style.display = "none";
    //Check if this is being called for changing a flight or booking a new one
    // (i.e. check if changeInfo exists in local storage
    var isChangeFlight = false;
    if(localStorage.getItem("changeInfo") !== null)
    {
        var currentFlight = JSON.parse(localStorage.getItem("flight"));
        isChangeFlight = true;
    }

    flights.forEach(function(type, i) {
        type.forEach(function(flight) {
            if(!isChangeFlight || (isChangeFlight && currentFlight.flight !== flight.id))
            {
                var row = table.insertRow();
                //If change flight
                if(isChangeFlight)
                    insertInfo(row, flight, true);
                //Else, it's a new booking
                else
                    insertInfo(row, flight, false);
            }
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