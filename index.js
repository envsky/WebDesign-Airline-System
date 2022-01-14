const express = require('express');
const app = express();
const pool = require('./db');
const cors = require('cors');
const processing = require('./processing');
const queryBank = require('./queryBank');
const fakeBooking = require('./performBookings');


// middleware
app.use(cors());
app.use(express.json());      //req.body

//ROUTES
app.get('/', (request, response) => {
	response.sendFile('Client/Pages/airlineweb.html', { root: __dirname });
});

app.get('/city', async(req, res)=>{
    try {
        pool.query("SET SCHEMA 'public';");
        const code = req.query.airport_code;
        const city = await queryBank.cities('one',code);
        res.json(city);
    } catch(err) {
        console.log(err.message);
    }
});

app.get('/admin/flightInfo', async(req, res)=> {
    try {
        let info;
        if(req.query.flightID !== '')
             info = await queryBank.getStandby(req.query.flightID);
        if(info===undefined)
            res.sendStatus(404);
        else
            res.status(200).json(info);

    } catch(err) {
        console.log(err.message);
    }
})

app.post('/fakeBookings', async(req, res)=> {
    try {
        let numOfBookings = req.body.numOfBookings;
        let status = await fakeBooking.bookingStart(numOfBookings);
        res.sendStatus(status);
    } catch(err) {
        console.log(err.message);
    }
});

app.get('/cities', async(req, res)=>{
    try {
        pool.query("SET SCHEMA 'public';");
        const allCities = await queryBank.cities('all');
        res.json(allCities);
    }
    catch(err) {
        console.log(err.message);
    }
});



app.get('/findFlights', async(req, res)=>{
    try{
        pool.connect(async(err, client, done) => {
            client.query("SET SCHEMA 'public';");
            const args = [req.query.from, req.query.to, req.query.date.toString(), req.query.travelers];
            const directFlights = await queryBank.directFlights(client, 'all',
                {from: args[0], to: args[1], date: args[2], travelers: args[3]});

            const oneStopFlights = await queryBank.connectionFlights(client, 'all',
                {from: args[0], to: args[1], date: args[2], travelers: args[3]});

            const allFlights = [directFlights, oneStopFlights];

            allFlights.forEach(function (type) {
                type.forEach(function (flight) {
                    processing.calculateDuration(flight);
                    processing.calculateFarePrice(flight);
                });
            });
            done();
            res.json(allFlights);
        });
    }
    catch(err){
        console.log(err.message);
    }
});

app.get('/getFlight', async(req, res)=> {
    try
    {
        pool.connect(async(err, client, done) => {
            client.query("SET SCHEMA 'public';");
            const flight = await processing.getFlight(client, req.query.id, req.query.id2);
            done();
            res.json(flight);
        });
    }
    catch(err){
        console.log(err.message);
    }
});

app.get('/priceDiff', async(req, res)=> {
    try {
        pool.connect(async(err, client, done) => {
            client.query("SET SCHEMA 'public';");
            var priceDiff = await processing.priceDiff(client, req.query, req.query.type);
            done();
            res.json(priceDiff);
        });

    } catch(err) {
        console.log(err.message);
    }
})

app.get('/booking', async(req, res)=> {
    try {
        let flight;
        pool.connect(async(err, client, done) => {
            client.query("SET SCHEMA 'public';");
            flight = await queryBank.getBooking(client, req.query.bookRef, req.query.type);
            done();
            if(flight === undefined)
                res.sendStatus(404);
            else {
                res.status(200).json(flight);
            }
        });
    } catch(err) {
        console.log(err.message);
    }
})

app.post('/purchase', async(req, res)=>{
    try
    {
        pool.connect(async(err, client, done) => {
            client.query("SET SCHEMA 'public';");
            const flight = await processing.getFlight(client, req.body.flight.flight, req.body.flight.flight2);

            const passengerInfo = req.body.passengerInfo;
            const contactInfo = req.body.contactInfo;
            const paymentInfo = req.body.paymentInfo;

            var price;
            var priceWithTax;
            var amount;
            var fare;
            var indirect = (flight.conn1_id !== undefined);

            switch (req.body.flight.fare) {
                case 'Economy':
                    price = flight.econPrice;
                    priceWithTax = flight.econWithTax;
                    fare = "economy";
                    break;
                case 'Economy Plus':
                    price = flight.econPlusPrice;
                    priceWithTax = flight.econPlusWithTax;
                    fare = "economy_plus";
                    break;
                case 'Business':
                    price = flight.businessPrice;
                    priceWithTax = flight.businessWithTax;
                    fare = "business";
                    break;
            }
            //Check availability of flight(s)
            var available = await queryBank.checkAvailability(fare, flight.id, req.body.flight.travelers);
            if (indirect)
                available = await queryBank.checkAvailability(fare, flight.conn1_id, req.body.flight.travelers);

            if (available) {
                var bookRef = await processing.generateBookRef(6);
                amount = (priceWithTax * req.body.flight.travelers).toFixed(2);

                while (true) {
                    try {
                        //Start transaction query
                        await queryBank.transactionStatus(client, "start");

                        //If credit card is not already on file, put it in database
                        await queryBank.postCreditCard(client, paymentInfo.cardNum, paymentInfo.nameOnCard,
                            paymentInfo.expMonth, paymentInfo.expYear);

                        //Insert transaction into database and return transaction ID
                        await queryBank.postBooking(client, bookRef, paymentInfo.cardNum, null, amount, contactInfo.email, contactInfo.phone);

                        //If travelers not already on file, put in database and return passenger ID
                        //For each traveler, create ticket for flight(s)
                        for (var i = 0; i < req.body.flight.travelers; i++) {
                            var passID = await queryBank.postPassenger(client, passengerInfo[i].first_name, passengerInfo[i].last_name, passengerInfo[i].date_of_birth);
                            var ticket;
                            if (indirect)
                                ticket = await queryBank.postTicket(client, bookRef, flight.conn1_id, passID, req.body.flight.fare);

                            await queryBank.postTicket(client, bookRef, flight.id, passID, req.body.flight.fare, ticket);


                        }
                        await queryBank.transactionStatus(client, "commit");
                        done();
                        break;
                    } catch (err) {
                        await queryBank.transactionStatus(client, "rollback");
                        console.log(err.message);
                    }
                }
                //Transaction successful, return connection to pool

                res.status(200).json({
                    bookRef: bookRef,
                    travelers: passengerInfo,
                    payment:
                        {
                            cardLastFour: paymentInfo.cardNum.toString().substr(12),
                            amount: amount
                        }
                });
            } else
                res.sendStatus(403);
        });

    } catch(err) {
        console.log(err.message);
    }
});

app.put('/purchase', async(req, res)=> {
    try {
        pool.connect(async(err, client, done) => {
            client.query("SET SCHEMA 'public';");
            const booking = await queryBank.getBooking(client, req.body.bookRef, 'all');
            const oldFlight = await processing.getFlight(client, req.body.oldFlight.flight, req.body.oldFlight.flight2);
            const newFlight = await processing.getFlight(client, req.body.newFlight.flight, req.body.newFlight.flight2);
            const priceDiff = await processing.priceDiff(client, req.body, 'change');
            const isStandby = req.body.newFlight.isStandby;

            var response = {};
            var indirect = (oldFlight.conn1_id !== undefined);
            var newIndirect = (newFlight.conn1_id !== undefined);
            var newFare;
            while (true) {
                try {
                    //Start transaction query
                    await queryBank.transactionStatus(client, "start");
                    //Change amount of booking

                    if (isStandby) {
                        response.standbyPosition = await queryBank.postStandby(client, newFlight.id, req.body.bookRef, newFlight.fare);
                    } else {
                        //If a refund, the price diff is negative, so the right amount is put each time
                        await queryBank.putBookingAmount(client, req.body.bookRef,
                            parseFloat(booking.amount) + parseFloat(priceDiff.priceDiff));

                        //For each passenger, update tickets
                        for (var i = 0; i < booking.travelers.length; i++) {
                            var tickets = await queryBank.getAllTickets(client, req.body.bookRef, booking.travelers[i].id);
                            //CASE 1: Both are indirect
                            if (indirect && newIndirect) {
                                await queryBank.updateTicket(client, tickets[0].id, newFlight.id, req.body.newFlight.fare);
                                await queryBank.updateTicket(client, tickets[1].id, newFlight.conn1_id, req.body.newFlight.fare);
                            } else if (!indirect && newIndirect) {
                                //CASE 2: Old is direct, new is indirect
                                var ticketID = await queryBank.updateTicket(client, tickets[0].id, newFlight.conn1_id, req.body.newFlight.fare);
                                await queryBank.postTicket(client, req.body.bookRef, newFlight.id, booking.travelers[i].id, req.body.newFlight.fare, ticketID);
                            } else if (indirect && !newIndirect) {
                                //CASE 3: Old is indirect, new is direct
                                await queryBank.updateTicket(client, tickets[1].id, newFlight.id, req.body.newFlight.fare);
                                await queryBank.deleteTicket(client, tickets[0].id);
                            } else {
                                //CASE 4: Both are direct
                                await queryBank.updateTicket(client, tickets[0].id, newFlight.id, req.body.newFlight.fare);
                            }

                        }
                    }

                    await queryBank.transactionStatus(client, "commit");
                    done();
                    break;
                } catch (err) {
                    await queryBank.transactionStatus(client, "rollback");
                    console.log(err.message);
                }
            }

            const newBooking = await queryBank.getBooking(client, req.body.bookRef, 'all');

            res.status(200).json({
                travelers: newBooking.travelers,
                payment:
                    {
                        cardLastFour: newBooking.cardLastFour,
                        amount: newBooking.amount
                    }
            });
        });
    } catch(err) {
        console.log(err.message);
    }
})

app.delete('/purchase', async(req, res) => {
    //IN req.body WE HAVE: bookRef, oldFlight, travelersCancel
    try {

        pool.connect(async(err, client, done) => {
            client.query("SET SCHEMA 'public';");
            var booking = await queryBank.getBooking(client, req.body.bookRef, 'all');
            while (true) {
                try {
                    var response;
                    await queryBank.transactionStatus(client,"start");
                    /*
                    IF FULL CANCELLATION: delete from booking and passenger, check credit card
                    Deletions will cascade to ticket, cargo, and standby
                     */
                    if (booking.travelers.length === req.body.travelersCancel.length) {
                        await queryBank.deleteBooking(client, req.body.bookRef);
                        for (i = 0; i < booking.travelers.length; i++) {
                            await queryBank.deletePassenger(client, req.body.travelersCancel[i]);
                        }
                        await queryBank.transactionStatus(client,"commit");
                        response = {
                            type: 'fullDelete'
                        }
                        break;
                    }
                    /*
                    IF PARTIAL CANCELLATION: delete from passenger for specific passengers and update booking amount
                    Deletions will cascade to ticket, cargo, and standby
                     */
                    else {
                        //Get the tickets for each passenger on the booking that is canceling, and delete their ticket
                        for (i = 0; i < req.body.travelersCancel.length; i++) {
                            await queryBank.deletePassenger(client, req.body.travelersCancel[i]);
                        }
                        var priceDiff = await processing.priceDiff(client, req.body, 'cancel');
                        await queryBank.putBookingAmount(client, req.body.bookRef,
                            parseFloat(booking.amount) - parseFloat(priceDiff.priceDiff));

                        await queryBank.transactionStatus(client, "commit");


                        const newBooking = await queryBank.getBooking(client, req.body.bookRef, 'all');
                        response = {
                            type: 'partialDelete',
                            travelers: newBooking.travelers,
                            payment: {
                                cardLastFour: newBooking.cardLastFour,
                                amount: newBooking.amount
                            }
                        };
                        break;
                    }
                } catch (err) {
                    await queryBank.transactionStatus(client,"rollback");
                    console.log(err.message);
                }
            }
            res.status(200).json(response);
            done();
        });
    } catch(err) {
        res.sendStatus(500);
        console.log(err.message);
    }
});

app.put('/checkIn', async(req, res)=> {
    try {
        pool.connect(async(err, client, done) => {
            client.query("SET SCHEMA 'public';");
            var valid = await queryBank.validBookRef(client, req.body.bookRef);
            if (valid) {
                await queryBank.checkIn(client, req.body.bookRef);
                await queryBank.addCargo(client, req.body.bookRef, req.body.numBag);
                res.sendStatus(200);
            }
            else
                res.sendStatus(403);
            done();
        });
    } catch(err) {
        console.log(err.message);
        res.sendStatus(403);
    }
})

if (process.env.NODE_ENV === 'production') {
	app.use(express.static('Client/Pages'));
}

// set up the server listening at port 5000 (the port number can be changed)
app.listen(process.env.PORT || 5000, ()=>{});