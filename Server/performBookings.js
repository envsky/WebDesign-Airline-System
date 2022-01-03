const fetch = require("node-fetch");
var fakerator = require("fakerator")("en-EN");

const fares = ["Economy", "Economy Plus", "Business"];
let cities = [];
const getCities = async() =>{
    try {
        const response = await (await fetch('http://localhost:5000/cities')).json();
        cities = response.map(city=>{return city.airport_code});
    }
    catch(err) {
        console.log(err.message);
    }
}

function randomDate(start, end) {
    return new Date(start.getTime() + Math.random() * (end.getTime() - start.getTime()));
}
function randomNumbers(length) {
    var result           = '';
    var characters       = '0123456789';
    var charactersLength = characters.length;
    for ( var i = 0; i < length; i++ ) {
        result += characters.charAt(Math.floor(Math.random() * charactersLength));
    }
    return result;
}

async function purchases(numOfBookings) {
    try {
        for(let i=0; i< numOfBookings; i++)
        {
            while(true)
            {
                var from = cities[Math.floor(Math.random()*cities.length)];
                var to = cities[Math.floor(Math.random()*cities.length)];
                var response = await (await fetch(`http://localhost:5000/findFlights?from=${from}&to=${to}&date=2020-12-11&travelers=1`)).json();

                if(response[0].length > 0 && response[1].length > 0)
                {
                    var index = Math.round(Math.random());
                    var flightType = response[index];
                    var randomFlight = response[index][Math.floor(Math.random() * flightType.length)];
                    var fare = fares[Math.floor(Math.random()*3)];
                    var travelerCount = Math.round(Math.random()*(5-1)+1);
                    var travelers = [];
                    var primaryTraveler = fakerator.names.firstName();
                    var lastName = fakerator.names.lastName();
                    travelers.push({
                        first_name: primaryTraveler,
                        last_name: lastName,
                        date_of_birth: randomDate(new Date(1961, 0, 1), new Date())
                    });
                    for(let i=1;i<travelerCount;i++)
                    {
                        travelers.push({
                            first_name: fakerator.names.firstName(),
                            last_name: lastName,
                            date_of_birth: randomDate(new Date(1961, 0, 1), new Date())
                        });
                    }
                    var flight = {
                        flight: randomFlight.id,
                        fare: fare,
                        travelers: travelerCount
                    }
                    if(randomFlight.conn1_id !== undefined)
                        flight.flight2 = randomFlight.conn1_id;

                    await fetch("http://localhost:5000/purchase",
                        {method: "POST",
                            headers: {"Content-Type": "application/json"},
                            body: JSON.stringify({
                                flight: flight,
                                passengerInfo: travelers,
                                contactInfo: {
                                    email: primaryTraveler.toLowerCase()+"."+lastName.toLowerCase()+"@postgres.com",
                                    phone: randomNumbers(10)
                                },
                                paymentInfo: {
                                    cardNum: randomNumbers(16),
                                    nameOnCard: primaryTraveler+" "+lastName,
                                    expMonth: Math.floor(Math.random()*12),
                                    expYear: Math.floor(Math.random() * (2040 - 2022) + 2022)
                                }
                            })});
                    break;
                }
            }
        }
        return 200;
    } catch(err) {
        console.log(err.message);
    }
}

const bookingStart = async(numOfBookings) => {
    try {
        await getCities();
        return await purchases(numOfBookings);
    } catch(err) {
        console.log(err.message);
    }
}

module.exports = {bookingStart};

