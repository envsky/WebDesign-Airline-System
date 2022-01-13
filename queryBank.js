const { response } = require('express');
const pool = require('./db');




const transactionStatus = async(client, status) => {
    switch (status){
        case "start":
        {

            await client.query(`BEGIN TRANSACTION ISOLATION LEVEL SERIALIZABLE;`);
            break;
        } 
        case "commit":
        {
            await client.query(`COMMIT;`);
            break;
        }
        case "rollback":
        {
            await client.query(`ROLLBACK;`);
            break;
        }
    }
}
//TYPE can be either 'all' or 'one'
//IF 'all', args={to:<>, from:<>, date:<>}
//IF 'one', args={flightID:<>}
const directFlights = async(client, type, args) => {
    try
    {
        var response;
        var base =
            `SELECT departing.id, scheduled_departure, scheduled_arrival, departing.city AS depart_city,
            departing.flight_status AS depart_flight_status, departing.economy_available, departing.economy_plus_available,
            departing.business_available, departing.airport_code AS depart,
            arriving.city AS arrive_city, arriving.airport_code AS arrive
        FROM
            (SELECT id,scheduled_departure, scheduled_arrival, city, airport_code, flight_status, economy_available, economy_plus_available, business_available
            FROM flight JOIN airport
            ON flight.departure_airport=airport.airport_code) departing
        JOIN
            (SELECT id, city, airport_code
            FROM flight JOIN airport
            ON flight.arrival_airport=airport.airport_code) arriving
        ON departing.id=arriving.id`;

        switch(type)
        {
            case "all":
                response = await client.query(
                    `${base}
            WHERE departing.airport_code LIKE $1 AND arriving.airport_code LIKE $2
            AND scheduled_departure::text LIKE $3
            AND (departing.economy_available>=$4
                OR departing.economy_plus_available>=$4
                OR departing.business_available>=$4)
            ORDER BY scheduled_departure ASC;`,
                    [args.from, args.to, args.date+' %', args.travelers]);
                return response.rows;
            case "one":
                response = await client.query(
                    `${base}
            WHERE departing.id=$1;`, [args.flightID]);
                return response.rows[0];
        }
    } catch(err) {
        console.log(err.message);
    }
}

//TYPE can be either 'all' or 'one'
//IF 'all', args={to:<>, from:<>, date:<>}
//IF 'one', args={flightID:<>, flightID2:<>}
const connectionFlights = async(client, type, args)  => {
    try
    {
        var response;
        var base =
            `SELECT departing.id,
                departing.scheduled_departure AS scheduled_departure,
                departing.scheduled_arrival AS initial_scheduled_arrival,
                departing.city AS depart_city,
                departing.flight_status AS depart_flight_status,
                departing.economy_available AS economy_available,
                departing.economy_plus_available AS economy_plus_available,
                departing.business_available AS business_available,
                departing.airport_code AS depart,
                connection1Departing.scheduled_departure AS conn1_scheduled_departure,
                connection1Departing.scheduled_arrival AS scheduled_arrival, 
                connection1.city AS conn1_city,
                connection1Departing.economy_available AS conn1_economy_available,
                connection1Departing.economy_plus_available AS conn1_economy_plus_available,
                connection1Departing.business_available AS conn1_business_available,
                connection1.airport_code AS conn1,
                connection1Departing.flight_status AS conn1_flight_status,
                connection1Departing.id AS conn1_id,
                arriving.city AS arrive_city,
                arriving.airport_code AS arrive
            FROM
                (SELECT id,scheduled_departure, scheduled_arrival, city, airport_code, flight_status,
                        economy_available, economy_plus_available, business_available
                 FROM flight JOIN airport
                                   ON flight.departure_airport=airport.airport_code) departing
                    JOIN
                (SELECT id, city, airport_code
                 FROM flight JOIN airport
                                   ON flight.arrival_airport=airport.airport_code) connection1
                ON departing.id=connection1.id
                    JOIN
                ((SELECT id, scheduled_departure, scheduled_arrival, city, airport_code, flight_status,
                         economy_available, economy_plus_available, business_available
                 FROM flight JOIN airport
                                   ON flight.departure_airport=airport.airport_code) connection1Departing
                    JOIN
                (SELECT id, city, airport_code
                 FROM flight JOIN airport
                                   ON flight.arrival_airport=airport.airport_code) arriving
                ON connection1Departing.id=arriving.id)
                ON connection1.airport_code=connection1Departing.airport_code`;

        switch(type)
        {
            case "all":
                response = await client.query(
                    `${base}
            WHERE connection1Departing.scheduled_departure > departing.scheduled_arrival
            AND departing.airport_code LIKE $1 AND arriving.airport_code LIKE $2
            AND departing.scheduled_departure::text LIKE $3
            AND connection1Departing.scheduled_departure::text LIKE $3
            AND ((departing.economy_available>=$4 AND connection1Departing.economy_available>=$4)
                OR (departing.economy_plus_available>=$4 AND connection1Departing.economy_plus_available>=$4)
                OR (departing.business_available>=$4 AND connection1Departing.business_available>=$4))
            ORDER BY departing.scheduled_departure ASC;`,
                    [args.from, args.to, args.date+' %', args.travelers]);
                return response.rows;
            case "one":
                response = await client.query(
                    `${base}
            WHERE departing.id=$1
            AND connection1Departing.id=$2;`,
                    [args.flightID, args.flightID2]);
                return response.rows[0];
        }
    } catch(err) {
        console.log(err.message);
    }
}

const cities = async(type, code=null) => {
    try
    {
        await pool.query("SET SCHEMA 'public';");
        var response;
        switch(type)
        {
            case 'all':
                response = await pool.query('SELECT DISTINCT city, airport_code FROM airport;');
                return response.rows;
            case 'one':
                response = await pool.query('SELECT city FROM airport WHERE airport_code LIKE $1;', [code]);
                return response.rows[0].city;
        }
    } catch(err) {
        console.log(err.message);
    }
}

const getStandby = async(flightID) => {
    try {
        await pool.query("SET SCHEMA 'public';");
        let standby = await pool.query(
            `SELECT * FROM standby
            WHERE flight_id=$1
            ORDER BY position;`,
            [flightID]);
        return standby.rows;
    } catch(err) {
        console.log(err.message);
    }
}

const getBooking = async(client, bookRef, type) => {
    try {
        var response;
        var passengers;
        var cardLastFour;
        switch(type)
        {
            case 'passengerCount':
                passengers = await client.query(
                    `SELECT COUNT(DISTINCT passenger.id)
                    FROM booking
                    JOIN ticket
                        ON booking.book_ref=ticket.book_ref
                    JOIN passenger
                        ON passenger.id=ticket.passenger_id
                    WHERE booking.book_ref LIKE $1;`,
                                [bookRef]);
                passengers = passengers.rows[0].count;
                break;
            case 'all':
                passengers = await client.query(
                    `SELECT DISTINCT passenger.id, first_name, last_name, date_of_birth
                    FROM booking
                    JOIN ticket
                        ON booking.book_ref=ticket.book_ref
                    JOIN passenger
                        ON passenger.id=ticket.passenger_id
                    WHERE booking.book_ref LIKE $1;`,
                                [bookRef]);
                passengers = passengers.rows;
            case 'cardNumber':
                var cardNumber = await client.query(
                    `SELECT credit_card.card_number
                    FROM booking
                    JOIN credit_card
                        ON booking.card_number = credit_card.card_number
                    WHERE booking.book_ref LIKE $1;`,
                    [bookRef]);
                cardLastFour = cardNumber.rows[0].card_number.toString().substr(12);
        }
        var flight = await client.query(
            `WITH RECURSIVE tab AS (
                (SELECT amount, t.book_ref, id, flight_id, fare_condition, connecting_ticket
                 FROM ticket t
                          JOIN booking ON t.book_ref=booking.book_ref
                 WHERE t.book_ref=$1
                 ORDER BY connecting_ticket ASC
                 LIMIT 1)
                UNION ALL

                SELECT amount, t.book_ref, t.id, t.flight_id, t.fare_condition, t.connecting_ticket
                FROM ticket t
                         JOIN
                     tab
                     ON tab.connecting_ticket=t.id)
             SELECT amount, id, flight_id, fare_condition, connecting_ticket FROM tab;`,
            [bookRef]);
        try {
            response = {
                flight: flight.rows[0].flight_id,
                fare: flight.rows[0].fare_condition,
                travelers: passengers,
                amount: flight.rows[0].amount,
                cardLastFour: cardLastFour
            };
        } catch(err) {
            return undefined;
        }
        if(flight.rows[1] !== undefined)
            response.flight2 = flight.rows[1].flight_id;
        return response;

    } catch(err) {
        console.log(err.message);
    }
}

const checkAvailability = async(fare, flightID, travelers) => {
    var response;
    switch(fare)
    {
        case "economy":
        case "Economy":
            response = await pool.query(
                `SELECT
                CASE WHEN economy_available<$1
                    THEN FALSE
                ELSE TRUE
                END
            FROM flight WHERE id=$2;`,
                [travelers, flightID]);
            break;
        case "economy_plus":
        case "Economy Plus":
            response = await pool.query(
                `SELECT
                CASE WHEN economy_plus_available<$1
                    THEN FALSE
                ELSE TRUE
                END
            FROM flight WHERE id=$2;`,
                [travelers, flightID]);
            break;
        case "business":
        case "Business":
            response = await pool.query(
                `SELECT
                CASE WHEN business_available<$1
                    THEN FALSE
                ELSE TRUE
                END
            FROM flight WHERE id=$2;`,
                [travelers, flightID]);
            break;
    }
    return response.rows[0].case;
}

const postCreditCard = async(client, cardNum, nameOnCard, expMonth, expYear) => {
    await client.query(
        `INSERT INTO credit_card VALUES ($1, $2, $3, $4) ON CONFLICT(card_number) DO NOTHING;`,
        [cardNum, nameOnCard, expMonth, expYear]);
}

const postBooking = async(client, bookRef, cardNum, discount, amount, contactEmail, contactPhone) => {
    const response = await client.query(
        `INSERT INTO booking (book_ref, card_number, discount_code, amount, contact_email, contact_phone_number, booking_date)
        VALUES ($1, $2, $3, $4, $5, $6, CURRENT_TIMESTAMP);`,
        [bookRef, cardNum, discount, amount, contactEmail, contactPhone]);
}

const postPassenger = async(client, firstName, lastName, date_of_birth) => {
    const response = await client.query(
        `INSERT INTO passenger (first_name, last_name, date_of_birth)
            VALUES ($1, $2, $3) RETURNING id;`,
        [firstName, lastName, date_of_birth]);
    return response.rows[0].id;
}

const postTicket = async(client, bookRef, flightID, passID, fare, connectingTicket=null) => {
    try {
        var ticket = await client.query(
            `INSERT INTO ticket (book_ref, flight_id, passenger_id, fare_condition, connecting_ticket)
            VALUES ($1, $2, $3, $4, $5) RETURNING id;`,
            [bookRef, flightID, passID, fare, connectingTicket]);
        await postSeat(client, fare, flightID, 1);
        return ticket.rows[0].id;
    } catch(err) {
        console.log(err.message);
    }
}

const postSeat = async(client, fare, flightID, travelers) => {
    switch (fare){
        case "Economy":
            await client.query(
                `UPDATE flight
                    SET economy_booked=economy_booked+$1,
                        economy_available=economy_available-$1
                    WHERE id=$2;`,
                    [travelers, flightID]);
            break;
        case "Economy Plus":
            await client.query(
                `UPDATE flight
                    SET economy_plus_booked=economy_plus_booked+$1,
                        economy_plus_available=economy_plus_available-$1
                    WHERE id=$2;`,
                    [travelers, flightID]);
            break;
        case "Business":
            await client.query(
                `UPDATE flight
                    SET business_booked=business_booked+$1,
                        business_available=business_available-$1
                    WHERE id=$2;`,
                    [travelers, flightID]);
            break;
    }
}

const removeSeat = async(client, fare, flightID, travelers) => {
    try {
        switch (fare){
            case "Economy":
                await client.query(
                    `UPDATE flight
                    SET economy_booked=economy_booked-$1,
                        economy_available=economy_available+$1
                    WHERE id=$2;`,
                    [travelers, flightID]);
                break;
            case "Economy Plus":
                await client.query(
                    `UPDATE flight
                    SET economy_plus_booked=economy_plus_booked-$1,
                        economy_plus_available=economy_plus_available+$1
                    WHERE id=$2;`,
                    [travelers, flightID]);
                break;
            case "Business":
                await client.query(
                    `UPDATE flight
                    SET business_booked=business_booked-$1,
                        business_available=business_available+$1
                    WHERE id=$2;`,
                    [travelers, flightID]);
                break;
        }
    } catch(err) {
        console.log(err.message);
    }
}

const putBookingAmount = async(client, bookRef, newAmount) => {
    try {
        await client.query(
            `UPDATE booking
                SET amount=$1
            WHERE book_ref LIKE $2;`,
            [newAmount, bookRef]);
    } catch(err) {
        console.log(err.message);
    }
}

const getAllTickets = async(client, bookRef, passengerID) => {
    try {
        const tickets = await client.query(
            `WITH RECURSIVE tab AS (
        (SELECT amount, t.book_ref, id, flight_id, fare_condition, connecting_ticket
         FROM ticket t
                  JOIN booking ON t.book_ref=booking.book_ref
         WHERE t.book_ref=$1 AND t.passenger_id=$2
         ORDER BY connecting_ticket ASC
         LIMIT 1)
        UNION ALL

        SELECT amount, t.book_ref, t.id, t.flight_id, t.fare_condition, t.connecting_ticket
        FROM ticket t
                 JOIN
             tab
             ON tab.connecting_ticket=t.id)
        SELECT amount, id, flight_id, fare_condition, connecting_ticket FROM tab;`,
            [bookRef, passengerID]);
        return tickets.rows;
    } catch(err) {
        console.log(err.message);
    }
}

const updateTicket = async(client, ticketID, flightID, fare) => {
    try {
        var oldFlight = await client.query(
            `SELECT flight_id, fare_condition
            FROM ticket
            WHERE id=$1;`,
            [ticketID]);
        var newTicketID = await client.query(
            `UPDATE ticket
            SET flight_id=$1,
                fare_condition=$2
            WHERE id=$3 RETURNING id;`,
            [flightID, fare, ticketID]);

        await removeSeat(client, oldFlight.rows[0].fare_condition, oldFlight.rows[0].flight_id, 1);
        await postSeat(client, fare, flightID, 1);
        return newTicketID.rows[0].id;
    } catch(err) {
        console.log(err.message);
    }
}

const deleteTicket = async(client, ticketID) => {
    try {
        var flightAndFare = await client.query(
            `DELETE FROM ticket
            WHERE id=$1 RETURNING flight_id, fare_condition;`,
            [ticketID]);
        await removeSeat(client, flightAndFare.rows[0].fare_condition, flightAndFare.rows[0].flight_id, 1);
    } catch(err) {
        console.log(err.message);
    }
}

const deletePassenger = async(client, passID) => {
    try  {
        var seatsBooked = await client.query(
            `SELECT flight_id, fare_condition, COUNT(*)
            FROM passenger
            JOIN ticket
                ON passenger.id = ticket.passenger_id
            JOIN flight
                ON ticket.flight_id = flight.id
            WHERE passenger.id=$1
            GROUP BY flight_id, fare_condition;`,
            [passID]);

        await client.query(
            `DELETE FROM passenger
            WHERE id=$1;`,
            [passID]);

        //Update flight availabilities for each flight that the passenger had a ticket for
        for(let i=0;i<seatsBooked.rows.length;i++)
        {
            await removeSeat(client, seatsBooked.rows[i].fare_condition, seatsBooked.rows[i].flight_id, seatsBooked.rows[i].count);
        }
    } catch(err) {
        console.log(err.message);
    }
}

const deleteBooking = async(client, bookRef) => {
    try {
        var seatsBooked = await client.query(
            `SELECT flight_id, fare_condition, COUNT(*)
            FROM booking
            JOIN ticket
                ON booking.book_ref = ticket.book_ref
            JOIN flight
                ON ticket.flight_id = flight.id
            WHERE booking.book_ref=$1
            GROUP BY flight_id, fare_condition;`,
            [bookRef]);
        // console.log(seatsBooked.rows);
        var cardNum = await client.query(
            `DELETE from booking
            WHERE book_ref=$1 RETURNING card_number;`,
            [bookRef]);

        //Update flight availabilities for each flight that was on the booking
        for(let i=0; i < seatsBooked.rows.length; i++)
        {
            // console.log(seatsBooked.rows[i]);
            // console.log(seatsBooked.rows[i].count);

            await removeSeat(client, seatsBooked.rows[i].fare_condition, seatsBooked.rows[i].flight_id, seatsBooked.rows[i].count);
        }
        // console.log(cardNum.rows);
        var cardReferences = await client.query(
            `SELECT COUNT(book_ref)
             FROM booking
                JOIN credit_card
            ON booking.card_number = credit_card.card_number
            WHERE credit_card.card_number=$1;`,
            [cardNum.rows[0].card_number]);
        if(parseInt(cardReferences.rows[0].count) === 0)
        {
            await client.query(
                `DELETE FROM credit_card
                WHERE card_number=$1;`,
                [cardNum.rows[0].card_number]);

        }
    } catch(err) {
        console.log(err.message);
    }
}

const checkBookRefUniqueness = async(bookRef) => {
    await pool.query("SET SCHEMA 'public';");
    const response = await pool.query(
        `SELECT COUNT(*)
            FROM booking
            WHERE book_ref=$1;`,
            [bookRef]);
    return parseInt(response.rows[0].count);
}

const postStandby = async(client, flightID, bookRef, fare) => {
    let position = await client.query(
        `INSERT INTO standby(flight_id, book_ref, position, fare)
        VALUES
        ($1, $2, (SELECT COALESCE(MAX(position), 0) + 1
                    FROM standby
                    WHERE flight_id =$1), $3) 
        RETURNING position;`,
            [flightID, bookRef, fare]);
    return position.rows[0].position;
}

const validBookRef = async(client, bookRef) => {
    var response = await client.query(
        `SELECT EXISTS (SELECT 1 FROM booking WHERE book_ref=$1);`,
        [bookRef]);
    return response.rows[0].exists;
}

const checkIn = async(client, bookRef) => {
    await client.query(
        `UPDATE ticket
            SET check_in_time=CURRENT_TIMESTAMP
            WHERE book_ref=$1`,
        [bookRef]);
}

const addCargo = async(client, bookRef, numBag=0) => {
    await client.query(
        `INSERT INTO cargo (book_ref, number_of_bag)
            VALUES ($1, $2)`,
        [bookRef, numBag]);
}

module.exports = {getStandby, transactionStatus, directFlights, connectionFlights, cities, getBooking, checkAvailability,
    postCreditCard, postBooking, postPassenger, postTicket, putBookingAmount, updateTicket,
    deleteTicket, getAllTickets, deleteBooking, deletePassenger, checkBookRefUniqueness, postStandby,
    validBookRef, checkIn, addCargo};
