
const queryBank = require('./queryBank');

const calculateFarePrice = (flight) => {
    const economyStarter = 200;
    const economyPlusStarter = 500;
    const businessStarter = 800;
    const currentDate = new Date();
    var timeTillFlight = new Date(flight.scheduled_departure)-currentDate;
    timeTillFlight = Math.pow(timeTillFlight/2000000,2);
    const flightTime = calculateDuration(flight);
    //Formulas to calculate price
    var econPrice = (economyStarter/(Math.log(flightTime)/18))+(100000/timeTillFlight);
    var econPlusPrice = (economyPlusStarter/(Math.log(flightTime)/18))+(100000/timeTillFlight);
    var businessPrice = (businessStarter/(Math.log(flightTime)/18))+(100000/timeTillFlight);

    flight.econPrice = +(econPrice.toFixed(2));
    flight.econPlusPrice = +(econPlusPrice.toFixed(2));
    flight.businessPrice = +(businessPrice.toFixed(2));
    flight.econWithTax = +((econPrice+(0.0825*econPrice)).toFixed(2));
    flight.econPlusWithTax = +((econPlusPrice+(0.0825*econPlusPrice)).toFixed(2));
    flight.businessWithTax = +((businessPrice+(0.0825*businessPrice)).toFixed(2));
};

const calculateDuration = (flight) => {
    var departTime = new Date(flight.scheduled_departure);
    var arriveTime  = new Date(flight.scheduled_arrival);
    var res = Math.abs(arriveTime - departTime) / 1000; //Time between depart and arrive in seconds
    var hoursBetween = Math.floor(res / 3600) % 24;
    var minutesBetween = Math.floor(res / 60) % 60;
    flight.duration = hoursBetween.toString()+"h "+minutesBetween+"m";
    return arriveTime-departTime;
}

const getFlight = async(client,  flightID, flightID2)=> {
    try {
        let flight;
        if(flightID2 === undefined)
            flight = await queryBank.directFlights(client, 'one', {flightID: flightID});
        else
            flight = await queryBank.connectionFlights(client, 'one', {flightID: flightID, flightID2: flightID2});
        calculateDuration(flight);
        calculateFarePrice(flight);
        return flight;
    }
    catch (err) {
        console.log(err.message);
    }
}

const priceDiff = async(client, query, type)=> {
    //TODO potential security issue here, get booking for amount instead of from query
    var priceDiff;
    var refund = false;
    var response = {};
    switch(type)
    {
        case 'change':
            const newFl = await getFlight(client, query.newFlight.flight, query.newFlight.flight2);

            var price;
            var priceWithTax;
            switch(query.newFlight.fare)
            {
                case 'Economy':
                    price = newFl.econPrice;
                    priceWithTax = newFl.econWithTax;
                    break;
                case 'Economy Plus':
                    price = newFl.econPlusPrice;
                    priceWithTax = newFl.econPlusWithTax;
                    break;
                case 'Business':
                    price = newFl.businessPrice;
                    priceWithTax = newFl.businessWithTax;
            }
            priceDiff = (priceWithTax*query.newFlight.travelers-query.oldFlight.amount);
            if(priceDiff<0)
                refund = true;
            break;
        //USES oldFlight, travelersCancel
        case 'cancel':

            var pricePerPass = query.oldFlight.amount/query.oldFlight.travelers.length;
            priceDiff = pricePerPass*query.travelersCancel.length;

            response.newTotal = query.oldFlight.amount-priceDiff;

    }
    response.priceDiff = priceDiff.toFixed(2);
    response.refund = refund;
    return response;
}

const generateBookRef = async(length) => {
    while(true) {
    var chars = '0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ';
    var result = '';
    for (var i = length; i > 0; --i) result += chars[Math.round(Math.random() * (chars.length - 1))];
    var response = await queryBank.checkBookRefUniqueness(result);
    if(response === 0)
        break;
    }
    return result;
}

module.exports = {calculateFarePrice, calculateDuration, generateBookRef, getFlight, priceDiff};

