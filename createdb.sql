SET SCHEMA 'public';

DROP TABLE IF EXISTS passenger CASCADE;
DROP TABLE IF EXISTS credit_card CASCADE;
DROP TABLE IF EXISTS booking CASCADE;
DROP TABLE IF EXISTS airport CASCADE;
DROP TABLE IF EXISTS ticket CASCADE;
DROP TABLE IF EXISTS aircraft CASCADE;
DROP TABLE IF EXISTS flight CASCADE;
DROP TABLE IF EXISTS pilot CASCADE;
DROP TABLE IF EXISTS standby CASCADE;
DROP TABLE IF EXISTS cargo CASCADE;
DROP TABLE IF EXISTS discount CASCADE;

CREATE TABLE passenger(
  id SERIAL PRIMARY KEY,
  first_name TEXT NOT NULL,
  last_name TEXT NOT NULL,
  date_of_birth TIMESTAMP NOT NULL
);

CREATE TABLE credit_card(
  card_number NUMERIC(16,0) PRIMARY KEY,
  name_on_card TEXT NOT NULL,
  expiration_month INTEGER NOT NULL,
  expiration_year INTEGER NOT NULL
);

CREATE TABLE discount(
  discount_code VARCHAR PRIMARY KEY,
  amount NUMERIC(7,2) NOT NULL
);

CREATE TABLE booking(
  book_ref TEXT PRIMARY KEY,
  card_number NUMERIC(16,0) REFERENCES credit_card(card_number) NOT NULL,
  discount_code VARCHAR REFERENCES discount(discount_code),
  amount NUMERIC(7,2) NOT NULL,
  contact_email TEXT NOT NULL,
  contact_phone_number NUMERIC(10,0) NOT NULL,
  booking_date TIMESTAMP NOT NULL
);

CREATE TABLE aircraft(
  aircraft_code CHAR(3) PRIMARY KEY,
  model CHAR(25) NOT NULL,
  range INTEGER NOT NULL,
  economy_capacity INTEGER NOT NULL,
  economy_plus_capacity INTEGER NOT NULL,
  business_capacity INTEGER NOT NULL
);

CREATE TABLE airport(
  airport_code CHAR(3) PRIMARY KEY,
  airport_name CHAR(50) NOT NULL,
  city CHAR(20) NOT NULL,
  coordinates POINT,
  timezone TEXT
);

CREATE TABLE flight(
  id INTEGER PRIMARY KEY,
  aircraft_code CHAR(3) REFERENCES aircraft(aircraft_code) NOT NULL,
  boarding_time TIMESTAMP NOT NULL,
  departure_airport CHAR(3) REFERENCES airport(airport_code) NOT NULL,
  departure_gate INTEGER NOT NULL,
  scheduled_departure TIMESTAMP NOT NULL,
  arrival_airport CHAR(3) REFERENCES airport(airport_code) NOT NULL,
  arrival_gate INTEGER NOT NULL,
  scheduled_arrival TIMESTAMP NOT NULL,
  flight_status CHAR VARYING(20) NOT NULL,
  economy_booked INTEGER NOT NULL,
  economy_available INTEGER NOT NULL,
  economy_plus_booked INTEGER NOT NULL,
  economy_plus_available INTEGER NOT NULL,
  business_booked INTEGER NOT NULL,
  business_available INTEGER NOT NULL,
  meal BOOLEAN NOT NULL,
  movie BOOLEAN NOT NULL
  CONSTRAINT flight_check CHECK ((scheduled_arrival > scheduled_departure))
  CONSTRAINT boarding_check CHECK ((scheduled_departure > boarding_time))
);

CREATE TABLE ticket(
  id SERIAL PRIMARY KEY,
  book_ref TEXT REFERENCES booking(book_ref) ON DELETE CASCADE NOT NULL,
  flight_id INTEGER REFERENCES flight(id) NOT NULL,
  passenger_id SERIAL REFERENCES passenger(id) ON DELETE CASCADE NOT NULL,
  fare_condition CHAR VARYING(20) NOT NULL,
  boarding_no SERIAL NOT NULL,
  connecting_ticket INTEGER REFERENCES ticket(id) ON DELETE NO ACTION,
  check_in_time TIMESTAMP
);

CREATE TABLE pilot(
  id SERIAL PRIMARY KEY,
  flight_id INTEGER REFERENCES flight(id) NOT NULL,
  first_name TEXT NOT NULL,
  last_name TEXT NOT NULL
);

CREATE TABLE standby(
  flight_id INTEGER,
  position INTEGER,
  fare_condition CHAR VARYING(20),
  book_ref TEXT REFERENCES booking(book_ref) ON DELETE CASCADE NOT NULL,
  PRIMARY KEY(flight_id, position)
);

CREATE TABLE cargo(
  stock_keeping_no SERIAL PRIMARY KEY,
  book_ref TEXT REFERENCES booking(book_ref) ON DELETE CASCADE NOT NULL,
  number_of_bag INTEGER NOT NULL
);

/** airport **/
INSERT INTO airport
VALUES (
  'ATL',
  'Hartsfield-Jackson Atlanta International Airport',
  'Atlanta',
  '(33.64,-84.43)',
  'GMT -5:00'
);

INSERT INTO airport
VALUES (
  'LAX',
  'Los Angeles International Airport',
  'Los Angeles',
  '(33.94,-118.41)',
  'GMT -8:00'
);

INSERT INTO airport
VALUES (
  'ORD',
  'Chicago O`Hare International Airport',
  'Chicago',
  '(41.98,-87.90)',
  'GMT -6:00'
);

INSERT INTO airport
VALUES (
  'DFW',
  'Dallas/Fort Worth International Airport',
  'Dallas',
  '(32.90,-97.04)',
  'GMT -6:00'
);

INSERT INTO airport
VALUES (
  'DEN',
  'Denver International Airport',
  'Denver',
  '(39.86,-104.67)',
  'GMT -7:00'
);

INSERT INTO airport
VALUES (
  'JFK',
  'John F Kennedy International Airport',
  'New York',
  '(40.64,-73.78)',
  'GMT -5:00'
);

INSERT INTO airport
VALUES (
  'SFO',
  'San Francisco International Airport',
  'San Francisco',
  '(37.62,-122.38)',
  'GMT -8:00'
);

INSERT INTO airport
VALUES (
  'SEA',
  'Seattle Tacoma International Airport',
  'Seattle',
  '(47.45,-122.31)',
  'GMT -8:00'
);

INSERT INTO airport
VALUES (
  'LAS',
  'McCarran International Airport',
  'Las Vegas',
  '(36.08,-115.15)',
  'GMT -8:00'
);

INSERT INTO airport
VALUES (
  'MCO',
  'Orlando International Airport',
  'Orlando',
  '(28.43,-81.31)',
  'GMT -5:00'
);

/** aircraft **/
INSERT INTO aircraft
VALUES (
  '310',
  'Airbus A310',
  5002,
  100,
  100,
  100
);

INSERT INTO aircraft
VALUES (
  '318',
  'Airbus A318',
  3542,
  50,
  50,
  50
);

INSERT INTO aircraft
VALUES (
  '319',
  'Airbus A319',
  4287,
  50,
  50,
  50
);

INSERT INTO aircraft
VALUES (
  '321',
  'Airbus A321',
  3697,
  50,
  50,
  50
);

INSERT INTO aircraft
VALUES (
  '330',
  'Airbus A330',
  11750,
  100,
  100,
  100
);

INSERT INTO aircraft
VALUES (
  '340',
  'Airbus A340',
  7900,
  100,
  100,
  100
);

INSERT INTO aircraft
VALUES (
  '342',
  'Airbus A340-200',
  12400,
  100,
  100,
  100
);

INSERT INTO aircraft
VALUES (
  '343',
  'Airbus A340-300',
  13500,
  100,
  100,
  100
);

INSERT INTO aircraft
VALUES (
  '345',
  'Airbus A340-500',
  16670,
  100,
  100,
  100
);

INSERT INTO aircraft
VALUES (
  '346',
  'Airbus A340-600',
  14450,
  100,
  100,
  100
);

/**flight**/
INSERT INTO flight
VALUES (
'1000',
'330',
'2020-12-10 12:30:00',
'ATL',
102,
'2020-12-10 13:00:00',
'LAS',
8,
'2020-12-10 16:00:00',
'Scheduled',
0,
100,
0,
100,
0,
100,
TRUE,
TRUE
);


INSERT INTO pilot (flight_id, first_name, last_name)
VALUES (
'1000',
'James',
'Smith'
);


INSERT INTO flight
VALUES (
'1001',
'342',
'2020-12-10 12:30:00',
'JFK',
89,
'2020-12-10 13:00:00',
'MCO',
106,
'2020-12-10 16:00:00',
'Scheduled',
0,
100,
0,
100,
0,
100,
TRUE,
TRUE
);


INSERT INTO pilot (flight_id, first_name, last_name)
VALUES (
'1001',
'Mason',
'Lee'
);


INSERT INTO flight
VALUES (
'1002',
'345',
'2020-12-10 09:30:00',
'JFK',
82,
'2020-12-10 10:00:00',
'ATL',
97,
'2020-12-10 13:00:00',
'Scheduled',
0,
100,
0,
100,
0,
100,
TRUE,
TRUE
);


INSERT INTO pilot (flight_id, first_name, last_name)
VALUES (
'1002',
'Jacob',
'Miller'
);


INSERT INTO flight
VALUES (
'1003',
'318',
'2020-12-10 09:30:00',
'ATL',
8,
'2020-12-10 10:00:00',
'DEN',
77,
'2020-12-10 13:00:00',
'Scheduled',
0,
50,
0,
50,
0,
50,
FALSE,
FALSE
);


INSERT INTO pilot (flight_id, first_name, last_name)
VALUES (
'1003',
'James',
'Smith'
);


INSERT INTO flight
VALUES (
'1004',
'346',
'2020-12-10 07:30:00',
'LAX',
36,
'2020-12-10 08:00:00',
'MCO',
81,
'2020-12-10 10:00:00',
'Scheduled',
0,
100,
0,
100,
0,
100,
TRUE,
TRUE
);


INSERT INTO pilot (flight_id, first_name, last_name)
VALUES (
'1004',
'Liam',
'Brown'
);


INSERT INTO flight
VALUES (
'1005',
'343',
'2020-12-10 03:30:00',
'ORD',
27,
'2020-12-10 04:00:00',
'DFW',
11,
'2020-12-10 06:00:00',
'Scheduled',
0,
100,
0,
100,
0,
100,
TRUE,
TRUE
);


INSERT INTO pilot (flight_id, first_name, last_name)
VALUES (
'1005',
'Mason',
'Miller'
);


INSERT INTO flight
VALUES (
'1006',
'330',
'2020-12-10 10:30:00',
'LAX',
46,
'2020-12-10 11:00:00',
'ORD',
53,
'2020-12-10 13:00:00',
'Scheduled',
0,
100,
0,
100,
0,
100,
TRUE,
TRUE
);


INSERT INTO pilot (flight_id, first_name, last_name)
VALUES (
'1006',
'William',
'Smith'
);


INSERT INTO flight
VALUES (
'1007',
'346',
'2020-12-10 09:30:00',
'ATL',
92,
'2020-12-10 10:00:00',
'DFW',
93,
'2020-12-10 13:00:00',
'Scheduled',
0,
100,
0,
100,
0,
100,
TRUE,
TRUE
);


INSERT INTO pilot (flight_id, first_name, last_name)
VALUES (
'1007',
'Jacob',
'Miller'
);


INSERT INTO flight
VALUES (
'1008',
'343',
'2020-12-10 04:30:00',
'DFW',
18,
'2020-12-10 05:00:00',
'ORD',
81,
'2020-12-10 07:00:00',
'Scheduled',
0,
100,
0,
100,
0,
100,
TRUE,
TRUE
);


INSERT INTO pilot (flight_id, first_name, last_name)
VALUES (
'1008',
'Alex',
'Thomas'
);


INSERT INTO flight
VALUES (
'1009',
'342',
'2020-12-10 07:30:00',
'DEN',
69,
'2020-12-10 08:00:00',
'LAX',
94,
'2020-12-10 10:00:00',
'Scheduled',
0,
100,
0,
100,
0,
100,
TRUE,
TRUE
);


INSERT INTO pilot (flight_id, first_name, last_name)
VALUES (
'1009',
'James',
'Anderson'
);


INSERT INTO flight
VALUES (
'1010',
'343',
'2020-12-10 04:30:00',
'DFW',
11,
'2020-12-10 05:00:00',
'LAS',
27,
'2020-12-10 07:00:00',
'Scheduled',
0,
100,
0,
100,
0,
100,
TRUE,
TRUE
);


INSERT INTO pilot (flight_id, first_name, last_name)
VALUES (
'1010',
'Mason',
'Garcia'
);


INSERT INTO flight
VALUES (
'1011',
'343',
'2020-12-10 05:30:00',
'MCO',
30,
'2020-12-10 06:00:00',
'ORD',
48,
'2020-12-10 08:00:00',
'Scheduled',
0,
100,
0,
100,
0,
100,
TRUE,
TRUE
);


INSERT INTO pilot (flight_id, first_name, last_name)
VALUES (
'1011',
'Ethan',
'Thomas'
);


INSERT INTO flight
VALUES (
'1012',
'318',
'2020-12-10 10:30:00',
'MCO',
38,
'2020-12-10 11:00:00',
'DEN',
34,
'2020-12-10 13:00:00',
'Scheduled',
0,
50,
0,
50,
0,
50,
FALSE,
FALSE
);


INSERT INTO pilot (flight_id, first_name, last_name)
VALUES (
'1012',
'John',
'Miller'
);


INSERT INTO flight
VALUES (
'1013',
'310',
'2020-12-10 06:30:00',
'DEN',
43,
'2020-12-10 07:00:00',
'MCO',
65,
'2020-12-10 10:00:00',
'Scheduled',
0,
100,
0,
100,
0,
100,
TRUE,
TRUE
);


INSERT INTO pilot (flight_id, first_name, last_name)
VALUES (
'1013',
'Noah',
'Anderson'
);


INSERT INTO flight
VALUES (
'1014',
'321',
'2020-12-10 09:30:00',
'LAS',
88,
'2020-12-10 10:00:00',
'MCO',
67,
'2020-12-10 13:00:00',
'Scheduled',
0,
50,
0,
50,
0,
50,
FALSE,
FALSE
);


INSERT INTO pilot (flight_id, first_name, last_name)
VALUES (
'1014',
'Ethan',
'Smith'
);


INSERT INTO flight
VALUES (
'1015',
'321',
'2020-12-10 10:30:00',
'LAX',
76,
'2020-12-10 11:00:00',
'SEA',
30,
'2020-12-10 13:00:00',
'Scheduled',
0,
50,
0,
50,
0,
50,
FALSE,
FALSE
);


INSERT INTO pilot (flight_id, first_name, last_name)
VALUES (
'1015',
'Ethan',
'Harris'
);


INSERT INTO flight
VALUES (
'1016',
'330',
'2020-12-10 03:30:00',
'DEN',
72,
'2020-12-10 04:00:00',
'LAS',
100,
'2020-12-10 06:00:00',
'Scheduled',
0,
100,
0,
100,
0,
100,
TRUE,
TRUE
);


INSERT INTO pilot (flight_id, first_name, last_name)
VALUES (
'1016',
'William',
'Davis'
);


INSERT INTO flight
VALUES (
'1017',
'319',
'2020-12-10 10:30:00',
'SEA',
48,
'2020-12-10 11:00:00',
'ATL',
63,
'2020-12-10 13:00:00',
'Scheduled',
0,
50,
0,
50,
0,
50,
FALSE,
FALSE
);


INSERT INTO pilot (flight_id, first_name, last_name)
VALUES (
'1017',
'Ethan',
'Harris'
);


INSERT INTO flight
VALUES (
'1018',
'318',
'2020-12-10 06:30:00',
'LAX',
59,
'2020-12-10 07:00:00',
'ATL',
29,
'2020-12-10 10:00:00',
'Scheduled',
0,
50,
0,
50,
0,
50,
FALSE,
FALSE
);


INSERT INTO pilot (flight_id, first_name, last_name)
VALUES (
'1018',
'Jacob',
'Anderson'
);


INSERT INTO flight
VALUES (
'1019',
'319',
'2020-12-10 04:30:00',
'DEN',
51,
'2020-12-10 05:00:00',
'LAS',
14,
'2020-12-10 07:00:00',
'Scheduled',
0,
50,
0,
50,
0,
50,
FALSE,
FALSE
);


INSERT INTO pilot (flight_id, first_name, last_name)
VALUES (
'1019',
'Alex',
'Brown'
);


INSERT INTO flight
VALUES (
'1020',
'342',
'2020-12-10 07:30:00',
'LAS',
90,
'2020-12-10 08:00:00',
'SFO',
30,
'2020-12-10 10:00:00',
'Scheduled',
0,
100,
0,
100,
0,
100,
TRUE,
TRUE
);


INSERT INTO pilot (flight_id, first_name, last_name)
VALUES (
'1020',
'Alex',
'Miller'
);


INSERT INTO flight
VALUES (
'1021',
'346',
'2020-12-10 04:30:00',
'SFO',
100,
'2020-12-10 05:00:00',
'DFW',
23,
'2020-12-10 07:00:00',
'Scheduled',
0,
100,
0,
100,
0,
100,
TRUE,
TRUE
);


INSERT INTO pilot (flight_id, first_name, last_name)
VALUES (
'1021',
'Alex',
'Wang'
);


INSERT INTO flight
VALUES (
'1022',
'346',
'2020-12-10 10:30:00',
'DFW',
62,
'2020-12-10 11:00:00',
'SFO',
105,
'2020-12-10 13:00:00',
'Scheduled',
0,
100,
0,
100,
0,
100,
TRUE,
TRUE
);


INSERT INTO pilot (flight_id, first_name, last_name)
VALUES (
'1022',
'Jacob',
'Davis'
);


INSERT INTO flight
VALUES (
'1023',
'330',
'2020-12-10 08:30:00',
'ATL',
51,
'2020-12-10 09:00:00',
'DFW',
15,
'2020-12-10 12:00:00',
'Scheduled',
0,
100,
0,
100,
0,
100,
TRUE,
TRUE
);


INSERT INTO pilot (flight_id, first_name, last_name)
VALUES (
'1023',
'Noah',
'Garcia'
);


INSERT INTO flight
VALUES (
'1024',
'330',
'2020-12-10 10:30:00',
'LAS',
70,
'2020-12-10 11:00:00',
'ATL',
15,
'2020-12-10 13:00:00',
'Scheduled',
0,
100,
0,
100,
0,
100,
TRUE,
TRUE
);


INSERT INTO pilot (flight_id, first_name, last_name)
VALUES (
'1024',
'Alex',
'Brown'
);


INSERT INTO flight
VALUES (
'1025',
'318',
'2020-12-10 11:30:00',
'DEN',
30,
'2020-12-10 12:00:00',
'DFW',
77,
'2020-12-10 15:00:00',
'Scheduled',
0,
50,
0,
50,
0,
50,
FALSE,
FALSE
);


INSERT INTO pilot (flight_id, first_name, last_name)
VALUES (
'1025',
'James',
'Davis'
);


INSERT INTO flight
VALUES (
'1026',
'340',
'2020-12-10 07:30:00',
'JFK',
101,
'2020-12-10 08:00:00',
'LAX',
105,
'2020-12-10 10:00:00',
'Scheduled',
0,
100,
0,
100,
0,
100,
TRUE,
TRUE
);


INSERT INTO pilot (flight_id, first_name, last_name)
VALUES (
'1026',
'Ethan',
'Garcia'
);


INSERT INTO flight
VALUES (
'1027',
'343',
'2020-12-10 08:30:00',
'LAX',
41,
'2020-12-10 09:00:00',
'JFK',
52,
'2020-12-10 12:00:00',
'Scheduled',
0,
100,
0,
100,
0,
100,
TRUE,
TRUE
);


INSERT INTO pilot (flight_id, first_name, last_name)
VALUES (
'1027',
'James',
'Smith'
);


INSERT INTO flight
VALUES (
'1028',
'321',
'2020-12-10 05:30:00',
'LAX',
97,
'2020-12-10 06:00:00',
'MCO',
86,
'2020-12-10 08:00:00',
'Scheduled',
0,
50,
0,
50,
0,
50,
FALSE,
FALSE
);


INSERT INTO pilot (flight_id, first_name, last_name)
VALUES (
'1028',
'John',
'Anderson'
);


INSERT INTO flight
VALUES (
'1029',
'318',
'2020-12-10 10:30:00',
'DFW',
52,
'2020-12-10 11:00:00',
'SEA',
11,
'2020-12-10 13:00:00',
'Scheduled',
0,
50,
0,
50,
0,
50,
FALSE,
FALSE
);


INSERT INTO pilot (flight_id, first_name, last_name)
VALUES (
'1029',
'William',
'Lee'
);


INSERT INTO flight
VALUES (
'1030',
'346',
'2020-12-10 08:30:00',
'LAS',
70,
'2020-12-10 09:00:00',
'SEA',
69,
'2020-12-10 12:00:00',
'Scheduled',
0,
100,
0,
100,
0,
100,
TRUE,
TRUE
);


INSERT INTO pilot (flight_id, first_name, last_name)
VALUES (
'1030',
'Ethan',
'Wang'
);


INSERT INTO flight
VALUES (
'1031',
'319',
'2020-12-10 09:30:00',
'DFW',
59,
'2020-12-10 10:00:00',
'ATL',
48,
'2020-12-10 13:00:00',
'Scheduled',
0,
50,
0,
50,
0,
50,
FALSE,
FALSE
);


INSERT INTO pilot (flight_id, first_name, last_name)
VALUES (
'1031',
'William',
'Thomas'
);


INSERT INTO flight
VALUES (
'1032',
'330',
'2020-12-10 05:30:00',
'LAX',
101,
'2020-12-10 06:00:00',
'JFK',
21,
'2020-12-10 08:00:00',
'Scheduled',
0,
100,
0,
100,
0,
100,
TRUE,
TRUE
);


INSERT INTO pilot (flight_id, first_name, last_name)
VALUES (
'1032',
'William',
'Miller'
);


INSERT INTO flight
VALUES (
'1033',
'310',
'2020-12-10 05:30:00',
'DEN',
18,
'2020-12-10 06:00:00',
'SFO',
69,
'2020-12-10 08:00:00',
'Scheduled',
0,
100,
0,
100,
0,
100,
TRUE,
TRUE
);


INSERT INTO pilot (flight_id, first_name, last_name)
VALUES (
'1033',
'Michael',
'Thomas'
);


INSERT INTO flight
VALUES (
'1034',
'343',
'2020-12-10 12:30:00',
'DEN',
31,
'2020-12-10 13:00:00',
'ORD',
33,
'2020-12-10 16:00:00',
'Scheduled',
0,
100,
0,
100,
0,
100,
TRUE,
TRUE
);


INSERT INTO pilot (flight_id, first_name, last_name)
VALUES (
'1034',
'Mason',
'Smith'
);


INSERT INTO flight
VALUES (
'1035',
'340',
'2020-12-10 09:30:00',
'DEN',
9,
'2020-12-10 10:00:00',
'SEA',
88,
'2020-12-10 13:00:00',
'Scheduled',
0,
100,
0,
100,
0,
100,
TRUE,
TRUE
);


INSERT INTO pilot (flight_id, first_name, last_name)
VALUES (
'1035',
'Ethan',
'Anderson'
);


INSERT INTO flight
VALUES (
'1036',
'318',
'2020-12-10 07:30:00',
'SFO',
18,
'2020-12-10 08:00:00',
'JFK',
93,
'2020-12-10 10:00:00',
'Scheduled',
0,
50,
0,
50,
0,
50,
FALSE,
FALSE
);


INSERT INTO pilot (flight_id, first_name, last_name)
VALUES (
'1036',
'William',
'Miller'
);


INSERT INTO flight
VALUES (
'1037',
'330',
'2020-12-10 03:30:00',
'JFK',
42,
'2020-12-10 04:00:00',
'SEA',
100,
'2020-12-10 06:00:00',
'Scheduled',
0,
100,
0,
100,
0,
100,
TRUE,
TRUE
);


INSERT INTO pilot (flight_id, first_name, last_name)
VALUES (
'1037',
'James',
'Miller'
);


INSERT INTO flight
VALUES (
'1038',
'343',
'2020-12-10 12:30:00',
'LAX',
35,
'2020-12-10 13:00:00',
'JFK',
89,
'2020-12-10 16:00:00',
'Scheduled',
0,
100,
0,
100,
0,
100,
TRUE,
TRUE
);


INSERT INTO pilot (flight_id, first_name, last_name)
VALUES (
'1038',
'Jacob',
'Thomas'
);


INSERT INTO flight
VALUES (
'1039',
'345',
'2020-12-10 11:30:00',
'JFK',
51,
'2020-12-10 12:00:00',
'SEA',
104,
'2020-12-10 15:00:00',
'Scheduled',
0,
100,
0,
100,
0,
100,
TRUE,
TRUE
);


INSERT INTO pilot (flight_id, first_name, last_name)
VALUES (
'1039',
'James',
'Harris'
);


INSERT INTO flight
VALUES (
'1040',
'343',
'2020-12-10 08:30:00',
'DEN',
25,
'2020-12-10 09:00:00',
'ORD',
30,
'2020-12-10 12:00:00',
'Scheduled',
0,
100,
0,
100,
0,
100,
TRUE,
TRUE
);


INSERT INTO pilot (flight_id, first_name, last_name)
VALUES (
'1040',
'James',
'Wang'
);


INSERT INTO flight
VALUES (
'1041',
'345',
'2020-12-10 12:30:00',
'DFW',
36,
'2020-12-10 13:00:00',
'JFK',
28,
'2020-12-10 16:00:00',
'Scheduled',
0,
100,
0,
100,
0,
100,
TRUE,
TRUE
);


INSERT INTO pilot (flight_id, first_name, last_name)
VALUES (
'1041',
'Noah',
'Thomas'
);


INSERT INTO flight
VALUES (
'1042',
'343',
'2020-12-10 06:30:00',
'LAX',
38,
'2020-12-10 07:00:00',
'MCO',
23,
'2020-12-10 10:00:00',
'Scheduled',
0,
100,
0,
100,
0,
100,
TRUE,
TRUE
);


INSERT INTO pilot (flight_id, first_name, last_name)
VALUES (
'1042',
'John',
'Lee'
);


INSERT INTO flight
VALUES (
'1043',
'321',
'2020-12-10 08:30:00',
'MCO',
9,
'2020-12-10 09:00:00',
'ORD',
54,
'2020-12-10 12:00:00',
'Scheduled',
0,
50,
0,
50,
0,
50,
FALSE,
FALSE
);


INSERT INTO pilot (flight_id, first_name, last_name)
VALUES (
'1043',
'John',
'Brown'
);


INSERT INTO flight
VALUES (
'1044',
'343',
'2020-12-10 06:30:00',
'MCO',
69,
'2020-12-10 07:00:00',
'ORD',
58,
'2020-12-10 10:00:00',
'Scheduled',
0,
100,
0,
100,
0,
100,
TRUE,
TRUE
);


INSERT INTO pilot (flight_id, first_name, last_name)
VALUES (
'1044',
'William',
'Brown'
);


INSERT INTO flight
VALUES (
'1045',
'346',
'2020-12-10 11:30:00',
'MCO',
70,
'2020-12-10 12:00:00',
'ORD',
106,
'2020-12-10 15:00:00',
'Scheduled',
0,
100,
0,
100,
0,
100,
TRUE,
TRUE
);


INSERT INTO pilot (flight_id, first_name, last_name)
VALUES (
'1045',
'Jacob',
'Lee'
);


INSERT INTO flight
VALUES (
'1046',
'319',
'2020-12-10 08:30:00',
'ORD',
111,
'2020-12-10 09:00:00',
'SFO',
64,
'2020-12-10 12:00:00',
'Scheduled',
0,
50,
0,
50,
0,
50,
FALSE,
FALSE
);


INSERT INTO pilot (flight_id, first_name, last_name)
VALUES (
'1046',
'Liam',
'Garcia'
);


INSERT INTO flight
VALUES (
'1047',
'310',
'2020-12-10 04:30:00',
'DEN',
101,
'2020-12-10 05:00:00',
'LAX',
90,
'2020-12-10 07:00:00',
'Scheduled',
0,
100,
0,
100,
0,
100,
TRUE,
TRUE
);


INSERT INTO pilot (flight_id, first_name, last_name)
VALUES (
'1047',
'Alex',
'Harris'
);


INSERT INTO flight
VALUES (
'1048',
'346',
'2020-12-10 08:30:00',
'JFK',
78,
'2020-12-10 09:00:00',
'LAS',
5,
'2020-12-10 12:00:00',
'Scheduled',
0,
100,
0,
100,
0,
100,
TRUE,
TRUE
);


INSERT INTO pilot (flight_id, first_name, last_name)
VALUES (
'1048',
'Liam',
'Smith'
);


INSERT INTO flight
VALUES (
'1049',
'330',
'2020-12-10 10:30:00',
'ATL',
84,
'2020-12-10 11:00:00',
'JFK',
97,
'2020-12-10 13:00:00',
'Scheduled',
0,
100,
0,
100,
0,
100,
TRUE,
TRUE
);


INSERT INTO pilot (flight_id, first_name, last_name)
VALUES (
'1049',
'Alex',
'Smith'
);


INSERT INTO flight
VALUES (
'1050',
'318',
'2020-12-10 09:30:00',
'ATL',
37,
'2020-12-10 10:00:00',
'LAX',
5,
'2020-12-10 13:00:00',
'Scheduled',
0,
50,
0,
50,
0,
50,
FALSE,
FALSE
);


INSERT INTO pilot (flight_id, first_name, last_name)
VALUES (
'1050',
'Alex',
'Brown'
);


INSERT INTO flight
VALUES (
'1051',
'340',
'2020-12-11 09:30:00',
'SFO',
19,
'2020-12-11 10:00:00',
'ORD',
106,
'2020-12-11 13:00:00',
'Scheduled',
0,
100,
0,
100,
0,
100,
TRUE,
TRUE
);


INSERT INTO pilot (flight_id, first_name, last_name)
VALUES (
'1051',
'Jacob',
'Garcia'
);


INSERT INTO flight
VALUES (
'1052',
'321',
'2020-12-11 12:30:00',
'MCO',
33,
'2020-12-11 13:00:00',
'SEA',
103,
'2020-12-11 16:00:00',
'Scheduled',
0,
50,
0,
50,
0,
50,
FALSE,
FALSE
);


INSERT INTO pilot (flight_id, first_name, last_name)
VALUES (
'1052',
'Michael',
'Wang'
);


INSERT INTO flight
VALUES (
'1053',
'330',
'2020-12-11 05:30:00',
'DFW',
84,
'2020-12-11 06:00:00',
'SFO',
2,
'2020-12-11 08:00:00',
'Scheduled',
0,
100,
0,
100,
0,
100,
TRUE,
TRUE
);


INSERT INTO pilot (flight_id, first_name, last_name)
VALUES (
'1053',
'Mason',
'Wang'
);


INSERT INTO flight
VALUES (
'1054',
'310',
'2020-12-11 09:30:00',
'SEA',
58,
'2020-12-11 10:00:00',
'SFO',
97,
'2020-12-11 13:00:00',
'Scheduled',
0,
100,
0,
100,
0,
100,
TRUE,
TRUE
);


INSERT INTO pilot (flight_id, first_name, last_name)
VALUES (
'1054',
'Mason',
'Smith'
);


INSERT INTO flight
VALUES (
'1055',
'345',
'2020-12-11 03:30:00',
'SFO',
67,
'2020-12-11 04:00:00',
'JFK',
101,
'2020-12-11 06:00:00',
'Scheduled',
0,
100,
0,
100,
0,
100,
TRUE,
TRUE
);


INSERT INTO pilot (flight_id, first_name, last_name)
VALUES (
'1055',
'John',
'Davis'
);


INSERT INTO flight
VALUES (
'1056',
'345',
'2020-12-11 11:30:00',
'MCO',
31,
'2020-12-11 12:00:00',
'DEN',
22,
'2020-12-11 15:00:00',
'Scheduled',
0,
100,
0,
100,
0,
100,
TRUE,
TRUE
);


INSERT INTO pilot (flight_id, first_name, last_name)
VALUES (
'1056',
'Noah',
'Miller'
);


INSERT INTO flight
VALUES (
'1057',
'321',
'2020-12-11 08:30:00',
'DEN',
3,
'2020-12-11 09:00:00',
'DFW',
2,
'2020-12-11 12:00:00',
'Scheduled',
0,
50,
0,
50,
0,
50,
FALSE,
FALSE
);


INSERT INTO pilot (flight_id, first_name, last_name)
VALUES (
'1057',
'Liam',
'Smith'
);


INSERT INTO flight
VALUES (
'1058',
'321',
'2020-12-11 04:30:00',
'ATL',
18,
'2020-12-11 05:00:00',
'LAS',
18,
'2020-12-11 07:00:00',
'Scheduled',
0,
50,
0,
50,
0,
50,
FALSE,
FALSE
);


INSERT INTO pilot (flight_id, first_name, last_name)
VALUES (
'1058',
'Michael',
'Miller'
);


INSERT INTO flight
VALUES (
'1059',
'318',
'2020-12-11 10:30:00',
'DFW',
74,
'2020-12-11 11:00:00',
'SEA',
77,
'2020-12-11 13:00:00',
'Scheduled',
0,
50,
0,
50,
0,
50,
FALSE,
FALSE
);


INSERT INTO pilot (flight_id, first_name, last_name)
VALUES (
'1059',
'Ethan',
'Wang'
);


INSERT INTO flight
VALUES (
'1060',
'342',
'2020-12-11 04:30:00',
'LAX',
21,
'2020-12-11 05:00:00',
'JFK',
28,
'2020-12-11 07:00:00',
'Scheduled',
0,
100,
0,
100,
0,
100,
TRUE,
TRUE
);


INSERT INTO pilot (flight_id, first_name, last_name)
VALUES (
'1060',
'Jacob',
'Wang'
);


INSERT INTO flight
VALUES (
'1061',
'318',
'2020-12-11 12:30:00',
'SEA',
53,
'2020-12-11 13:00:00',
'LAS',
101,
'2020-12-11 16:00:00',
'Scheduled',
0,
50,
0,
50,
0,
50,
FALSE,
FALSE
);


INSERT INTO pilot (flight_id, first_name, last_name)
VALUES (
'1061',
'John',
'Thomas'
);


INSERT INTO flight
VALUES (
'1062',
'343',
'2020-12-11 07:30:00',
'JFK',
8,
'2020-12-11 08:00:00',
'SFO',
104,
'2020-12-11 10:00:00',
'Scheduled',
0,
100,
0,
100,
0,
100,
TRUE,
TRUE
);


INSERT INTO pilot (flight_id, first_name, last_name)
VALUES (
'1062',
'John',
'Thomas'
);


INSERT INTO flight
VALUES (
'1063',
'330',
'2020-12-11 04:30:00',
'SFO',
57,
'2020-12-11 05:00:00',
'ATL',
15,
'2020-12-11 07:00:00',
'Scheduled',
0,
100,
0,
100,
0,
100,
TRUE,
TRUE
);


INSERT INTO pilot (flight_id, first_name, last_name)
VALUES (
'1063',
'Alex',
'Davis'
);


INSERT INTO flight
VALUES (
'1064',
'346',
'2020-12-11 07:30:00',
'LAX',
34,
'2020-12-11 08:00:00',
'SEA',
41,
'2020-12-11 10:00:00',
'Scheduled',
0,
100,
0,
100,
0,
100,
TRUE,
TRUE
);


INSERT INTO pilot (flight_id, first_name, last_name)
VALUES (
'1064',
'Jacob',
'Wang'
);


INSERT INTO flight
VALUES (
'1065',
'321',
'2020-12-11 11:30:00',
'DEN',
77,
'2020-12-11 12:00:00',
'DFW',
79,
'2020-12-11 15:00:00',
'Scheduled',
0,
50,
0,
50,
0,
50,
FALSE,
FALSE
);


INSERT INTO pilot (flight_id, first_name, last_name)
VALUES (
'1065',
'Ethan',
'Davis'
);


INSERT INTO flight
VALUES (
'1066',
'345',
'2020-12-11 04:30:00',
'SFO',
27,
'2020-12-11 05:00:00',
'JFK',
10,
'2020-12-11 07:00:00',
'Scheduled',
0,
100,
0,
100,
0,
100,
TRUE,
TRUE
);


INSERT INTO pilot (flight_id, first_name, last_name)
VALUES (
'1066',
'Alex',
'Davis'
);


INSERT INTO flight
VALUES (
'1067',
'319',
'2020-12-11 05:30:00',
'LAS',
79,
'2020-12-11 06:00:00',
'DEN',
71,
'2020-12-11 08:00:00',
'Scheduled',
0,
50,
0,
50,
0,
50,
FALSE,
FALSE
);


INSERT INTO pilot (flight_id, first_name, last_name)
VALUES (
'1067',
'Alex',
'Wang'
);


INSERT INTO flight
VALUES (
'1068',
'330',
'2020-12-11 06:30:00',
'LAS',
74,
'2020-12-11 07:00:00',
'DEN',
82,
'2020-12-11 10:00:00',
'Scheduled',
0,
100,
0,
100,
0,
100,
TRUE,
TRUE
);


INSERT INTO pilot (flight_id, first_name, last_name)
VALUES (
'1068',
'Michael',
'Davis'
);


INSERT INTO flight
VALUES (
'1069',
'319',
'2020-12-11 10:30:00',
'LAS',
78,
'2020-12-11 11:00:00',
'SFO',
98,
'2020-12-11 13:00:00',
'Scheduled',
0,
50,
0,
50,
0,
50,
FALSE,
FALSE
);


INSERT INTO pilot (flight_id, first_name, last_name)
VALUES (
'1069',
'Michael',
'Brown'
);


INSERT INTO flight
VALUES (
'1070',
'318',
'2020-12-11 03:30:00',
'SFO',
41,
'2020-12-11 04:00:00',
'ATL',
86,
'2020-12-11 06:00:00',
'Scheduled',
0,
50,
0,
50,
0,
50,
FALSE,
FALSE
);


INSERT INTO pilot (flight_id, first_name, last_name)
VALUES (
'1070',
'Noah',
'Davis'
);


INSERT INTO flight
VALUES (
'1071',
'321',
'2020-12-11 06:30:00',
'SEA',
41,
'2020-12-11 07:00:00',
'MCO',
8,
'2020-12-11 10:00:00',
'Scheduled',
0,
50,
0,
50,
0,
50,
FALSE,
FALSE
);


INSERT INTO pilot (flight_id, first_name, last_name)
VALUES (
'1071',
'Noah',
'Wang'
);


INSERT INTO flight
VALUES (
'1072',
'340',
'2020-12-11 03:30:00',
'ATL',
61,
'2020-12-11 04:00:00',
'LAS',
39,
'2020-12-11 06:00:00',
'Scheduled',
0,
100,
0,
100,
0,
100,
TRUE,
TRUE
);


INSERT INTO pilot (flight_id, first_name, last_name)
VALUES (
'1072',
'Michael',
'Smith'
);


INSERT INTO flight
VALUES (
'1073',
'318',
'2020-12-11 09:30:00',
'LAS',
63,
'2020-12-11 10:00:00',
'ATL',
73,
'2020-12-11 13:00:00',
'Scheduled',
0,
50,
0,
50,
0,
50,
FALSE,
FALSE
);


INSERT INTO pilot (flight_id, first_name, last_name)
VALUES (
'1073',
'Ethan',
'Brown'
);


INSERT INTO flight
VALUES (
'1074',
'321',
'2020-12-11 08:30:00',
'MCO',
92,
'2020-12-11 09:00:00',
'DEN',
102,
'2020-12-11 12:00:00',
'Scheduled',
0,
50,
0,
50,
0,
50,
FALSE,
FALSE
);


INSERT INTO pilot (flight_id, first_name, last_name)
VALUES (
'1074',
'John',
'Miller'
);


INSERT INTO flight
VALUES (
'1075',
'345',
'2020-12-11 11:30:00',
'LAS',
14,
'2020-12-11 12:00:00',
'MCO',
87,
'2020-12-11 15:00:00',
'Scheduled',
0,
100,
0,
100,
0,
100,
TRUE,
TRUE
);


INSERT INTO pilot (flight_id, first_name, last_name)
VALUES (
'1075',
'Ethan',
'Thomas'
);


INSERT INTO flight
VALUES (
'1076',
'330',
'2020-12-11 10:30:00',
'ATL',
3,
'2020-12-11 11:00:00',
'DFW',
59,
'2020-12-11 13:00:00',
'Scheduled',
0,
100,
0,
100,
0,
100,
TRUE,
TRUE
);


INSERT INTO pilot (flight_id, first_name, last_name)
VALUES (
'1076',
'John',
'Davis'
);


INSERT INTO flight
VALUES (
'1077',
'318',
'2020-12-11 11:30:00',
'DFW',
84,
'2020-12-11 12:00:00',
'LAS',
71,
'2020-12-11 15:00:00',
'Scheduled',
0,
50,
0,
50,
0,
50,
FALSE,
FALSE
);


INSERT INTO pilot (flight_id, first_name, last_name)
VALUES (
'1077',
'Liam',
'Brown'
);


INSERT INTO flight
VALUES (
'1078',
'342',
'2020-12-11 04:30:00',
'DEN',
37,
'2020-12-11 05:00:00',
'DFW',
44,
'2020-12-11 07:00:00',
'Scheduled',
0,
100,
0,
100,
0,
100,
TRUE,
TRUE
);


INSERT INTO pilot (flight_id, first_name, last_name)
VALUES (
'1078',
'Michael',
'Miller'
);


INSERT INTO flight
VALUES (
'1079',
'319',
'2020-12-11 11:30:00',
'JFK',
13,
'2020-12-11 12:00:00',
'DFW',
82,
'2020-12-11 15:00:00',
'Scheduled',
0,
50,
0,
50,
0,
50,
FALSE,
FALSE
);


INSERT INTO pilot (flight_id, first_name, last_name)
VALUES (
'1079',
'John',
'Brown'
);


INSERT INTO flight
VALUES (
'1080',
'340',
'2020-12-11 06:30:00',
'SEA',
96,
'2020-12-11 07:00:00',
'JFK',
54,
'2020-12-11 10:00:00',
'Scheduled',
0,
100,
0,
100,
0,
100,
TRUE,
TRUE
);


INSERT INTO pilot (flight_id, first_name, last_name)
VALUES (
'1080',
'Mason',
'Davis'
);


INSERT INTO flight
VALUES (
'1081',
'318',
'2020-12-11 08:30:00',
'ORD',
76,
'2020-12-11 09:00:00',
'DFW',
16,
'2020-12-11 12:00:00',
'Scheduled',
0,
50,
0,
50,
0,
50,
FALSE,
FALSE
);


INSERT INTO pilot (flight_id, first_name, last_name)
VALUES (
'1081',
'Noah',
'Harris'
);


INSERT INTO flight
VALUES (
'1082',
'330',
'2020-12-11 12:30:00',
'SFO',
31,
'2020-12-11 13:00:00',
'ATL',
69,
'2020-12-11 16:00:00',
'Scheduled',
0,
100,
0,
100,
0,
100,
TRUE,
TRUE
);


INSERT INTO pilot (flight_id, first_name, last_name)
VALUES (
'1082',
'Liam',
'Wang'
);


INSERT INTO flight
VALUES (
'1083',
'343',
'2020-12-11 11:30:00',
'JFK',
27,
'2020-12-11 12:00:00',
'ATL',
15,
'2020-12-11 15:00:00',
'Scheduled',
0,
100,
0,
100,
0,
100,
TRUE,
TRUE
);


INSERT INTO pilot (flight_id, first_name, last_name)
VALUES (
'1083',
'Liam',
'Garcia'
);


INSERT INTO flight
VALUES (
'1084',
'310',
'2020-12-11 10:30:00',
'LAS',
35,
'2020-12-11 11:00:00',
'DEN',
84,
'2020-12-11 13:00:00',
'Scheduled',
0,
100,
0,
100,
0,
100,
TRUE,
TRUE
);


INSERT INTO pilot (flight_id, first_name, last_name)
VALUES (
'1084',
'Jacob',
'Davis'
);


INSERT INTO flight
VALUES (
'1085',
'321',
'2020-12-11 05:30:00',
'LAS',
7,
'2020-12-11 06:00:00',
'ATL',
56,
'2020-12-11 08:00:00',
'Scheduled',
0,
50,
0,
50,
0,
50,
FALSE,
FALSE
);


INSERT INTO pilot (flight_id, first_name, last_name)
VALUES (
'1085',
'John',
'Garcia'
);


INSERT INTO flight
VALUES (
'1086',
'346',
'2020-12-11 09:30:00',
'LAX',
73,
'2020-12-11 10:00:00',
'DFW',
19,
'2020-12-11 13:00:00',
'Scheduled',
0,
100,
0,
100,
0,
100,
TRUE,
TRUE
);


INSERT INTO pilot (flight_id, first_name, last_name)
VALUES (
'1086',
'William',
'Lee'
);


INSERT INTO flight
VALUES (
'1087',
'342',
'2020-12-11 08:30:00',
'DEN',
72,
'2020-12-11 09:00:00',
'DFW',
103,
'2020-12-11 12:00:00',
'Scheduled',
0,
100,
0,
100,
0,
100,
TRUE,
TRUE
);


INSERT INTO pilot (flight_id, first_name, last_name)
VALUES (
'1087',
'Noah',
'Thomas'
);


INSERT INTO flight
VALUES (
'1088',
'318',
'2020-12-11 03:30:00',
'JFK',
55,
'2020-12-11 04:00:00',
'LAX',
4,
'2020-12-11 06:00:00',
'Scheduled',
0,
50,
0,
50,
0,
50,
FALSE,
FALSE
);


INSERT INTO pilot (flight_id, first_name, last_name)
VALUES (
'1088',
'Ethan',
'Brown'
);


INSERT INTO flight
VALUES (
'1089',
'321',
'2020-12-11 12:30:00',
'LAS',
11,
'2020-12-11 13:00:00',
'MCO',
16,
'2020-12-11 16:00:00',
'Scheduled',
0,
50,
0,
50,
0,
50,
FALSE,
FALSE
);


INSERT INTO pilot (flight_id, first_name, last_name)
VALUES (
'1089',
'John',
'Wang'
);


INSERT INTO flight
VALUES (
'1090',
'345',
'2020-12-11 10:30:00',
'LAX',
42,
'2020-12-11 11:00:00',
'SFO',
20,
'2020-12-11 13:00:00',
'Scheduled',
0,
100,
0,
100,
0,
100,
TRUE,
TRUE
);


INSERT INTO pilot (flight_id, first_name, last_name)
VALUES (
'1090',
'Michael',
'Lee'
);


INSERT INTO flight
VALUES (
'1091',
'318',
'2020-12-11 08:30:00',
'ORD',
25,
'2020-12-11 09:00:00',
'DFW',
73,
'2020-12-11 12:00:00',
'Scheduled',
0,
50,
0,
50,
0,
50,
FALSE,
FALSE
);


INSERT INTO pilot (flight_id, first_name, last_name)
VALUES (
'1091',
'Noah',
'Garcia'
);


INSERT INTO flight
VALUES (
'1092',
'310',
'2020-12-11 09:30:00',
'LAS',
56,
'2020-12-11 10:00:00',
'DEN',
104,
'2020-12-11 13:00:00',
'Scheduled',
0,
100,
0,
100,
0,
100,
TRUE,
TRUE
);


INSERT INTO pilot (flight_id, first_name, last_name)
VALUES (
'1092',
'William',
'Thomas'
);


INSERT INTO flight
VALUES (
'1093',
'318',
'2020-12-11 12:30:00',
'JFK',
46,
'2020-12-11 13:00:00',
'LAS',
107,
'2020-12-11 16:00:00',
'Scheduled',
0,
50,
0,
50,
0,
50,
FALSE,
FALSE
);


INSERT INTO pilot (flight_id, first_name, last_name)
VALUES (
'1093',
'Ethan',
'Thomas'
);


INSERT INTO flight
VALUES (
'1094',
'340',
'2020-12-11 07:30:00',
'LAS',
12,
'2020-12-11 08:00:00',
'SEA',
13,
'2020-12-11 10:00:00',
'Scheduled',
0,
100,
0,
100,
0,
100,
TRUE,
TRUE
);


INSERT INTO pilot (flight_id, first_name, last_name)
VALUES (
'1094',
'Michael',
'Smith'
);


INSERT INTO flight
VALUES (
'1095',
'318',
'2020-12-11 08:30:00',
'DFW',
3,
'2020-12-11 09:00:00',
'DEN',
2,
'2020-12-11 12:00:00',
'Scheduled',
0,
50,
0,
50,
0,
50,
FALSE,
FALSE
);


INSERT INTO pilot (flight_id, first_name, last_name)
VALUES (
'1095',
'William',
'Anderson'
);


INSERT INTO flight
VALUES (
'1096',
'340',
'2020-12-11 06:30:00',
'SEA',
111,
'2020-12-11 07:00:00',
'LAS',
50,
'2020-12-11 10:00:00',
'Scheduled',
0,
100,
0,
100,
0,
100,
TRUE,
TRUE
);


INSERT INTO pilot (flight_id, first_name, last_name)
VALUES (
'1096',
'James',
'Harris'
);


INSERT INTO flight
VALUES (
'1097',
'310',
'2020-12-11 09:30:00',
'SEA',
12,
'2020-12-11 10:00:00',
'SFO',
59,
'2020-12-11 13:00:00',
'Scheduled',
0,
100,
0,
100,
0,
100,
TRUE,
TRUE
);


INSERT INTO pilot (flight_id, first_name, last_name)
VALUES (
'1097',
'Liam',
'Davis'
);


INSERT INTO flight
VALUES (
'1098',
'346',
'2020-12-11 07:30:00',
'ATL',
60,
'2020-12-11 08:00:00',
'MCO',
53,
'2020-12-11 10:00:00',
'Scheduled',
0,
100,
0,
100,
0,
100,
TRUE,
TRUE
);


INSERT INTO pilot (flight_id, first_name, last_name)
VALUES (
'1098',
'Alex',
'Brown'
);


INSERT INTO flight
VALUES (
'1099',
'321',
'2020-12-11 07:30:00',
'SFO',
97,
'2020-12-11 08:00:00',
'JFK',
48,
'2020-12-11 10:00:00',
'Scheduled',
0,
50,
0,
50,
0,
50,
FALSE,
FALSE
);


INSERT INTO pilot (flight_id, first_name, last_name)
VALUES (
'1099',
'William',
'Anderson'
);


INSERT INTO flight
VALUES (
'1100',
'321',
'2020-12-10 09:30:00',
'ATL',
17,
'2020-12-10 10:00:00',
'MCO',
29,
'2020-12-10 13:00:00',
'Scheduled',
0,
50,
0,
50,
0,
50,
FALSE,
FALSE
);


INSERT INTO pilot (flight_id, first_name, last_name)
VALUES (
'1100',
'Michael',
'Thomas'
);


INSERT INTO flight
VALUES (
'1101',
'318',
'2020-12-12 03:30:00',
'DFW',
1,
'2020-12-12 04:00:00',
'SFO',
48,
'2020-12-12 06:00:00',
'Scheduled',
0,
50,
0,
50,
0,
50,
FALSE,
FALSE
);


INSERT INTO pilot (flight_id, first_name, last_name)
VALUES (
'1101',
'Liam',
'Wang'
);


INSERT INTO flight
VALUES (
'1102',
'321',
'2020-12-12 11:30:00',
'LAS',
74,
'2020-12-12 12:00:00',
'MCO',
92,
'2020-12-12 15:00:00',
'Scheduled',
0,
50,
0,
50,
0,
50,
FALSE,
FALSE
);


INSERT INTO pilot (flight_id, first_name, last_name)
VALUES (
'1102',
'Alex',
'Garcia'
);


INSERT INTO flight
VALUES (
'1103',
'321',
'2020-12-12 12:30:00',
'SFO',
77,
'2020-12-12 13:00:00',
'LAX',
65,
'2020-12-12 16:00:00',
'Scheduled',
0,
50,
0,
50,
0,
50,
FALSE,
FALSE
);


INSERT INTO pilot (flight_id, first_name, last_name)
VALUES (
'1103',
'William',
'Davis'
);


INSERT INTO flight
VALUES (
'1104',
'330',
'2020-12-12 11:30:00',
'ORD',
92,
'2020-12-12 12:00:00',
'MCO',
7,
'2020-12-12 15:00:00',
'Scheduled',
0,
100,
0,
100,
0,
100,
TRUE,
TRUE
);


INSERT INTO pilot (flight_id, first_name, last_name)
VALUES (
'1104',
'Liam',
'Lee'
);


INSERT INTO flight
VALUES (
'1105',
'342',
'2020-12-12 07:30:00',
'DEN',
68,
'2020-12-12 08:00:00',
'DFW',
28,
'2020-12-12 10:00:00',
'Scheduled',
0,
100,
0,
100,
0,
100,
TRUE,
TRUE
);


INSERT INTO pilot (flight_id, first_name, last_name)
VALUES (
'1105',
'Alex',
'Garcia'
);


INSERT INTO flight
VALUES (
'1106',
'340',
'2020-12-12 12:30:00',
'LAS',
95,
'2020-12-12 13:00:00',
'LAX',
93,
'2020-12-12 16:00:00',
'Scheduled',
0,
100,
0,
100,
0,
100,
TRUE,
TRUE
);


INSERT INTO pilot (flight_id, first_name, last_name)
VALUES (
'1106',
'William',
'Smith'
);


INSERT INTO flight
VALUES (
'1107',
'321',
'2020-12-12 03:30:00',
'ATL',
13,
'2020-12-12 04:00:00',
'DFW',
83,
'2020-12-12 06:00:00',
'Scheduled',
0,
50,
0,
50,
0,
50,
FALSE,
FALSE
);


INSERT INTO pilot (flight_id, first_name, last_name)
VALUES (
'1107',
'Ethan',
'Harris'
);


INSERT INTO flight
VALUES (
'1108',
'345',
'2020-12-12 05:30:00',
'SFO',
80,
'2020-12-12 06:00:00',
'LAX',
105,
'2020-12-12 08:00:00',
'Scheduled',
0,
100,
0,
100,
0,
100,
TRUE,
TRUE
);


INSERT INTO pilot (flight_id, first_name, last_name)
VALUES (
'1108',
'Ethan',
'Lee'
);


INSERT INTO flight
VALUES (
'1109',
'340',
'2020-12-12 12:30:00',
'SEA',
107,
'2020-12-12 13:00:00',
'DEN',
80,
'2020-12-12 16:00:00',
'Scheduled',
0,
100,
0,
100,
0,
100,
TRUE,
TRUE
);


INSERT INTO pilot (flight_id, first_name, last_name)
VALUES (
'1109',
'Alex',
'Davis'
);


INSERT INTO flight
VALUES (
'1110',
'330',
'2020-12-12 12:30:00',
'JFK',
79,
'2020-12-12 13:00:00',
'DFW',
35,
'2020-12-12 16:00:00',
'Scheduled',
0,
100,
0,
100,
0,
100,
TRUE,
TRUE
);


INSERT INTO pilot (flight_id, first_name, last_name)
VALUES (
'1110',
'Liam',
'Harris'
);


INSERT INTO flight
VALUES (
'1111',
'345',
'2020-12-12 05:30:00',
'SFO',
81,
'2020-12-12 06:00:00',
'DFW',
91,
'2020-12-12 08:00:00',
'Scheduled',
0,
100,
0,
100,
0,
100,
TRUE,
TRUE
);


INSERT INTO pilot (flight_id, first_name, last_name)
VALUES (
'1111',
'Michael',
'Anderson'
);


INSERT INTO flight
VALUES (
'1112',
'330',
'2020-12-12 05:30:00',
'JFK',
19,
'2020-12-12 06:00:00',
'DFW',
6,
'2020-12-12 08:00:00',
'Scheduled',
0,
100,
0,
100,
0,
100,
TRUE,
TRUE
);


INSERT INTO pilot (flight_id, first_name, last_name)
VALUES (
'1112',
'Mason',
'Smith'
);


INSERT INTO flight
VALUES (
'1113',
'346',
'2020-12-12 11:30:00',
'DEN',
37,
'2020-12-12 12:00:00',
'ATL',
110,
'2020-12-12 15:00:00',
'Scheduled',
0,
100,
0,
100,
0,
100,
TRUE,
TRUE
);


INSERT INTO pilot (flight_id, first_name, last_name)
VALUES (
'1113',
'Noah',
'Thomas'
);


INSERT INTO flight
VALUES (
'1114',
'343',
'2020-12-12 11:30:00',
'JFK',
22,
'2020-12-12 12:00:00',
'LAS',
47,
'2020-12-12 15:00:00',
'Scheduled',
0,
100,
0,
100,
0,
100,
TRUE,
TRUE
);


INSERT INTO pilot (flight_id, first_name, last_name)
VALUES (
'1114',
'Michael',
'Harris'
);


INSERT INTO flight
VALUES (
'1115',
'342',
'2020-12-12 03:30:00',
'SEA',
7,
'2020-12-12 04:00:00',
'LAX',
76,
'2020-12-12 06:00:00',
'Scheduled',
0,
100,
0,
100,
0,
100,
TRUE,
TRUE
);


INSERT INTO pilot (flight_id, first_name, last_name)
VALUES (
'1115',
'Mason',
'Brown'
);


INSERT INTO flight
VALUES (
'1116',
'321',
'2020-12-12 08:30:00',
'LAX',
7,
'2020-12-12 09:00:00',
'MCO',
4,
'2020-12-12 12:00:00',
'Scheduled',
0,
50,
0,
50,
0,
50,
FALSE,
FALSE
);


INSERT INTO pilot (flight_id, first_name, last_name)
VALUES (
'1116',
'William',
'Garcia'
);


INSERT INTO flight
VALUES (
'1117',
'340',
'2020-12-12 08:30:00',
'SFO',
55,
'2020-12-12 09:00:00',
'MCO',
38,
'2020-12-12 12:00:00',
'Scheduled',
0,
100,
0,
100,
0,
100,
TRUE,
TRUE
);


INSERT INTO pilot (flight_id, first_name, last_name)
VALUES (
'1117',
'John',
'Smith'
);


INSERT INTO flight
VALUES (
'1118',
'310',
'2020-12-12 03:30:00',
'DFW',
41,
'2020-12-12 04:00:00',
'LAS',
73,
'2020-12-12 06:00:00',
'Scheduled',
0,
100,
0,
100,
0,
100,
TRUE,
TRUE
);


INSERT INTO pilot (flight_id, first_name, last_name)
VALUES (
'1118',
'John',
'Harris'
);


INSERT INTO flight
VALUES (
'1119',
'345',
'2020-12-12 12:30:00',
'SFO',
90,
'2020-12-12 13:00:00',
'LAS',
70,
'2020-12-12 16:00:00',
'Scheduled',
0,
100,
0,
100,
0,
100,
TRUE,
TRUE
);


INSERT INTO pilot (flight_id, first_name, last_name)
VALUES (
'1119',
'James',
'Lee'
);


INSERT INTO flight
VALUES (
'1120',
'346',
'2020-12-12 03:30:00',
'JFK',
88,
'2020-12-12 04:00:00',
'SFO',
100,
'2020-12-12 06:00:00',
'Scheduled',
0,
100,
0,
100,
0,
100,
TRUE,
TRUE
);


INSERT INTO pilot (flight_id, first_name, last_name)
VALUES (
'1120',
'Alex',
'Thomas'
);


INSERT INTO flight
VALUES (
'1121',
'342',
'2020-12-12 11:30:00',
'SFO',
106,
'2020-12-12 12:00:00',
'DEN',
64,
'2020-12-12 15:00:00',
'Scheduled',
0,
100,
0,
100,
0,
100,
TRUE,
TRUE
);


INSERT INTO pilot (flight_id, first_name, last_name)
VALUES (
'1121',
'Noah',
'Anderson'
);


INSERT INTO flight
VALUES (
'1122',
'319',
'2020-12-12 06:30:00',
'JFK',
60,
'2020-12-12 07:00:00',
'DFW',
107,
'2020-12-12 10:00:00',
'Scheduled',
0,
50,
0,
50,
0,
50,
FALSE,
FALSE
);


INSERT INTO pilot (flight_id, first_name, last_name)
VALUES (
'1122',
'Jacob',
'Miller'
);


INSERT INTO flight
VALUES (
'1123',
'345',
'2020-12-12 04:30:00',
'LAX',
42,
'2020-12-12 05:00:00',
'JFK',
41,
'2020-12-12 07:00:00',
'Scheduled',
0,
100,
0,
100,
0,
100,
TRUE,
TRUE
);


INSERT INTO pilot (flight_id, first_name, last_name)
VALUES (
'1123',
'John',
'Harris'
);


INSERT INTO flight
VALUES (
'1124',
'340',
'2020-12-12 11:30:00',
'SFO',
106,
'2020-12-12 12:00:00',
'ATL',
28,
'2020-12-12 15:00:00',
'Scheduled',
0,
100,
0,
100,
0,
100,
TRUE,
TRUE
);


INSERT INTO pilot (flight_id, first_name, last_name)
VALUES (
'1124',
'Mason',
'Brown'
);


INSERT INTO flight
VALUES (
'1125',
'340',
'2020-12-12 05:30:00',
'SFO',
94,
'2020-12-12 06:00:00',
'LAS',
33,
'2020-12-12 08:00:00',
'Scheduled',
0,
100,
0,
100,
0,
100,
TRUE,
TRUE
);


INSERT INTO pilot (flight_id, first_name, last_name)
VALUES (
'1125',
'Mason',
'Lee'
);


INSERT INTO flight
VALUES (
'1126',
'318',
'2020-12-12 05:30:00',
'JFK',
66,
'2020-12-12 06:00:00',
'ATL',
81,
'2020-12-12 08:00:00',
'Scheduled',
0,
50,
0,
50,
0,
50,
FALSE,
FALSE
);


INSERT INTO pilot (flight_id, first_name, last_name)
VALUES (
'1126',
'Alex',
'Wang'
);


INSERT INTO flight
VALUES (
'1127',
'340',
'2020-12-12 04:30:00',
'SFO',
43,
'2020-12-12 05:00:00',
'DEN',
24,
'2020-12-12 07:00:00',
'Scheduled',
0,
100,
0,
100,
0,
100,
TRUE,
TRUE
);


INSERT INTO pilot (flight_id, first_name, last_name)
VALUES (
'1127',
'Liam',
'Garcia'
);


INSERT INTO flight
VALUES (
'1128',
'321',
'2020-12-12 06:30:00',
'MCO',
104,
'2020-12-12 07:00:00',
'JFK',
17,
'2020-12-12 10:00:00',
'Scheduled',
0,
50,
0,
50,
0,
50,
FALSE,
FALSE
);


INSERT INTO pilot (flight_id, first_name, last_name)
VALUES (
'1128',
'Mason',
'Garcia'
);


INSERT INTO flight
VALUES (
'1129',
'346',
'2020-12-12 09:30:00',
'DFW',
84,
'2020-12-12 10:00:00',
'JFK',
27,
'2020-12-12 13:00:00',
'Scheduled',
0,
100,
0,
100,
0,
100,
TRUE,
TRUE
);


INSERT INTO pilot (flight_id, first_name, last_name)
VALUES (
'1129',
'James',
'Miller'
);


INSERT INTO flight
VALUES (
'1130',
'345',
'2020-12-12 11:30:00',
'ORD',
39,
'2020-12-12 12:00:00',
'MCO',
94,
'2020-12-12 15:00:00',
'Scheduled',
0,
100,
0,
100,
0,
100,
TRUE,
TRUE
);


INSERT INTO pilot (flight_id, first_name, last_name)
VALUES (
'1130',
'Noah',
'Davis'
);


INSERT INTO flight
VALUES (
'1131',
'346',
'2020-12-12 10:30:00',
'SFO',
100,
'2020-12-12 11:00:00',
'SEA',
73,
'2020-12-12 13:00:00',
'Scheduled',
0,
100,
0,
100,
0,
100,
TRUE,
TRUE
);


INSERT INTO pilot (flight_id, first_name, last_name)
VALUES (
'1131',
'Noah',
'Brown'
);


INSERT INTO flight
VALUES (
'1132',
'340',
'2020-12-12 10:30:00',
'LAX',
19,
'2020-12-12 11:00:00',
'LAS',
25,
'2020-12-12 13:00:00',
'Scheduled',
0,
100,
0,
100,
0,
100,
TRUE,
TRUE
);


INSERT INTO pilot (flight_id, first_name, last_name)
VALUES (
'1132',
'Noah',
'Davis'
);


INSERT INTO flight
VALUES (
'1133',
'321',
'2020-12-12 09:30:00',
'JFK',
84,
'2020-12-12 10:00:00',
'DFW',
21,
'2020-12-12 13:00:00',
'Scheduled',
0,
50,
0,
50,
0,
50,
FALSE,
FALSE
);


INSERT INTO pilot (flight_id, first_name, last_name)
VALUES (
'1133',
'Ethan',
'Lee'
);


INSERT INTO flight
VALUES (
'1134',
'318',
'2020-12-12 04:30:00',
'LAS',
58,
'2020-12-12 05:00:00',
'DEN',
99,
'2020-12-12 07:00:00',
'Scheduled',
0,
50,
0,
50,
0,
50,
FALSE,
FALSE
);


INSERT INTO pilot (flight_id, first_name, last_name)
VALUES (
'1134',
'Alex',
'Garcia'
);


INSERT INTO flight
VALUES (
'1135',
'330',
'2020-12-12 12:30:00',
'DEN',
4,
'2020-12-12 13:00:00',
'JFK',
2,
'2020-12-12 16:00:00',
'Scheduled',
0,
100,
0,
100,
0,
100,
TRUE,
TRUE
);


INSERT INTO pilot (flight_id, first_name, last_name)
VALUES (
'1135',
'Ethan',
'Anderson'
);


INSERT INTO flight
VALUES (
'1136',
'319',
'2020-12-12 10:30:00',
'DFW',
60,
'2020-12-12 11:00:00',
'JFK',
65,
'2020-12-12 13:00:00',
'Scheduled',
0,
50,
0,
50,
0,
50,
FALSE,
FALSE
);


INSERT INTO pilot (flight_id, first_name, last_name)
VALUES (
'1136',
'Noah',
'Smith'
);


INSERT INTO flight
VALUES (
'1137',
'346',
'2020-12-12 05:30:00',
'MCO',
43,
'2020-12-12 06:00:00',
'DFW',
23,
'2020-12-12 08:00:00',
'Scheduled',
0,
100,
0,
100,
0,
100,
TRUE,
TRUE
);


INSERT INTO pilot (flight_id, first_name, last_name)
VALUES (
'1137',
'Michael',
'Smith'
);


INSERT INTO flight
VALUES (
'1138',
'319',
'2020-12-12 12:30:00',
'DEN',
95,
'2020-12-12 13:00:00',
'LAS',
6,
'2020-12-12 16:00:00',
'Scheduled',
0,
50,
0,
50,
0,
50,
FALSE,
FALSE
);


INSERT INTO pilot (flight_id, first_name, last_name)
VALUES (
'1138',
'Michael',
'Thomas'
);


INSERT INTO flight
VALUES (
'1139',
'330',
'2020-12-12 12:30:00',
'ATL',
31,
'2020-12-12 13:00:00',
'DFW',
35,
'2020-12-12 16:00:00',
'Scheduled',
0,
100,
0,
100,
0,
100,
TRUE,
TRUE
);


INSERT INTO pilot (flight_id, first_name, last_name)
VALUES (
'1139',
'Mason',
'Smith'
);


INSERT INTO flight
VALUES (
'1140',
'343',
'2020-12-12 12:30:00',
'DFW',
80,
'2020-12-12 13:00:00',
'SFO',
31,
'2020-12-12 16:00:00',
'Scheduled',
0,
100,
0,
100,
0,
100,
TRUE,
TRUE
);


INSERT INTO pilot (flight_id, first_name, last_name)
VALUES (
'1140',
'James',
'Thomas'
);


INSERT INTO flight
VALUES (
'1141',
'345',
'2020-12-12 10:30:00',
'DFW',
105,
'2020-12-12 11:00:00',
'SFO',
14,
'2020-12-12 13:00:00',
'Scheduled',
0,
100,
0,
100,
0,
100,
TRUE,
TRUE
);


INSERT INTO pilot (flight_id, first_name, last_name)
VALUES (
'1141',
'Michael',
'Davis'
);


INSERT INTO flight
VALUES (
'1142',
'343',
'2020-12-12 03:30:00',
'DFW',
100,
'2020-12-12 04:00:00',
'LAS',
89,
'2020-12-12 06:00:00',
'Scheduled',
0,
100,
0,
100,
0,
100,
TRUE,
TRUE
);


INSERT INTO pilot (flight_id, first_name, last_name)
VALUES (
'1142',
'Mason',
'Davis'
);


INSERT INTO flight
VALUES (
'1143',
'318',
'2020-12-12 10:30:00',
'LAX',
57,
'2020-12-12 11:00:00',
'DFW',
69,
'2020-12-12 13:00:00',
'Scheduled',
0,
50,
0,
50,
0,
50,
FALSE,
FALSE
);


INSERT INTO pilot (flight_id, first_name, last_name)
VALUES (
'1143',
'John',
'Thomas'
);


INSERT INTO flight
VALUES (
'1144',
'340',
'2020-12-12 10:30:00',
'DFW',
11,
'2020-12-12 11:00:00',
'MCO',
29,
'2020-12-12 13:00:00',
'Scheduled',
0,
100,
0,
100,
0,
100,
TRUE,
TRUE
);


INSERT INTO pilot (flight_id, first_name, last_name)
VALUES (
'1144',
'Noah',
'Anderson'
);


INSERT INTO flight
VALUES (
'1145',
'321',
'2020-12-12 06:30:00',
'ORD',
89,
'2020-12-12 07:00:00',
'SFO',
21,
'2020-12-12 10:00:00',
'Scheduled',
0,
50,
0,
50,
0,
50,
FALSE,
FALSE
);


INSERT INTO pilot (flight_id, first_name, last_name)
VALUES (
'1145',
'Michael',
'Wang'
);


INSERT INTO flight
VALUES (
'1146',
'346',
'2020-12-12 07:30:00',
'LAX',
22,
'2020-12-12 08:00:00',
'SEA',
11,
'2020-12-12 10:00:00',
'Scheduled',
0,
100,
0,
100,
0,
100,
TRUE,
TRUE
);


INSERT INTO pilot (flight_id, first_name, last_name)
VALUES (
'1146',
'Alex',
'Harris'
);


INSERT INTO flight
VALUES (
'1147',
'318',
'2020-12-12 03:30:00',
'SEA',
8,
'2020-12-12 04:00:00',
'DFW',
88,
'2020-12-12 06:00:00',
'Scheduled',
0,
50,
0,
50,
0,
50,
FALSE,
FALSE
);


INSERT INTO pilot (flight_id, first_name, last_name)
VALUES (
'1147',
'James',
'Brown'
);


INSERT INTO flight
VALUES (
'1148',
'346',
'2020-12-12 11:30:00',
'SFO',
4,
'2020-12-12 12:00:00',
'ORD',
8,
'2020-12-12 15:00:00',
'Scheduled',
0,
100,
0,
100,
0,
100,
TRUE,
TRUE
);


INSERT INTO pilot (flight_id, first_name, last_name)
VALUES (
'1148',
'Ethan',
'Wang'
);


INSERT INTO flight
VALUES (
'1149',
'346',
'2020-12-12 03:30:00',
'ATL',
99,
'2020-12-12 04:00:00',
'MCO',
89,
'2020-12-12 06:00:00',
'Scheduled',
0,
100,
0,
100,
0,
100,
TRUE,
TRUE
);


INSERT INTO pilot (flight_id, first_name, last_name)
VALUES (
'1149',
'Michael',
'Lee'
);


INSERT INTO flight
VALUES (
'1150',
'310',
'2020-12-10 10:30:00',
'LAX',
28,
'2020-12-10 11:00:00',
'DEN',
64,
'2020-12-10 13:00:00',
'Scheduled',
0,
100,
0,
100,
0,
100,
TRUE,
TRUE
);


INSERT INTO pilot (flight_id, first_name, last_name)
VALUES (
'1150',
'Jacob',
'Garcia'
);


INSERT INTO flight
VALUES (
'1151',
'330',
'2020-12-13 10:30:00',
'SFO',
66,
'2020-12-13 11:00:00',
'DFW',
57,
'2020-12-13 13:00:00',
'Scheduled',
0,
100,
0,
100,
0,
100,
TRUE,
TRUE
);


INSERT INTO pilot (flight_id, first_name, last_name)
VALUES (
'1151',
'Jacob',
'Davis'
);


INSERT INTO flight
VALUES (
'1152',
'319',
'2020-12-13 05:30:00',
'ATL',
102,
'2020-12-13 06:00:00',
'DEN',
12,
'2020-12-13 08:00:00',
'Scheduled',
0,
50,
0,
50,
0,
50,
FALSE,
FALSE
);


INSERT INTO pilot (flight_id, first_name, last_name)
VALUES (
'1152',
'Michael',
'Thomas'
);


INSERT INTO flight
VALUES (
'1153',
'310',
'2020-12-13 09:30:00',
'LAX',
2,
'2020-12-13 10:00:00',
'JFK',
54,
'2020-12-13 13:00:00',
'Scheduled',
0,
100,
0,
100,
0,
100,
TRUE,
TRUE
);


INSERT INTO pilot (flight_id, first_name, last_name)
VALUES (
'1153',
'James',
'Anderson'
);


INSERT INTO flight
VALUES (
'1154',
'318',
'2020-12-13 11:30:00',
'LAS',
23,
'2020-12-13 12:00:00',
'MCO',
62,
'2020-12-13 15:00:00',
'Scheduled',
0,
50,
0,
50,
0,
50,
FALSE,
FALSE
);


INSERT INTO pilot (flight_id, first_name, last_name)
VALUES (
'1154',
'Liam',
'Harris'
);


INSERT INTO flight
VALUES (
'1155',
'330',
'2020-12-13 05:30:00',
'SEA',
74,
'2020-12-13 06:00:00',
'SFO',
93,
'2020-12-13 08:00:00',
'Scheduled',
0,
100,
0,
100,
0,
100,
TRUE,
TRUE
);


INSERT INTO pilot (flight_id, first_name, last_name)
VALUES (
'1155',
'Mason',
'Miller'
);


INSERT INTO flight
VALUES (
'1156',
'342',
'2020-12-13 07:30:00',
'DEN',
22,
'2020-12-13 08:00:00',
'ORD',
75,
'2020-12-13 10:00:00',
'Scheduled',
0,
100,
0,
100,
0,
100,
TRUE,
TRUE
);


INSERT INTO pilot (flight_id, first_name, last_name)
VALUES (
'1156',
'Mason',
'Lee'
);


INSERT INTO flight
VALUES (
'1157',
'319',
'2020-12-13 11:30:00',
'ORD',
65,
'2020-12-13 12:00:00',
'MCO',
89,
'2020-12-13 15:00:00',
'Scheduled',
0,
50,
0,
50,
0,
50,
FALSE,
FALSE
);


INSERT INTO pilot (flight_id, first_name, last_name)
VALUES (
'1157',
'Ethan',
'Brown'
);


INSERT INTO flight
VALUES (
'1158',
'346',
'2020-12-13 06:30:00',
'DEN',
61,
'2020-12-13 07:00:00',
'ATL',
57,
'2020-12-13 10:00:00',
'Scheduled',
0,
100,
0,
100,
0,
100,
TRUE,
TRUE
);


INSERT INTO pilot (flight_id, first_name, last_name)
VALUES (
'1158',
'Liam',
'Smith'
);


INSERT INTO flight
VALUES (
'1159',
'310',
'2020-12-13 07:30:00',
'MCO',
45,
'2020-12-13 08:00:00',
'ORD',
107,
'2020-12-13 10:00:00',
'Scheduled',
0,
100,
0,
100,
0,
100,
TRUE,
TRUE
);


INSERT INTO pilot (flight_id, first_name, last_name)
VALUES (
'1159',
'Noah',
'Wang'
);


INSERT INTO flight
VALUES (
'1160',
'330',
'2020-12-13 10:30:00',
'MCO',
80,
'2020-12-13 11:00:00',
'DEN',
108,
'2020-12-13 13:00:00',
'Scheduled',
0,
100,
0,
100,
0,
100,
TRUE,
TRUE
);


INSERT INTO pilot (flight_id, first_name, last_name)
VALUES (
'1160',
'Liam',
'Anderson'
);


INSERT INTO flight
VALUES (
'1161',
'346',
'2020-12-13 12:30:00',
'SEA',
69,
'2020-12-13 13:00:00',
'JFK',
86,
'2020-12-13 16:00:00',
'Scheduled',
0,
100,
0,
100,
0,
100,
TRUE,
TRUE
);


INSERT INTO pilot (flight_id, first_name, last_name)
VALUES (
'1161',
'Noah',
'Thomas'
);


INSERT INTO flight
VALUES (
'1162',
'318',
'2020-12-13 04:30:00',
'LAX',
83,
'2020-12-13 05:00:00',
'SFO',
89,
'2020-12-13 07:00:00',
'Scheduled',
0,
50,
0,
50,
0,
50,
FALSE,
FALSE
);


INSERT INTO pilot (flight_id, first_name, last_name)
VALUES (
'1162',
'William',
'Smith'
);


INSERT INTO flight
VALUES (
'1163',
'318',
'2020-12-13 07:30:00',
'SFO',
88,
'2020-12-13 08:00:00',
'SEA',
66,
'2020-12-13 10:00:00',
'Scheduled',
0,
50,
0,
50,
0,
50,
FALSE,
FALSE
);


INSERT INTO pilot (flight_id, first_name, last_name)
VALUES (
'1163',
'Ethan',
'Garcia'
);


INSERT INTO flight
VALUES (
'1164',
'340',
'2020-12-13 03:30:00',
'JFK',
47,
'2020-12-13 04:00:00',
'SEA',
66,
'2020-12-13 06:00:00',
'Scheduled',
0,
100,
0,
100,
0,
100,
TRUE,
TRUE
);


INSERT INTO pilot (flight_id, first_name, last_name)
VALUES (
'1164',
'Mason',
'Miller'
);


INSERT INTO flight
VALUES (
'1165',
'310',
'2020-12-13 04:30:00',
'JFK',
15,
'2020-12-13 05:00:00',
'DEN',
41,
'2020-12-13 07:00:00',
'Scheduled',
0,
100,
0,
100,
0,
100,
TRUE,
TRUE
);


INSERT INTO pilot (flight_id, first_name, last_name)
VALUES (
'1165',
'Mason',
'Anderson'
);


INSERT INTO flight
VALUES (
'1166',
'343',
'2020-12-13 09:30:00',
'LAX',
47,
'2020-12-13 10:00:00',
'MCO',
98,
'2020-12-13 13:00:00',
'Scheduled',
0,
100,
0,
100,
0,
100,
TRUE,
TRUE
);


INSERT INTO pilot (flight_id, first_name, last_name)
VALUES (
'1166',
'Liam',
'Harris'
);


INSERT INTO flight
VALUES (
'1167',
'330',
'2020-12-13 08:30:00',
'ATL',
11,
'2020-12-13 09:00:00',
'DEN',
9,
'2020-12-13 12:00:00',
'Scheduled',
0,
100,
0,
100,
0,
100,
TRUE,
TRUE
);


INSERT INTO pilot (flight_id, first_name, last_name)
VALUES (
'1167',
'Noah',
'Garcia'
);


INSERT INTO flight
VALUES (
'1168',
'343',
'2020-12-13 04:30:00',
'SEA',
55,
'2020-12-13 05:00:00',
'DEN',
87,
'2020-12-13 07:00:00',
'Scheduled',
0,
100,
0,
100,
0,
100,
TRUE,
TRUE
);


INSERT INTO pilot (flight_id, first_name, last_name)
VALUES (
'1168',
'Noah',
'Garcia'
);


INSERT INTO flight
VALUES (
'1169',
'318',
'2020-12-13 07:30:00',
'DEN',
48,
'2020-12-13 08:00:00',
'LAX',
52,
'2020-12-13 10:00:00',
'Scheduled',
0,
50,
0,
50,
0,
50,
FALSE,
FALSE
);


INSERT INTO pilot (flight_id, first_name, last_name)
VALUES (
'1169',
'John',
'Miller'
);


INSERT INTO flight
VALUES (
'1170',
'342',
'2020-12-13 07:30:00',
'ORD',
25,
'2020-12-13 08:00:00',
'LAS',
30,
'2020-12-13 10:00:00',
'Scheduled',
0,
100,
0,
100,
0,
100,
TRUE,
TRUE
);


INSERT INTO pilot (flight_id, first_name, last_name)
VALUES (
'1170',
'Michael',
'Wang'
);


INSERT INTO flight
VALUES (
'1171',
'343',
'2020-12-13 07:30:00',
'JFK',
92,
'2020-12-13 08:00:00',
'LAS',
28,
'2020-12-13 10:00:00',
'Scheduled',
0,
100,
0,
100,
0,
100,
TRUE,
TRUE
);


INSERT INTO pilot (flight_id, first_name, last_name)
VALUES (
'1171',
'Ethan',
'Garcia'
);


INSERT INTO flight
VALUES (
'1172',
'330',
'2020-12-13 06:30:00',
'ORD',
32,
'2020-12-13 07:00:00',
'LAX',
60,
'2020-12-13 10:00:00',
'Scheduled',
0,
100,
0,
100,
0,
100,
TRUE,
TRUE
);


INSERT INTO pilot (flight_id, first_name, last_name)
VALUES (
'1172',
'Mason',
'Smith'
);


INSERT INTO flight
VALUES (
'1173',
'318',
'2020-12-13 04:30:00',
'JFK',
24,
'2020-12-13 05:00:00',
'DFW',
89,
'2020-12-13 07:00:00',
'Scheduled',
0,
50,
0,
50,
0,
50,
FALSE,
FALSE
);


INSERT INTO pilot (flight_id, first_name, last_name)
VALUES (
'1173',
'Alex',
'Smith'
);


INSERT INTO flight
VALUES (
'1174',
'346',
'2020-12-13 10:30:00',
'ATL',
76,
'2020-12-13 11:00:00',
'DFW',
8,
'2020-12-13 13:00:00',
'Scheduled',
0,
100,
0,
100,
0,
100,
TRUE,
TRUE
);


INSERT INTO pilot (flight_id, first_name, last_name)
VALUES (
'1174',
'Noah',
'Garcia'
);


INSERT INTO flight
VALUES (
'1175',
'342',
'2020-12-13 05:30:00',
'ATL',
29,
'2020-12-13 06:00:00',
'SFO',
26,
'2020-12-13 08:00:00',
'Scheduled',
0,
100,
0,
100,
0,
100,
TRUE,
TRUE
);


INSERT INTO pilot (flight_id, first_name, last_name)
VALUES (
'1175',
'Alex',
'Garcia'
);


INSERT INTO flight
VALUES (
'1176',
'310',
'2020-12-13 03:30:00',
'DFW',
20,
'2020-12-13 04:00:00',
'DEN',
51,
'2020-12-13 06:00:00',
'Scheduled',
0,
100,
0,
100,
0,
100,
TRUE,
TRUE
);


INSERT INTO pilot (flight_id, first_name, last_name)
VALUES (
'1176',
'Michael',
'Smith'
);


INSERT INTO flight
VALUES (
'1177',
'321',
'2020-12-13 07:30:00',
'ATL',
36,
'2020-12-13 08:00:00',
'DFW',
107,
'2020-12-13 10:00:00',
'Scheduled',
0,
50,
0,
50,
0,
50,
FALSE,
FALSE
);


INSERT INTO pilot (flight_id, first_name, last_name)
VALUES (
'1177',
'James',
'Miller'
);


INSERT INTO flight
VALUES (
'1178',
'330',
'2020-12-13 08:30:00',
'DEN',
79,
'2020-12-13 09:00:00',
'LAS',
64,
'2020-12-13 12:00:00',
'Scheduled',
0,
100,
0,
100,
0,
100,
TRUE,
TRUE
);


INSERT INTO pilot (flight_id, first_name, last_name)
VALUES (
'1178',
'Liam',
'Anderson'
);


INSERT INTO flight
VALUES (
'1179',
'318',
'2020-12-13 09:30:00',
'SFO',
8,
'2020-12-13 10:00:00',
'DFW',
1,
'2020-12-13 13:00:00',
'Scheduled',
0,
50,
0,
50,
0,
50,
FALSE,
FALSE
);


INSERT INTO pilot (flight_id, first_name, last_name)
VALUES (
'1179',
'Mason',
'Thomas'
);


INSERT INTO flight
VALUES (
'1180',
'330',
'2020-12-13 07:30:00',
'SFO',
63,
'2020-12-13 08:00:00',
'DFW',
82,
'2020-12-13 10:00:00',
'Scheduled',
0,
100,
0,
100,
0,
100,
TRUE,
TRUE
);


INSERT INTO pilot (flight_id, first_name, last_name)
VALUES (
'1180',
'William',
'Lee'
);


INSERT INTO flight
VALUES (
'1181',
'319',
'2020-12-13 08:30:00',
'LAX',
102,
'2020-12-13 09:00:00',
'SFO',
94,
'2020-12-13 12:00:00',
'Scheduled',
0,
50,
0,
50,
0,
50,
FALSE,
FALSE
);


INSERT INTO pilot (flight_id, first_name, last_name)
VALUES (
'1181',
'Alex',
'Smith'
);


INSERT INTO flight
VALUES (
'1182',
'330',
'2020-12-13 06:30:00',
'MCO',
58,
'2020-12-13 07:00:00',
'LAX',
64,
'2020-12-13 10:00:00',
'Scheduled',
0,
100,
0,
100,
0,
100,
TRUE,
TRUE
);


INSERT INTO pilot (flight_id, first_name, last_name)
VALUES (
'1182',
'John',
'Wang'
);


INSERT INTO flight
VALUES (
'1183',
'346',
'2020-12-13 04:30:00',
'SFO',
58,
'2020-12-13 05:00:00',
'LAX',
89,
'2020-12-13 07:00:00',
'Scheduled',
0,
100,
0,
100,
0,
100,
TRUE,
TRUE
);


INSERT INTO pilot (flight_id, first_name, last_name)
VALUES (
'1183',
'John',
'Anderson'
);


INSERT INTO flight
VALUES (
'1184',
'340',
'2020-12-13 10:30:00',
'DFW',
65,
'2020-12-13 11:00:00',
'ORD',
29,
'2020-12-13 13:00:00',
'Scheduled',
0,
100,
0,
100,
0,
100,
TRUE,
TRUE
);


INSERT INTO pilot (flight_id, first_name, last_name)
VALUES (
'1184',
'William',
'Garcia'
);


INSERT INTO flight
VALUES (
'1185',
'346',
'2020-12-13 03:30:00',
'DEN',
16,
'2020-12-13 04:00:00',
'LAS',
1,
'2020-12-13 06:00:00',
'Scheduled',
0,
100,
0,
100,
0,
100,
TRUE,
TRUE
);


INSERT INTO pilot (flight_id, first_name, last_name)
VALUES (
'1185',
'Michael',
'Wang'
);


INSERT INTO flight
VALUES (
'1186',
'310',
'2020-12-13 08:30:00',
'DFW',
14,
'2020-12-13 09:00:00',
'DEN',
84,
'2020-12-13 12:00:00',
'Scheduled',
0,
100,
0,
100,
0,
100,
TRUE,
TRUE
);


INSERT INTO pilot (flight_id, first_name, last_name)
VALUES (
'1186',
'Michael',
'Garcia'
);


INSERT INTO flight
VALUES (
'1187',
'310',
'2020-12-13 08:30:00',
'SFO',
81,
'2020-12-13 09:00:00',
'ORD',
87,
'2020-12-13 12:00:00',
'Scheduled',
0,
100,
0,
100,
0,
100,
TRUE,
TRUE
);


INSERT INTO pilot (flight_id, first_name, last_name)
VALUES (
'1187',
'Liam',
'Garcia'
);


INSERT INTO flight
VALUES (
'1188',
'345',
'2020-12-13 04:30:00',
'SFO',
33,
'2020-12-13 05:00:00',
'JFK',
11,
'2020-12-13 07:00:00',
'Scheduled',
0,
100,
0,
100,
0,
100,
TRUE,
TRUE
);


INSERT INTO pilot (flight_id, first_name, last_name)
VALUES (
'1188',
'William',
'Davis'
);


INSERT INTO flight
VALUES (
'1189',
'343',
'2020-12-13 12:30:00',
'MCO',
8,
'2020-12-13 13:00:00',
'ATL',
89,
'2020-12-13 16:00:00',
'Scheduled',
0,
100,
0,
100,
0,
100,
TRUE,
TRUE
);


INSERT INTO pilot (flight_id, first_name, last_name)
VALUES (
'1189',
'Noah',
'Anderson'
);


INSERT INTO flight
VALUES (
'1190',
'340',
'2020-12-13 05:30:00',
'SEA',
4,
'2020-12-13 06:00:00',
'LAS',
104,
'2020-12-13 08:00:00',
'Scheduled',
0,
100,
0,
100,
0,
100,
TRUE,
TRUE
);


INSERT INTO pilot (flight_id, first_name, last_name)
VALUES (
'1190',
'Jacob',
'Anderson'
);


INSERT INTO flight
VALUES (
'1191',
'342',
'2020-12-13 06:30:00',
'LAS',
92,
'2020-12-13 07:00:00',
'LAX',
25,
'2020-12-13 10:00:00',
'Scheduled',
0,
100,
0,
100,
0,
100,
TRUE,
TRUE
);


INSERT INTO pilot (flight_id, first_name, last_name)
VALUES (
'1191',
'James',
'Brown'
);


INSERT INTO flight
VALUES (
'1192',
'330',
'2020-12-13 05:30:00',
'DEN',
51,
'2020-12-13 06:00:00',
'MCO',
109,
'2020-12-13 08:00:00',
'Scheduled',
0,
100,
0,
100,
0,
100,
TRUE,
TRUE
);


INSERT INTO pilot (flight_id, first_name, last_name)
VALUES (
'1192',
'Michael',
'Harris'
);


INSERT INTO flight
VALUES (
'1193',
'319',
'2020-12-13 09:30:00',
'SEA',
19,
'2020-12-13 10:00:00',
'LAX',
25,
'2020-12-13 13:00:00',
'Scheduled',
0,
50,
0,
50,
0,
50,
FALSE,
FALSE
);


INSERT INTO pilot (flight_id, first_name, last_name)
VALUES (
'1193',
'Liam',
'Davis'
);


INSERT INTO flight
VALUES (
'1194',
'318',
'2020-12-13 09:30:00',
'JFK',
44,
'2020-12-13 10:00:00',
'DFW',
33,
'2020-12-13 13:00:00',
'Scheduled',
0,
50,
0,
50,
0,
50,
FALSE,
FALSE
);


INSERT INTO pilot (flight_id, first_name, last_name)
VALUES (
'1194',
'Michael',
'Harris'
);


INSERT INTO flight
VALUES (
'1195',
'318',
'2020-12-13 09:30:00',
'SFO',
52,
'2020-12-13 10:00:00',
'LAS',
73,
'2020-12-13 13:00:00',
'Scheduled',
0,
50,
0,
50,
0,
50,
FALSE,
FALSE
);


INSERT INTO pilot (flight_id, first_name, last_name)
VALUES (
'1195',
'John',
'Davis'
);


INSERT INTO flight
VALUES (
'1196',
'346',
'2020-12-13 06:30:00',
'ORD',
98,
'2020-12-13 07:00:00',
'LAS',
4,
'2020-12-13 10:00:00',
'Scheduled',
0,
100,
0,
100,
0,
100,
TRUE,
TRUE
);


INSERT INTO pilot (flight_id, first_name, last_name)
VALUES (
'1196',
'Jacob',
'Brown'
);


INSERT INTO flight
VALUES (
'1197',
'340',
'2020-12-13 07:30:00',
'ORD',
60,
'2020-12-13 08:00:00',
'LAX',
60,
'2020-12-13 10:00:00',
'Scheduled',
0,
100,
0,
100,
0,
100,
TRUE,
TRUE
);


INSERT INTO pilot (flight_id, first_name, last_name)
VALUES (
'1197',
'Ethan',
'Brown'
);


INSERT INTO flight
VALUES (
'1198',
'346',
'2020-12-13 06:30:00',
'DEN',
69,
'2020-12-13 07:00:00',
'ATL',
6,
'2020-12-13 10:00:00',
'Scheduled',
0,
100,
0,
100,
0,
100,
TRUE,
TRUE
);


INSERT INTO pilot (flight_id, first_name, last_name)
VALUES (
'1198',
'Noah',
'Harris'
);


INSERT INTO flight
VALUES (
'1199',
'330',
'2020-12-13 11:30:00',
'DEN',
36,
'2020-12-13 12:00:00',
'SEA',
56,
'2020-12-13 15:00:00',
'Scheduled',
0,
100,
0,
100,
0,
100,
TRUE,
TRUE
);


INSERT INTO pilot (flight_id, first_name, last_name)
VALUES (
'1199',
'Jacob',
'Harris'
);


INSERT INTO flight
VALUES (
'1200',
'319',
'2020-12-10 11:30:00',
'DEN',
72,
'2020-12-10 12:00:00',
'JFK',
83,
'2020-12-10 15:00:00',
'Scheduled',
0,
50,
0,
50,
0,
50,
FALSE,
FALSE
);


INSERT INTO pilot (flight_id, first_name, last_name)
VALUES (
'1200',
'Mason',
'Thomas'
);


INSERT INTO flight
VALUES (
'1201',
'330',
'2020-12-14 06:30:00',
'DFW',
14,
'2020-12-14 07:00:00',
'SEA',
68,
'2020-12-14 10:00:00',
'Scheduled',
0,
100,
0,
100,
0,
100,
TRUE,
TRUE
);


INSERT INTO pilot (flight_id, first_name, last_name)
VALUES (
'1201',
'Liam',
'Thomas'
);


INSERT INTO flight
VALUES (
'1202',
'346',
'2020-12-14 04:30:00',
'SFO',
65,
'2020-12-14 05:00:00',
'DEN',
77,
'2020-12-14 07:00:00',
'Scheduled',
0,
100,
0,
100,
0,
100,
TRUE,
TRUE
);


INSERT INTO pilot (flight_id, first_name, last_name)
VALUES (
'1202',
'Liam',
'Wang'
);


INSERT INTO flight
VALUES (
'1203',
'310',
'2020-12-14 06:30:00',
'ATL',
37,
'2020-12-14 07:00:00',
'SFO',
59,
'2020-12-14 10:00:00',
'Scheduled',
0,
100,
0,
100,
0,
100,
TRUE,
TRUE
);


INSERT INTO pilot (flight_id, first_name, last_name)
VALUES (
'1203',
'William',
'Miller'
);


INSERT INTO flight
VALUES (
'1204',
'330',
'2020-12-14 07:30:00',
'MCO',
83,
'2020-12-14 08:00:00',
'ORD',
89,
'2020-12-14 10:00:00',
'Scheduled',
0,
100,
0,
100,
0,
100,
TRUE,
TRUE
);


INSERT INTO pilot (flight_id, first_name, last_name)
VALUES (
'1204',
'Liam',
'Thomas'
);


INSERT INTO flight
VALUES (
'1205',
'346',
'2020-12-14 06:30:00',
'SFO',
37,
'2020-12-14 07:00:00',
'JFK',
73,
'2020-12-14 10:00:00',
'Scheduled',
0,
100,
0,
100,
0,
100,
TRUE,
TRUE
);


INSERT INTO pilot (flight_id, first_name, last_name)
VALUES (
'1205',
'Noah',
'Smith'
);


INSERT INTO flight
VALUES (
'1206',
'319',
'2020-12-14 07:30:00',
'SFO',
8,
'2020-12-14 08:00:00',
'SEA',
55,
'2020-12-14 10:00:00',
'Scheduled',
0,
50,
0,
50,
0,
50,
FALSE,
FALSE
);


INSERT INTO pilot (flight_id, first_name, last_name)
VALUES (
'1206',
'Noah',
'Lee'
);


INSERT INTO flight
VALUES (
'1207',
'346',
'2020-12-14 09:30:00',
'LAX',
4,
'2020-12-14 10:00:00',
'SEA',
56,
'2020-12-14 13:00:00',
'Scheduled',
0,
100,
0,
100,
0,
100,
TRUE,
TRUE
);


INSERT INTO pilot (flight_id, first_name, last_name)
VALUES (
'1207',
'Michael',
'Davis'
);


INSERT INTO flight
VALUES (
'1208',
'346',
'2020-12-14 03:30:00',
'MCO',
21,
'2020-12-14 04:00:00',
'ORD',
105,
'2020-12-14 06:00:00',
'Scheduled',
0,
100,
0,
100,
0,
100,
TRUE,
TRUE
);


INSERT INTO pilot (flight_id, first_name, last_name)
VALUES (
'1208',
'Liam',
'Miller'
);


INSERT INTO flight
VALUES (
'1209',
'330',
'2020-12-14 07:30:00',
'DEN',
10,
'2020-12-14 08:00:00',
'LAX',
100,
'2020-12-14 10:00:00',
'Scheduled',
0,
100,
0,
100,
0,
100,
TRUE,
TRUE
);


INSERT INTO pilot (flight_id, first_name, last_name)
VALUES (
'1209',
'James',
'Brown'
);


INSERT INTO flight
VALUES (
'1210',
'310',
'2020-12-14 07:30:00',
'LAS',
40,
'2020-12-14 08:00:00',
'LAX',
86,
'2020-12-14 10:00:00',
'Scheduled',
0,
100,
0,
100,
0,
100,
TRUE,
TRUE
);


INSERT INTO pilot (flight_id, first_name, last_name)
VALUES (
'1210',
'Ethan',
'Davis'
);


INSERT INTO flight
VALUES (
'1211',
'340',
'2020-12-14 08:30:00',
'JFK',
33,
'2020-12-14 09:00:00',
'ORD',
87,
'2020-12-14 12:00:00',
'Scheduled',
0,
100,
0,
100,
0,
100,
TRUE,
TRUE
);


INSERT INTO pilot (flight_id, first_name, last_name)
VALUES (
'1211',
'Noah',
'Brown'
);


INSERT INTO flight
VALUES (
'1212',
'321',
'2020-12-14 12:30:00',
'MCO',
94,
'2020-12-14 13:00:00',
'JFK',
63,
'2020-12-14 16:00:00',
'Scheduled',
0,
50,
0,
50,
0,
50,
FALSE,
FALSE
);


INSERT INTO pilot (flight_id, first_name, last_name)
VALUES (
'1212',
'Alex',
'Smith'
);


INSERT INTO flight
VALUES (
'1213',
'310',
'2020-12-14 08:30:00',
'ORD',
31,
'2020-12-14 09:00:00',
'ATL',
47,
'2020-12-14 12:00:00',
'Scheduled',
0,
100,
0,
100,
0,
100,
TRUE,
TRUE
);


INSERT INTO pilot (flight_id, first_name, last_name)
VALUES (
'1213',
'James',
'Davis'
);


INSERT INTO flight
VALUES (
'1214',
'345',
'2020-12-14 04:30:00',
'SEA',
22,
'2020-12-14 05:00:00',
'DFW',
64,
'2020-12-14 07:00:00',
'Scheduled',
0,
100,
0,
100,
0,
100,
TRUE,
TRUE
);


INSERT INTO pilot (flight_id, first_name, last_name)
VALUES (
'1214',
'Mason',
'Smith'
);


INSERT INTO flight
VALUES (
'1215',
'340',
'2020-12-14 09:30:00',
'DEN',
11,
'2020-12-14 10:00:00',
'SEA',
64,
'2020-12-14 13:00:00',
'Scheduled',
0,
100,
0,
100,
0,
100,
TRUE,
TRUE
);


INSERT INTO pilot (flight_id, first_name, last_name)
VALUES (
'1215',
'James',
'Wang'
);


INSERT INTO flight
VALUES (
'1216',
'318',
'2020-12-14 11:30:00',
'SFO',
86,
'2020-12-14 12:00:00',
'ORD',
99,
'2020-12-14 15:00:00',
'Scheduled',
0,
50,
0,
50,
0,
50,
FALSE,
FALSE
);


INSERT INTO pilot (flight_id, first_name, last_name)
VALUES (
'1216',
'James',
'Harris'
);


INSERT INTO flight
VALUES (
'1217',
'346',
'2020-12-14 05:30:00',
'JFK',
4,
'2020-12-14 06:00:00',
'LAX',
87,
'2020-12-14 08:00:00',
'Scheduled',
0,
100,
0,
100,
0,
100,
TRUE,
TRUE
);


INSERT INTO pilot (flight_id, first_name, last_name)
VALUES (
'1217',
'Alex',
'Anderson'
);


INSERT INTO flight
VALUES (
'1218',
'343',
'2020-12-14 10:30:00',
'ORD',
89,
'2020-12-14 11:00:00',
'DFW',
32,
'2020-12-14 13:00:00',
'Scheduled',
0,
100,
0,
100,
0,
100,
TRUE,
TRUE
);


INSERT INTO pilot (flight_id, first_name, last_name)
VALUES (
'1218',
'Mason',
'Brown'
);


INSERT INTO flight
VALUES (
'1219',
'310',
'2020-12-14 11:30:00',
'ATL',
99,
'2020-12-14 12:00:00',
'ORD',
22,
'2020-12-14 15:00:00',
'Scheduled',
0,
100,
0,
100,
0,
100,
TRUE,
TRUE
);


INSERT INTO pilot (flight_id, first_name, last_name)
VALUES (
'1219',
'Jacob',
'Anderson'
);


INSERT INTO flight
VALUES (
'1220',
'310',
'2020-12-14 06:30:00',
'SFO',
83,
'2020-12-14 07:00:00',
'DEN',
93,
'2020-12-14 10:00:00',
'Scheduled',
0,
100,
0,
100,
0,
100,
TRUE,
TRUE
);


INSERT INTO pilot (flight_id, first_name, last_name)
VALUES (
'1220',
'William',
'Lee'
);


INSERT INTO flight
VALUES (
'1221',
'340',
'2020-12-14 10:30:00',
'SFO',
91,
'2020-12-14 11:00:00',
'ORD',
31,
'2020-12-14 13:00:00',
'Scheduled',
0,
100,
0,
100,
0,
100,
TRUE,
TRUE
);


INSERT INTO pilot (flight_id, first_name, last_name)
VALUES (
'1221',
'William',
'Wang'
);


INSERT INTO flight
VALUES (
'1222',
'321',
'2020-12-14 12:30:00',
'DFW',
53,
'2020-12-14 13:00:00',
'LAX',
101,
'2020-12-14 16:00:00',
'Scheduled',
0,
50,
0,
50,
0,
50,
FALSE,
FALSE
);


INSERT INTO pilot (flight_id, first_name, last_name)
VALUES (
'1222',
'Jacob',
'Davis'
);


INSERT INTO flight
VALUES (
'1223',
'310',
'2020-12-14 11:30:00',
'MCO',
76,
'2020-12-14 12:00:00',
'DEN',
17,
'2020-12-14 15:00:00',
'Scheduled',
0,
100,
0,
100,
0,
100,
TRUE,
TRUE
);


INSERT INTO pilot (flight_id, first_name, last_name)
VALUES (
'1223',
'Liam',
'Thomas'
);


INSERT INTO flight
VALUES (
'1224',
'340',
'2020-12-14 12:30:00',
'ATL',
23,
'2020-12-14 13:00:00',
'ORD',
31,
'2020-12-14 16:00:00',
'Scheduled',
0,
100,
0,
100,
0,
100,
TRUE,
TRUE
);


INSERT INTO pilot (flight_id, first_name, last_name)
VALUES (
'1224',
'Noah',
'Harris'
);


INSERT INTO flight
VALUES (
'1225',
'321',
'2020-12-14 11:30:00',
'LAS',
74,
'2020-12-14 12:00:00',
'SEA',
69,
'2020-12-14 15:00:00',
'Scheduled',
0,
50,
0,
50,
0,
50,
FALSE,
FALSE
);


INSERT INTO pilot (flight_id, first_name, last_name)
VALUES (
'1225',
'Mason',
'Lee'
);


INSERT INTO flight
VALUES (
'1226',
'319',
'2020-12-14 11:30:00',
'LAS',
24,
'2020-12-14 12:00:00',
'DEN',
5,
'2020-12-14 15:00:00',
'Scheduled',
0,
50,
0,
50,
0,
50,
FALSE,
FALSE
);


INSERT INTO pilot (flight_id, first_name, last_name)
VALUES (
'1226',
'Alex',
'Brown'
);


INSERT INTO flight
VALUES (
'1227',
'319',
'2020-12-14 07:30:00',
'DEN',
97,
'2020-12-14 08:00:00',
'DFW',
102,
'2020-12-14 10:00:00',
'Scheduled',
0,
50,
0,
50,
0,
50,
FALSE,
FALSE
);


INSERT INTO pilot (flight_id, first_name, last_name)
VALUES (
'1227',
'William',
'Anderson'
);


INSERT INTO flight
VALUES (
'1228',
'343',
'2020-12-14 11:30:00',
'DFW',
49,
'2020-12-14 12:00:00',
'JFK',
74,
'2020-12-14 15:00:00',
'Scheduled',
0,
100,
0,
100,
0,
100,
TRUE,
TRUE
);


INSERT INTO pilot (flight_id, first_name, last_name)
VALUES (
'1228',
'Ethan',
'Smith'
);


INSERT INTO flight
VALUES (
'1229',
'319',
'2020-12-14 08:30:00',
'LAX',
94,
'2020-12-14 09:00:00',
'SFO',
104,
'2020-12-14 12:00:00',
'Scheduled',
0,
50,
0,
50,
0,
50,
FALSE,
FALSE
);


INSERT INTO pilot (flight_id, first_name, last_name)
VALUES (
'1229',
'James',
'Harris'
);


INSERT INTO flight
VALUES (
'1230',
'342',
'2020-12-14 07:30:00',
'SFO',
109,
'2020-12-14 08:00:00',
'ATL',
74,
'2020-12-14 10:00:00',
'Scheduled',
0,
100,
0,
100,
0,
100,
TRUE,
TRUE
);


INSERT INTO pilot (flight_id, first_name, last_name)
VALUES (
'1230',
'Alex',
'Wang'
);


INSERT INTO flight
VALUES (
'1231',
'346',
'2020-12-14 12:30:00',
'ORD',
48,
'2020-12-14 13:00:00',
'ATL',
63,
'2020-12-14 16:00:00',
'Scheduled',
0,
100,
0,
100,
0,
100,
TRUE,
TRUE
);


INSERT INTO pilot (flight_id, first_name, last_name)
VALUES (
'1231',
'Liam',
'Brown'
);


INSERT INTO flight
VALUES (
'1232',
'345',
'2020-12-14 03:30:00',
'JFK',
11,
'2020-12-14 04:00:00',
'ATL',
93,
'2020-12-14 06:00:00',
'Scheduled',
0,
100,
0,
100,
0,
100,
TRUE,
TRUE
);


INSERT INTO pilot (flight_id, first_name, last_name)
VALUES (
'1232',
'John',
'Wang'
);


INSERT INTO flight
VALUES (
'1233',
'318',
'2020-12-14 08:30:00',
'DEN',
4,
'2020-12-14 09:00:00',
'SEA',
64,
'2020-12-14 12:00:00',
'Scheduled',
0,
50,
0,
50,
0,
50,
FALSE,
FALSE
);


INSERT INTO pilot (flight_id, first_name, last_name)
VALUES (
'1233',
'Ethan',
'Wang'
);


INSERT INTO flight
VALUES (
'1234',
'321',
'2020-12-14 10:30:00',
'DFW',
82,
'2020-12-14 11:00:00',
'MCO',
63,
'2020-12-14 13:00:00',
'Scheduled',
0,
50,
0,
50,
0,
50,
FALSE,
FALSE
);


INSERT INTO pilot (flight_id, first_name, last_name)
VALUES (
'1234',
'Noah',
'Harris'
);


INSERT INTO flight
VALUES (
'1235',
'342',
'2020-12-14 11:30:00',
'JFK',
86,
'2020-12-14 12:00:00',
'MCO',
4,
'2020-12-14 15:00:00',
'Scheduled',
0,
100,
0,
100,
0,
100,
TRUE,
TRUE
);


INSERT INTO pilot (flight_id, first_name, last_name)
VALUES (
'1235',
'Liam',
'Harris'
);


INSERT INTO flight
VALUES (
'1236',
'345',
'2020-12-14 06:30:00',
'SFO',
88,
'2020-12-14 07:00:00',
'LAX',
8,
'2020-12-14 10:00:00',
'Scheduled',
0,
100,
0,
100,
0,
100,
TRUE,
TRUE
);


INSERT INTO pilot (flight_id, first_name, last_name)
VALUES (
'1236',
'Alex',
'Lee'
);


INSERT INTO flight
VALUES (
'1237',
'345',
'2020-12-14 06:30:00',
'ATL',
32,
'2020-12-14 07:00:00',
'ORD',
19,
'2020-12-14 10:00:00',
'Scheduled',
0,
100,
0,
100,
0,
100,
TRUE,
TRUE
);


INSERT INTO pilot (flight_id, first_name, last_name)
VALUES (
'1237',
'Liam',
'Brown'
);


INSERT INTO flight
VALUES (
'1238',
'342',
'2020-12-14 07:30:00',
'LAS',
49,
'2020-12-14 08:00:00',
'DEN',
59,
'2020-12-14 10:00:00',
'Scheduled',
0,
100,
0,
100,
0,
100,
TRUE,
TRUE
);


INSERT INTO pilot (flight_id, first_name, last_name)
VALUES (
'1238',
'William',
'Lee'
);


INSERT INTO flight
VALUES (
'1239',
'321',
'2020-12-14 06:30:00',
'DEN',
107,
'2020-12-14 07:00:00',
'LAS',
14,
'2020-12-14 10:00:00',
'Scheduled',
0,
50,
0,
50,
0,
50,
FALSE,
FALSE
);


INSERT INTO pilot (flight_id, first_name, last_name)
VALUES (
'1239',
'Noah',
'Lee'
);


INSERT INTO flight
VALUES (
'1240',
'345',
'2020-12-14 10:30:00',
'JFK',
20,
'2020-12-14 11:00:00',
'ORD',
56,
'2020-12-14 13:00:00',
'Scheduled',
0,
100,
0,
100,
0,
100,
TRUE,
TRUE
);


INSERT INTO pilot (flight_id, first_name, last_name)
VALUES (
'1240',
'John',
'Garcia'
);


INSERT INTO flight
VALUES (
'1241',
'318',
'2020-12-14 06:30:00',
'LAX',
100,
'2020-12-14 07:00:00',
'SFO',
58,
'2020-12-14 10:00:00',
'Scheduled',
0,
50,
0,
50,
0,
50,
FALSE,
FALSE
);


INSERT INTO pilot (flight_id, first_name, last_name)
VALUES (
'1241',
'Mason',
'Wang'
);


INSERT INTO flight
VALUES (
'1242',
'310',
'2020-12-14 04:30:00',
'SEA',
38,
'2020-12-14 05:00:00',
'MCO',
78,
'2020-12-14 07:00:00',
'Scheduled',
0,
100,
0,
100,
0,
100,
TRUE,
TRUE
);


INSERT INTO pilot (flight_id, first_name, last_name)
VALUES (
'1242',
'Alex',
'Lee'
);


INSERT INTO flight
VALUES (
'1243',
'346',
'2020-12-14 06:30:00',
'MCO',
102,
'2020-12-14 07:00:00',
'LAX',
53,
'2020-12-14 10:00:00',
'Scheduled',
0,
100,
0,
100,
0,
100,
TRUE,
TRUE
);


INSERT INTO pilot (flight_id, first_name, last_name)
VALUES (
'1243',
'Jacob',
'Davis'
);


INSERT INTO flight
VALUES (
'1244',
'310',
'2020-12-14 07:30:00',
'MCO',
33,
'2020-12-14 08:00:00',
'LAS',
29,
'2020-12-14 10:00:00',
'Scheduled',
0,
100,
0,
100,
0,
100,
TRUE,
TRUE
);


INSERT INTO pilot (flight_id, first_name, last_name)
VALUES (
'1244',
'Alex',
'Wang'
);


INSERT INTO flight
VALUES (
'1245',
'343',
'2020-12-14 04:30:00',
'LAX',
73,
'2020-12-14 05:00:00',
'ATL',
29,
'2020-12-14 07:00:00',
'Scheduled',
0,
100,
0,
100,
0,
100,
TRUE,
TRUE
);


INSERT INTO pilot (flight_id, first_name, last_name)
VALUES (
'1245',
'William',
'Wang'
);


INSERT INTO flight
VALUES (
'1246',
'342',
'2020-12-14 05:30:00',
'ATL',
9,
'2020-12-14 06:00:00',
'ORD',
79,
'2020-12-14 08:00:00',
'Scheduled',
0,
100,
0,
100,
0,
100,
TRUE,
TRUE
);


INSERT INTO pilot (flight_id, first_name, last_name)
VALUES (
'1246',
'Mason',
'Smith'
);


INSERT INTO flight
VALUES (
'1247',
'318',
'2020-12-14 04:30:00',
'ATL',
22,
'2020-12-14 05:00:00',
'DFW',
8,
'2020-12-14 07:00:00',
'Scheduled',
0,
50,
0,
50,
0,
50,
FALSE,
FALSE
);


INSERT INTO pilot (flight_id, first_name, last_name)
VALUES (
'1247',
'Liam',
'Harris'
);


INSERT INTO flight
VALUES (
'1248',
'318',
'2020-12-14 12:30:00',
'LAX',
26,
'2020-12-14 13:00:00',
'ATL',
97,
'2020-12-14 16:00:00',
'Scheduled',
0,
50,
0,
50,
0,
50,
FALSE,
FALSE
);


INSERT INTO pilot (flight_id, first_name, last_name)
VALUES (
'1248',
'Ethan',
'Wang'
);


INSERT INTO flight
VALUES (
'1249',
'330',
'2020-12-14 06:30:00',
'LAS',
30,
'2020-12-14 07:00:00',
'ORD',
53,
'2020-12-14 10:00:00',
'Scheduled',
0,
100,
0,
100,
0,
100,
TRUE,
TRUE
);


INSERT INTO pilot (flight_id, first_name, last_name)
VALUES (
'1249',
'Mason',
'Garcia'
);


INSERT INTO flight
VALUES (
'1250',
'346',
'2020-12-10 09:30:00',
'JFK',
68,
'2020-12-10 10:00:00',
'SFO',
75,
'2020-12-10 13:00:00',
'Scheduled',
0,
100,
0,
100,
0,
100,
TRUE,
TRUE
);


INSERT INTO pilot (flight_id, first_name, last_name)
VALUES (
'1250',
'Jacob',
'Miller'
);


INSERT INTO flight
VALUES (
'1251',
'340',
'2020-12-15 12:30:00',
'LAX',
4,
'2020-12-15 13:00:00',
'DEN',
21,
'2020-12-15 16:00:00',
'Scheduled',
0,
100,
0,
100,
0,
100,
TRUE,
TRUE
);


INSERT INTO pilot (flight_id, first_name, last_name)
VALUES (
'1251',
'James',
'Smith'
);


INSERT INTO flight
VALUES (
'1252',
'321',
'2020-12-15 09:30:00',
'JFK',
79,
'2020-12-15 10:00:00',
'SFO',
29,
'2020-12-15 13:00:00',
'Scheduled',
0,
50,
0,
50,
0,
50,
FALSE,
FALSE
);


INSERT INTO pilot (flight_id, first_name, last_name)
VALUES (
'1252',
'Ethan',
'Brown'
);


INSERT INTO flight
VALUES (
'1253',
'342',
'2020-12-15 07:30:00',
'SFO',
47,
'2020-12-15 08:00:00',
'LAS',
60,
'2020-12-15 10:00:00',
'Scheduled',
0,
100,
0,
100,
0,
100,
TRUE,
TRUE
);


INSERT INTO pilot (flight_id, first_name, last_name)
VALUES (
'1253',
'Ethan',
'Thomas'
);


INSERT INTO flight
VALUES (
'1254',
'321',
'2020-12-15 07:30:00',
'DFW',
65,
'2020-12-15 08:00:00',
'ATL',
71,
'2020-12-15 10:00:00',
'Scheduled',
0,
50,
0,
50,
0,
50,
FALSE,
FALSE
);


INSERT INTO pilot (flight_id, first_name, last_name)
VALUES (
'1254',
'Alex',
'Lee'
);


INSERT INTO flight
VALUES (
'1255',
'346',
'2020-12-15 12:30:00',
'LAS',
58,
'2020-12-15 13:00:00',
'MCO',
28,
'2020-12-15 16:00:00',
'Scheduled',
0,
100,
0,
100,
0,
100,
TRUE,
TRUE
);


INSERT INTO pilot (flight_id, first_name, last_name)
VALUES (
'1255',
'Michael',
'Smith'
);


INSERT INTO flight
VALUES (
'1256',
'343',
'2020-12-15 05:30:00',
'DFW',
61,
'2020-12-15 06:00:00',
'JFK',
48,
'2020-12-15 08:00:00',
'Scheduled',
0,
100,
0,
100,
0,
100,
TRUE,
TRUE
);


INSERT INTO pilot (flight_id, first_name, last_name)
VALUES (
'1256',
'Ethan',
'Smith'
);


INSERT INTO flight
VALUES (
'1257',
'321',
'2020-12-15 06:30:00',
'LAX',
97,
'2020-12-15 07:00:00',
'DFW',
4,
'2020-12-15 10:00:00',
'Scheduled',
0,
50,
0,
50,
0,
50,
FALSE,
FALSE
);


INSERT INTO pilot (flight_id, first_name, last_name)
VALUES (
'1257',
'William',
'Smith'
);


INSERT INTO flight
VALUES (
'1258',
'346',
'2020-12-15 06:30:00',
'DEN',
34,
'2020-12-15 07:00:00',
'ORD',
34,
'2020-12-15 10:00:00',
'Scheduled',
0,
100,
0,
100,
0,
100,
TRUE,
TRUE
);


INSERT INTO pilot (flight_id, first_name, last_name)
VALUES (
'1258',
'Jacob',
'Miller'
);


INSERT INTO flight
VALUES (
'1259',
'310',
'2020-12-15 10:30:00',
'DEN',
68,
'2020-12-15 11:00:00',
'ORD',
32,
'2020-12-15 13:00:00',
'Scheduled',
0,
100,
0,
100,
0,
100,
TRUE,
TRUE
);


INSERT INTO pilot (flight_id, first_name, last_name)
VALUES (
'1259',
'Mason',
'Miller'
);


INSERT INTO flight
VALUES (
'1260',
'310',
'2020-12-15 07:30:00',
'DEN',
93,
'2020-12-15 08:00:00',
'ATL',
12,
'2020-12-15 10:00:00',
'Scheduled',
0,
100,
0,
100,
0,
100,
TRUE,
TRUE
);


INSERT INTO pilot (flight_id, first_name, last_name)
VALUES (
'1260',
'Ethan',
'Garcia'
);


INSERT INTO flight
VALUES (
'1261',
'346',
'2020-12-15 09:30:00',
'LAS',
34,
'2020-12-15 10:00:00',
'ORD',
53,
'2020-12-15 13:00:00',
'Scheduled',
0,
100,
0,
100,
0,
100,
TRUE,
TRUE
);


INSERT INTO pilot (flight_id, first_name, last_name)
VALUES (
'1261',
'William',
'Garcia'
);


INSERT INTO flight
VALUES (
'1262',
'346',
'2020-12-15 03:30:00',
'DFW',
98,
'2020-12-15 04:00:00',
'ATL',
23,
'2020-12-15 06:00:00',
'Scheduled',
0,
100,
0,
100,
0,
100,
TRUE,
TRUE
);


INSERT INTO pilot (flight_id, first_name, last_name)
VALUES (
'1262',
'Mason',
'Wang'
);


INSERT INTO flight
VALUES (
'1263',
'346',
'2020-12-15 09:30:00',
'ATL',
1,
'2020-12-15 10:00:00',
'SEA',
73,
'2020-12-15 13:00:00',
'Scheduled',
0,
100,
0,
100,
0,
100,
TRUE,
TRUE
);


INSERT INTO pilot (flight_id, first_name, last_name)
VALUES (
'1263',
'Ethan',
'Brown'
);


INSERT INTO flight
VALUES (
'1264',
'346',
'2020-12-15 12:30:00',
'LAX',
83,
'2020-12-15 13:00:00',
'DEN',
21,
'2020-12-15 16:00:00',
'Scheduled',
0,
100,
0,
100,
0,
100,
TRUE,
TRUE
);


INSERT INTO pilot (flight_id, first_name, last_name)
VALUES (
'1264',
'Michael',
'Brown'
);


INSERT INTO flight
VALUES (
'1265',
'342',
'2020-12-15 09:30:00',
'DFW',
27,
'2020-12-15 10:00:00',
'MCO',
9,
'2020-12-15 13:00:00',
'Scheduled',
0,
100,
0,
100,
0,
100,
TRUE,
TRUE
);


INSERT INTO pilot (flight_id, first_name, last_name)
VALUES (
'1265',
'Jacob',
'Lee'
);


INSERT INTO flight
VALUES (
'1266',
'342',
'2020-12-15 11:30:00',
'MCO',
25,
'2020-12-15 12:00:00',
'DEN',
13,
'2020-12-15 15:00:00',
'Scheduled',
0,
100,
0,
100,
0,
100,
TRUE,
TRUE
);


INSERT INTO pilot (flight_id, first_name, last_name)
VALUES (
'1266',
'Michael',
'Lee'
);


INSERT INTO flight
VALUES (
'1267',
'319',
'2020-12-15 10:30:00',
'ATL',
11,
'2020-12-15 11:00:00',
'DFW',
26,
'2020-12-15 13:00:00',
'Scheduled',
0,
50,
0,
50,
0,
50,
FALSE,
FALSE
);


INSERT INTO pilot (flight_id, first_name, last_name)
VALUES (
'1267',
'Mason',
'Davis'
);


INSERT INTO flight
VALUES (
'1268',
'321',
'2020-12-15 03:30:00',
'LAS',
50,
'2020-12-15 04:00:00',
'LAX',
32,
'2020-12-15 06:00:00',
'Scheduled',
0,
50,
0,
50,
0,
50,
FALSE,
FALSE
);


INSERT INTO pilot (flight_id, first_name, last_name)
VALUES (
'1268',
'James',
'Anderson'
);


INSERT INTO flight
VALUES (
'1269',
'330',
'2020-12-15 05:30:00',
'DEN',
8,
'2020-12-15 06:00:00',
'LAX',
15,
'2020-12-15 08:00:00',
'Scheduled',
0,
100,
0,
100,
0,
100,
TRUE,
TRUE
);


INSERT INTO pilot (flight_id, first_name, last_name)
VALUES (
'1269',
'Michael',
'Wang'
);


INSERT INTO flight
VALUES (
'1270',
'318',
'2020-12-15 04:30:00',
'LAX',
27,
'2020-12-15 05:00:00',
'ATL',
69,
'2020-12-15 07:00:00',
'Scheduled',
0,
50,
0,
50,
0,
50,
FALSE,
FALSE
);


INSERT INTO pilot (flight_id, first_name, last_name)
VALUES (
'1270',
'William',
'Garcia'
);


INSERT INTO flight
VALUES (
'1271',
'318',
'2020-12-15 05:30:00',
'LAS',
72,
'2020-12-15 06:00:00',
'MCO',
66,
'2020-12-15 08:00:00',
'Scheduled',
0,
50,
0,
50,
0,
50,
FALSE,
FALSE
);


INSERT INTO pilot (flight_id, first_name, last_name)
VALUES (
'1271',
'Mason',
'Smith'
);


INSERT INTO flight
VALUES (
'1272',
'343',
'2020-12-15 05:30:00',
'MCO',
79,
'2020-12-15 06:00:00',
'LAX',
27,
'2020-12-15 08:00:00',
'Scheduled',
0,
100,
0,
100,
0,
100,
TRUE,
TRUE
);


INSERT INTO pilot (flight_id, first_name, last_name)
VALUES (
'1272',
'Noah',
'Brown'
);


INSERT INTO flight
VALUES (
'1273',
'340',
'2020-12-15 06:30:00',
'SFO',
72,
'2020-12-15 07:00:00',
'LAS',
64,
'2020-12-15 10:00:00',
'Scheduled',
0,
100,
0,
100,
0,
100,
TRUE,
TRUE
);


INSERT INTO pilot (flight_id, first_name, last_name)
VALUES (
'1273',
'Noah',
'Smith'
);


INSERT INTO flight
VALUES (
'1274',
'340',
'2020-12-15 11:30:00',
'ORD',
75,
'2020-12-15 12:00:00',
'DEN',
26,
'2020-12-15 15:00:00',
'Scheduled',
0,
100,
0,
100,
0,
100,
TRUE,
TRUE
);


INSERT INTO pilot (flight_id, first_name, last_name)
VALUES (
'1274',
'Noah',
'Thomas'
);


INSERT INTO flight
VALUES (
'1275',
'345',
'2020-12-15 06:30:00',
'JFK',
19,
'2020-12-15 07:00:00',
'LAX',
53,
'2020-12-15 10:00:00',
'Scheduled',
0,
100,
0,
100,
0,
100,
TRUE,
TRUE
);


INSERT INTO pilot (flight_id, first_name, last_name)
VALUES (
'1275',
'Jacob',
'Brown'
);


INSERT INTO flight
VALUES (
'1276',
'310',
'2020-12-15 05:30:00',
'DFW',
105,
'2020-12-15 06:00:00',
'LAS',
102,
'2020-12-15 08:00:00',
'Scheduled',
0,
100,
0,
100,
0,
100,
TRUE,
TRUE
);


INSERT INTO pilot (flight_id, first_name, last_name)
VALUES (
'1276',
'Liam',
'Brown'
);


INSERT INTO flight
VALUES (
'1277',
'343',
'2020-12-15 04:30:00',
'JFK',
51,
'2020-12-15 05:00:00',
'ORD',
53,
'2020-12-15 07:00:00',
'Scheduled',
0,
100,
0,
100,
0,
100,
TRUE,
TRUE
);


INSERT INTO pilot (flight_id, first_name, last_name)
VALUES (
'1277',
'Noah',
'Harris'
);


INSERT INTO flight
VALUES (
'1278',
'318',
'2020-12-15 06:30:00',
'LAX',
82,
'2020-12-15 07:00:00',
'ORD',
97,
'2020-12-15 10:00:00',
'Scheduled',
0,
50,
0,
50,
0,
50,
FALSE,
FALSE
);


INSERT INTO pilot (flight_id, first_name, last_name)
VALUES (
'1278',
'Liam',
'Brown'
);


INSERT INTO flight
VALUES (
'1279',
'310',
'2020-12-15 04:30:00',
'SFO',
62,
'2020-12-15 05:00:00',
'JFK',
101,
'2020-12-15 07:00:00',
'Scheduled',
0,
100,
0,
100,
0,
100,
TRUE,
TRUE
);


INSERT INTO pilot (flight_id, first_name, last_name)
VALUES (
'1279',
'James',
'Harris'
);


INSERT INTO flight
VALUES (
'1280',
'340',
'2020-12-15 12:30:00',
'LAX',
81,
'2020-12-15 13:00:00',
'DFW',
76,
'2020-12-15 16:00:00',
'Scheduled',
0,
100,
0,
100,
0,
100,
TRUE,
TRUE
);


INSERT INTO pilot (flight_id, first_name, last_name)
VALUES (
'1280',
'Mason',
'Wang'
);


INSERT INTO flight
VALUES (
'1281',
'345',
'2020-12-15 10:30:00',
'ATL',
37,
'2020-12-15 11:00:00',
'LAS',
75,
'2020-12-15 13:00:00',
'Scheduled',
0,
100,
0,
100,
0,
100,
TRUE,
TRUE
);


INSERT INTO pilot (flight_id, first_name, last_name)
VALUES (
'1281',
'William',
'Davis'
);


INSERT INTO flight
VALUES (
'1282',
'346',
'2020-12-15 12:30:00',
'MCO',
88,
'2020-12-15 13:00:00',
'LAX',
21,
'2020-12-15 16:00:00',
'Scheduled',
0,
100,
0,
100,
0,
100,
TRUE,
TRUE
);


INSERT INTO pilot (flight_id, first_name, last_name)
VALUES (
'1282',
'Noah',
'Harris'
);


INSERT INTO flight
VALUES (
'1283',
'310',
'2020-12-15 07:30:00',
'ORD',
100,
'2020-12-15 08:00:00',
'DEN',
28,
'2020-12-15 10:00:00',
'Scheduled',
0,
100,
0,
100,
0,
100,
TRUE,
TRUE
);


INSERT INTO pilot (flight_id, first_name, last_name)
VALUES (
'1283',
'Mason',
'Wang'
);


INSERT INTO flight
VALUES (
'1284',
'346',
'2020-12-15 12:30:00',
'ATL',
95,
'2020-12-15 13:00:00',
'DEN',
9,
'2020-12-15 16:00:00',
'Scheduled',
0,
100,
0,
100,
0,
100,
TRUE,
TRUE
);


INSERT INTO pilot (flight_id, first_name, last_name)
VALUES (
'1284',
'Michael',
'Wang'
);


INSERT INTO flight
VALUES (
'1285',
'342',
'2020-12-15 12:30:00',
'ATL',
48,
'2020-12-15 13:00:00',
'DEN',
51,
'2020-12-15 16:00:00',
'Scheduled',
0,
100,
0,
100,
0,
100,
TRUE,
TRUE
);


INSERT INTO pilot (flight_id, first_name, last_name)
VALUES (
'1285',
'Jacob',
'Miller'
);


INSERT INTO flight
VALUES (
'1286',
'319',
'2020-12-15 08:30:00',
'LAX',
93,
'2020-12-15 09:00:00',
'ORD',
78,
'2020-12-15 12:00:00',
'Scheduled',
0,
50,
0,
50,
0,
50,
FALSE,
FALSE
);


INSERT INTO pilot (flight_id, first_name, last_name)
VALUES (
'1286',
'John',
'Miller'
);


INSERT INTO flight
VALUES (
'1287',
'340',
'2020-12-15 06:30:00',
'ORD',
14,
'2020-12-15 07:00:00',
'SFO',
36,
'2020-12-15 10:00:00',
'Scheduled',
0,
100,
0,
100,
0,
100,
TRUE,
TRUE
);


INSERT INTO pilot (flight_id, first_name, last_name)
VALUES (
'1287',
'Liam',
'Miller'
);


INSERT INTO flight
VALUES (
'1288',
'319',
'2020-12-15 08:30:00',
'ORD',
101,
'2020-12-15 09:00:00',
'SEA',
72,
'2020-12-15 12:00:00',
'Scheduled',
0,
50,
0,
50,
0,
50,
FALSE,
FALSE
);


INSERT INTO pilot (flight_id, first_name, last_name)
VALUES (
'1288',
'Jacob',
'Lee'
);


INSERT INTO flight
VALUES (
'1289',
'340',
'2020-12-15 08:30:00',
'JFK',
64,
'2020-12-15 09:00:00',
'DFW',
48,
'2020-12-15 12:00:00',
'Scheduled',
0,
100,
0,
100,
0,
100,
TRUE,
TRUE
);


INSERT INTO pilot (flight_id, first_name, last_name)
VALUES (
'1289',
'John',
'Davis'
);


INSERT INTO flight
VALUES (
'1290',
'318',
'2020-12-15 06:30:00',
'ATL',
4,
'2020-12-15 07:00:00',
'MCO',
30,
'2020-12-15 10:00:00',
'Scheduled',
0,
50,
0,
50,
0,
50,
FALSE,
FALSE
);


INSERT INTO pilot (flight_id, first_name, last_name)
VALUES (
'1290',
'James',
'Garcia'
);


INSERT INTO flight
VALUES (
'1291',
'345',
'2020-12-15 04:30:00',
'LAX',
62,
'2020-12-15 05:00:00',
'DFW',
73,
'2020-12-15 07:00:00',
'Scheduled',
0,
100,
0,
100,
0,
100,
TRUE,
TRUE
);


INSERT INTO pilot (flight_id, first_name, last_name)
VALUES (
'1291',
'John',
'Miller'
);


INSERT INTO flight
VALUES (
'1292',
'340',
'2020-12-15 08:30:00',
'JFK',
4,
'2020-12-15 09:00:00',
'LAS',
29,
'2020-12-15 12:00:00',
'Scheduled',
0,
100,
0,
100,
0,
100,
TRUE,
TRUE
);


INSERT INTO pilot (flight_id, first_name, last_name)
VALUES (
'1292',
'Noah',
'Smith'
);


INSERT INTO flight
VALUES (
'1293',
'310',
'2020-12-15 12:30:00',
'LAS',
23,
'2020-12-15 13:00:00',
'ATL',
33,
'2020-12-15 16:00:00',
'Scheduled',
0,
100,
0,
100,
0,
100,
TRUE,
TRUE
);


INSERT INTO pilot (flight_id, first_name, last_name)
VALUES (
'1293',
'Liam',
'Garcia'
);


INSERT INTO flight
VALUES (
'1294',
'342',
'2020-12-15 12:30:00',
'ATL',
92,
'2020-12-15 13:00:00',
'LAS',
30,
'2020-12-15 16:00:00',
'Scheduled',
0,
100,
0,
100,
0,
100,
TRUE,
TRUE
);


INSERT INTO pilot (flight_id, first_name, last_name)
VALUES (
'1294',
'John',
'Harris'
);


INSERT INTO flight
VALUES (
'1295',
'310',
'2020-12-15 05:30:00',
'DFW',
27,
'2020-12-15 06:00:00',
'LAX',
60,
'2020-12-15 08:00:00',
'Scheduled',
0,
100,
0,
100,
0,
100,
TRUE,
TRUE
);


INSERT INTO pilot (flight_id, first_name, last_name)
VALUES (
'1295',
'Jacob',
'Garcia'
);


INSERT INTO flight
VALUES (
'1296',
'340',
'2020-12-15 06:30:00',
'DFW',
96,
'2020-12-15 07:00:00',
'SEA',
110,
'2020-12-15 10:00:00',
'Scheduled',
0,
100,
0,
100,
0,
100,
TRUE,
TRUE
);


INSERT INTO pilot (flight_id, first_name, last_name)
VALUES (
'1296',
'Mason',
'Anderson'
);


INSERT INTO flight
VALUES (
'1297',
'342',
'2020-12-15 04:30:00',
'ATL',
19,
'2020-12-15 05:00:00',
'SFO',
45,
'2020-12-15 07:00:00',
'Scheduled',
0,
100,
0,
100,
0,
100,
TRUE,
TRUE
);


INSERT INTO pilot (flight_id, first_name, last_name)
VALUES (
'1297',
'Alex',
'Thomas'
);


INSERT INTO flight
VALUES (
'1298',
'318',
'2020-12-15 12:30:00',
'LAS',
104,
'2020-12-15 13:00:00',
'ATL',
105,
'2020-12-15 16:00:00',
'Scheduled',
0,
50,
0,
50,
0,
50,
FALSE,
FALSE
);


INSERT INTO pilot (flight_id, first_name, last_name)
VALUES (
'1298',
'John',
'Lee'
);


INSERT INTO flight
VALUES (
'1299',
'310',
'2020-12-15 10:30:00',
'LAX',
39,
'2020-12-15 11:00:00',
'ATL',
108,
'2020-12-15 13:00:00',
'Scheduled',
0,
100,
0,
100,
0,
100,
TRUE,
TRUE
);


INSERT INTO pilot (flight_id, first_name, last_name)
VALUES (
'1299',
'William',
'Lee'
);


INSERT INTO flight
VALUES (
'1300',
'310',
'2020-12-10 09:30:00',
'DEN',
44,
'2020-12-10 10:00:00',
'LAX',
31,
'2020-12-10 13:00:00',
'Scheduled',
0,
100,
0,
100,
0,
100,
TRUE,
TRUE
);


INSERT INTO pilot (flight_id, first_name, last_name)
VALUES (
'1300',
'Noah',
'Smith'
);


INSERT INTO flight
VALUES (
'1301',
'343',
'2020-12-16 10:30:00',
'ORD',
41,
'2020-12-16 11:00:00',
'LAX',
102,
'2020-12-16 13:00:00',
'Scheduled',
0,
100,
0,
100,
0,
100,
TRUE,
TRUE
);


INSERT INTO pilot (flight_id, first_name, last_name)
VALUES (
'1301',
'James',
'Lee'
);


INSERT INTO flight
VALUES (
'1302',
'346',
'2020-12-16 12:30:00',
'MCO',
9,
'2020-12-16 13:00:00',
'SFO',
67,
'2020-12-16 16:00:00',
'Scheduled',
0,
100,
0,
100,
0,
100,
TRUE,
TRUE
);


INSERT INTO pilot (flight_id, first_name, last_name)
VALUES (
'1302',
'Noah',
'Smith'
);


INSERT INTO flight
VALUES (
'1303',
'319',
'2020-12-16 07:30:00',
'SFO',
14,
'2020-12-16 08:00:00',
'ORD',
31,
'2020-12-16 10:00:00',
'Scheduled',
0,
50,
0,
50,
0,
50,
FALSE,
FALSE
);


INSERT INTO pilot (flight_id, first_name, last_name)
VALUES (
'1303',
'William',
'Miller'
);


INSERT INTO flight
VALUES (
'1304',
'318',
'2020-12-16 05:30:00',
'MCO',
29,
'2020-12-16 06:00:00',
'LAS',
45,
'2020-12-16 08:00:00',
'Scheduled',
0,
50,
0,
50,
0,
50,
FALSE,
FALSE
);


INSERT INTO pilot (flight_id, first_name, last_name)
VALUES (
'1304',
'Alex',
'Garcia'
);


INSERT INTO flight
VALUES (
'1305',
'346',
'2020-12-16 05:30:00',
'JFK',
90,
'2020-12-16 06:00:00',
'LAS',
97,
'2020-12-16 08:00:00',
'Scheduled',
0,
100,
0,
100,
0,
100,
TRUE,
TRUE
);


INSERT INTO pilot (flight_id, first_name, last_name)
VALUES (
'1305',
'Noah',
'Harris'
);


INSERT INTO flight
VALUES (
'1306',
'310',
'2020-12-16 08:30:00',
'DEN',
64,
'2020-12-16 09:00:00',
'MCO',
75,
'2020-12-16 12:00:00',
'Scheduled',
0,
100,
0,
100,
0,
100,
TRUE,
TRUE
);


INSERT INTO pilot (flight_id, first_name, last_name)
VALUES (
'1306',
'Jacob',
'Davis'
);


INSERT INTO flight
VALUES (
'1307',
'310',
'2020-12-16 10:30:00',
'DFW',
106,
'2020-12-16 11:00:00',
'SEA',
96,
'2020-12-16 13:00:00',
'Scheduled',
0,
100,
0,
100,
0,
100,
TRUE,
TRUE
);


INSERT INTO pilot (flight_id, first_name, last_name)
VALUES (
'1307',
'Michael',
'Smith'
);


INSERT INTO flight
VALUES (
'1308',
'319',
'2020-12-16 07:30:00',
'LAX',
34,
'2020-12-16 08:00:00',
'DFW',
52,
'2020-12-16 10:00:00',
'Scheduled',
0,
50,
0,
50,
0,
50,
FALSE,
FALSE
);


INSERT INTO pilot (flight_id, first_name, last_name)
VALUES (
'1308',
'Michael',
'Lee'
);


INSERT INTO flight
VALUES (
'1309',
'340',
'2020-12-16 09:30:00',
'DFW',
69,
'2020-12-16 10:00:00',
'JFK',
49,
'2020-12-16 13:00:00',
'Scheduled',
0,
100,
0,
100,
0,
100,
TRUE,
TRUE
);


INSERT INTO pilot (flight_id, first_name, last_name)
VALUES (
'1309',
'Noah',
'Davis'
);


INSERT INTO flight
VALUES (
'1310',
'342',
'2020-12-16 04:30:00',
'JFK',
18,
'2020-12-16 05:00:00',
'DFW',
27,
'2020-12-16 07:00:00',
'Scheduled',
0,
100,
0,
100,
0,
100,
TRUE,
TRUE
);


INSERT INTO pilot (flight_id, first_name, last_name)
VALUES (
'1310',
'James',
'Anderson'
);


INSERT INTO flight
VALUES (
'1311',
'346',
'2020-12-16 12:30:00',
'DFW',
97,
'2020-12-16 13:00:00',
'ATL',
17,
'2020-12-16 16:00:00',
'Scheduled',
0,
100,
0,
100,
0,
100,
TRUE,
TRUE
);


INSERT INTO pilot (flight_id, first_name, last_name)
VALUES (
'1311',
'John',
'Wang'
);


INSERT INTO flight
VALUES (
'1312',
'342',
'2020-12-16 11:30:00',
'LAX',
83,
'2020-12-16 12:00:00',
'MCO',
84,
'2020-12-16 15:00:00',
'Scheduled',
0,
100,
0,
100,
0,
100,
TRUE,
TRUE
);


INSERT INTO pilot (flight_id, first_name, last_name)
VALUES (
'1312',
'Ethan',
'Brown'
);


INSERT INTO flight
VALUES (
'1313',
'346',
'2020-12-16 08:30:00',
'MCO',
42,
'2020-12-16 09:00:00',
'LAS',
102,
'2020-12-16 12:00:00',
'Scheduled',
0,
100,
0,
100,
0,
100,
TRUE,
TRUE
);


INSERT INTO pilot (flight_id, first_name, last_name)
VALUES (
'1313',
'William',
'Thomas'
);


INSERT INTO flight
VALUES (
'1314',
'345',
'2020-12-16 06:30:00',
'SEA',
34,
'2020-12-16 07:00:00',
'DFW',
25,
'2020-12-16 10:00:00',
'Scheduled',
0,
100,
0,
100,
0,
100,
TRUE,
TRUE
);


INSERT INTO pilot (flight_id, first_name, last_name)
VALUES (
'1314',
'Noah',
'Anderson'
);


INSERT INTO flight
VALUES (
'1315',
'330',
'2020-12-16 05:30:00',
'MCO',
6,
'2020-12-16 06:00:00',
'LAX',
14,
'2020-12-16 08:00:00',
'Scheduled',
0,
100,
0,
100,
0,
100,
TRUE,
TRUE
);


INSERT INTO pilot (flight_id, first_name, last_name)
VALUES (
'1315',
'Liam',
'Miller'
);


INSERT INTO flight
VALUES (
'1316',
'345',
'2020-12-16 06:30:00',
'LAS',
53,
'2020-12-16 07:00:00',
'DEN',
69,
'2020-12-16 10:00:00',
'Scheduled',
0,
100,
0,
100,
0,
100,
TRUE,
TRUE
);


INSERT INTO pilot (flight_id, first_name, last_name)
VALUES (
'1316',
'James',
'Wang'
);


INSERT INTO flight
VALUES (
'1317',
'321',
'2020-12-16 04:30:00',
'LAX',
61,
'2020-12-16 05:00:00',
'LAS',
77,
'2020-12-16 07:00:00',
'Scheduled',
0,
50,
0,
50,
0,
50,
FALSE,
FALSE
);


INSERT INTO pilot (flight_id, first_name, last_name)
VALUES (
'1317',
'Ethan',
'Miller'
);


INSERT INTO flight
VALUES (
'1318',
'340',
'2020-12-16 09:30:00',
'LAX',
48,
'2020-12-16 10:00:00',
'ATL',
31,
'2020-12-16 13:00:00',
'Scheduled',
0,
100,
0,
100,
0,
100,
TRUE,
TRUE
);


INSERT INTO pilot (flight_id, first_name, last_name)
VALUES (
'1318',
'Mason',
'Davis'
);


INSERT INTO flight
VALUES (
'1319',
'343',
'2020-12-16 06:30:00',
'LAX',
60,
'2020-12-16 07:00:00',
'SFO',
23,
'2020-12-16 10:00:00',
'Scheduled',
0,
100,
0,
100,
0,
100,
TRUE,
TRUE
);


INSERT INTO pilot (flight_id, first_name, last_name)
VALUES (
'1319',
'Noah',
'Brown'
);


INSERT INTO flight
VALUES (
'1320',
'318',
'2020-12-16 10:30:00',
'DFW',
98,
'2020-12-16 11:00:00',
'ATL',
62,
'2020-12-16 13:00:00',
'Scheduled',
0,
50,
0,
50,
0,
50,
FALSE,
FALSE
);


INSERT INTO pilot (flight_id, first_name, last_name)
VALUES (
'1320',
'Alex',
'Davis'
);


INSERT INTO flight
VALUES (
'1321',
'346',
'2020-12-16 12:30:00',
'DFW',
35,
'2020-12-16 13:00:00',
'SEA',
106,
'2020-12-16 16:00:00',
'Scheduled',
0,
100,
0,
100,
0,
100,
TRUE,
TRUE
);


INSERT INTO pilot (flight_id, first_name, last_name)
VALUES (
'1321',
'Alex',
'Lee'
);


INSERT INTO flight
VALUES (
'1322',
'340',
'2020-12-16 08:30:00',
'MCO',
67,
'2020-12-16 09:00:00',
'ORD',
102,
'2020-12-16 12:00:00',
'Scheduled',
0,
100,
0,
100,
0,
100,
TRUE,
TRUE
);


INSERT INTO pilot (flight_id, first_name, last_name)
VALUES (
'1322',
'Liam',
'Thomas'
);


INSERT INTO flight
VALUES (
'1323',
'345',
'2020-12-16 07:30:00',
'SFO',
48,
'2020-12-16 08:00:00',
'LAS',
14,
'2020-12-16 10:00:00',
'Scheduled',
0,
100,
0,
100,
0,
100,
TRUE,
TRUE
);


INSERT INTO pilot (flight_id, first_name, last_name)
VALUES (
'1323',
'Ethan',
'Brown'
);


INSERT INTO flight
VALUES (
'1324',
'343',
'2020-12-16 11:30:00',
'ATL',
44,
'2020-12-16 12:00:00',
'JFK',
74,
'2020-12-16 15:00:00',
'Scheduled',
0,
100,
0,
100,
0,
100,
TRUE,
TRUE
);


INSERT INTO pilot (flight_id, first_name, last_name)
VALUES (
'1324',
'Alex',
'Anderson'
);


INSERT INTO flight
VALUES (
'1325',
'321',
'2020-12-16 06:30:00',
'ORD',
87,
'2020-12-16 07:00:00',
'LAS',
106,
'2020-12-16 10:00:00',
'Scheduled',
0,
50,
0,
50,
0,
50,
FALSE,
FALSE
);


INSERT INTO pilot (flight_id, first_name, last_name)
VALUES (
'1325',
'Michael',
'Wang'
);


INSERT INTO flight
VALUES (
'1326',
'319',
'2020-12-16 04:30:00',
'SEA',
66,
'2020-12-16 05:00:00',
'ATL',
1,
'2020-12-16 07:00:00',
'Scheduled',
0,
50,
0,
50,
0,
50,
FALSE,
FALSE
);


INSERT INTO pilot (flight_id, first_name, last_name)
VALUES (
'1326',
'Jacob',
'Davis'
);


INSERT INTO flight
VALUES (
'1327',
'319',
'2020-12-16 09:30:00',
'LAX',
5,
'2020-12-16 10:00:00',
'MCO',
13,
'2020-12-16 13:00:00',
'Scheduled',
0,
50,
0,
50,
0,
50,
FALSE,
FALSE
);


INSERT INTO pilot (flight_id, first_name, last_name)
VALUES (
'1327',
'Noah',
'Brown'
);


INSERT INTO flight
VALUES (
'1328',
'345',
'2020-12-16 04:30:00',
'ATL',
60,
'2020-12-16 05:00:00',
'DFW',
9,
'2020-12-16 07:00:00',
'Scheduled',
0,
100,
0,
100,
0,
100,
TRUE,
TRUE
);


INSERT INTO pilot (flight_id, first_name, last_name)
VALUES (
'1328',
'Ethan',
'Garcia'
);


INSERT INTO flight
VALUES (
'1329',
'330',
'2020-12-16 04:30:00',
'SFO',
76,
'2020-12-16 05:00:00',
'DEN',
68,
'2020-12-16 07:00:00',
'Scheduled',
0,
100,
0,
100,
0,
100,
TRUE,
TRUE
);


INSERT INTO pilot (flight_id, first_name, last_name)
VALUES (
'1329',
'James',
'Lee'
);


INSERT INTO flight
VALUES (
'1330',
'342',
'2020-12-16 07:30:00',
'ATL',
7,
'2020-12-16 08:00:00',
'DEN',
81,
'2020-12-16 10:00:00',
'Scheduled',
0,
100,
0,
100,
0,
100,
TRUE,
TRUE
);


INSERT INTO pilot (flight_id, first_name, last_name)
VALUES (
'1330',
'William',
'Garcia'
);


INSERT INTO flight
VALUES (
'1331',
'310',
'2020-12-16 05:30:00',
'DEN',
111,
'2020-12-16 06:00:00',
'ATL',
60,
'2020-12-16 08:00:00',
'Scheduled',
0,
100,
0,
100,
0,
100,
TRUE,
TRUE
);


INSERT INTO pilot (flight_id, first_name, last_name)
VALUES (
'1331',
'Mason',
'Miller'
);


INSERT INTO flight
VALUES (
'1332',
'345',
'2020-12-16 11:30:00',
'SFO',
56,
'2020-12-16 12:00:00',
'ORD',
76,
'2020-12-16 15:00:00',
'Scheduled',
0,
100,
0,
100,
0,
100,
TRUE,
TRUE
);


INSERT INTO pilot (flight_id, first_name, last_name)
VALUES (
'1332',
'Michael',
'Brown'
);


INSERT INTO flight
VALUES (
'1333',
'319',
'2020-12-16 08:30:00',
'JFK',
93,
'2020-12-16 09:00:00',
'MCO',
5,
'2020-12-16 12:00:00',
'Scheduled',
0,
50,
0,
50,
0,
50,
FALSE,
FALSE
);


INSERT INTO pilot (flight_id, first_name, last_name)
VALUES (
'1333',
'Michael',
'Lee'
);


INSERT INTO flight
VALUES (
'1334',
'321',
'2020-12-16 08:30:00',
'LAX',
33,
'2020-12-16 09:00:00',
'LAS',
51,
'2020-12-16 12:00:00',
'Scheduled',
0,
50,
0,
50,
0,
50,
FALSE,
FALSE
);


INSERT INTO pilot (flight_id, first_name, last_name)
VALUES (
'1334',
'Liam',
'Anderson'
);


INSERT INTO flight
VALUES (
'1335',
'340',
'2020-12-16 03:30:00',
'MCO',
35,
'2020-12-16 04:00:00',
'SFO',
29,
'2020-12-16 06:00:00',
'Scheduled',
0,
100,
0,
100,
0,
100,
TRUE,
TRUE
);


INSERT INTO pilot (flight_id, first_name, last_name)
VALUES (
'1335',
'John',
'Harris'
);


INSERT INTO flight
VALUES (
'1336',
'321',
'2020-12-16 05:30:00',
'LAX',
61,
'2020-12-16 06:00:00',
'MCO',
5,
'2020-12-16 08:00:00',
'Scheduled',
0,
50,
0,
50,
0,
50,
FALSE,
FALSE
);


INSERT INTO pilot (flight_id, first_name, last_name)
VALUES (
'1336',
'Alex',
'Wang'
);


INSERT INTO flight
VALUES (
'1337',
'319',
'2020-12-16 11:30:00',
'MCO',
74,
'2020-12-16 12:00:00',
'ORD',
91,
'2020-12-16 15:00:00',
'Scheduled',
0,
50,
0,
50,
0,
50,
FALSE,
FALSE
);


INSERT INTO pilot (flight_id, first_name, last_name)
VALUES (
'1337',
'John',
'Lee'
);


INSERT INTO flight
VALUES (
'1338',
'345',
'2020-12-16 10:30:00',
'JFK',
10,
'2020-12-16 11:00:00',
'LAX',
58,
'2020-12-16 13:00:00',
'Scheduled',
0,
100,
0,
100,
0,
100,
TRUE,
TRUE
);


INSERT INTO pilot (flight_id, first_name, last_name)
VALUES (
'1338',
'Liam',
'Thomas'
);


INSERT INTO flight
VALUES (
'1339',
'345',
'2020-12-16 09:30:00',
'DEN',
15,
'2020-12-16 10:00:00',
'MCO',
111,
'2020-12-16 13:00:00',
'Scheduled',
0,
100,
0,
100,
0,
100,
TRUE,
TRUE
);


INSERT INTO pilot (flight_id, first_name, last_name)
VALUES (
'1339',
'Noah',
'Lee'
);


INSERT INTO flight
VALUES (
'1340',
'321',
'2020-12-16 12:30:00',
'SEA',
23,
'2020-12-16 13:00:00',
'SFO',
45,
'2020-12-16 16:00:00',
'Scheduled',
0,
50,
0,
50,
0,
50,
FALSE,
FALSE
);


INSERT INTO pilot (flight_id, first_name, last_name)
VALUES (
'1340',
'John',
'Lee'
);


INSERT INTO flight
VALUES (
'1341',
'310',
'2020-12-16 12:30:00',
'JFK',
19,
'2020-12-16 13:00:00',
'SFO',
53,
'2020-12-16 16:00:00',
'Scheduled',
0,
100,
0,
100,
0,
100,
TRUE,
TRUE
);


INSERT INTO pilot (flight_id, first_name, last_name)
VALUES (
'1341',
'Mason',
'Lee'
);


INSERT INTO flight
VALUES (
'1342',
'343',
'2020-12-16 07:30:00',
'LAS',
85,
'2020-12-16 08:00:00',
'DEN',
98,
'2020-12-16 10:00:00',
'Scheduled',
0,
100,
0,
100,
0,
100,
TRUE,
TRUE
);


INSERT INTO pilot (flight_id, first_name, last_name)
VALUES (
'1342',
'John',
'Smith'
);


INSERT INTO flight
VALUES (
'1343',
'319',
'2020-12-16 06:30:00',
'JFK',
59,
'2020-12-16 07:00:00',
'DFW',
50,
'2020-12-16 10:00:00',
'Scheduled',
0,
50,
0,
50,
0,
50,
FALSE,
FALSE
);


INSERT INTO pilot (flight_id, first_name, last_name)
VALUES (
'1343',
'James',
'Anderson'
);


INSERT INTO flight
VALUES (
'1344',
'318',
'2020-12-16 12:30:00',
'LAS',
58,
'2020-12-16 13:00:00',
'ORD',
69,
'2020-12-16 16:00:00',
'Scheduled',
0,
50,
0,
50,
0,
50,
FALSE,
FALSE
);


INSERT INTO pilot (flight_id, first_name, last_name)
VALUES (
'1344',
'Jacob',
'Lee'
);


INSERT INTO flight
VALUES (
'1345',
'318',
'2020-12-16 08:30:00',
'SFO',
88,
'2020-12-16 09:00:00',
'MCO',
9,
'2020-12-16 12:00:00',
'Scheduled',
0,
50,
0,
50,
0,
50,
FALSE,
FALSE
);


INSERT INTO pilot (flight_id, first_name, last_name)
VALUES (
'1345',
'Jacob',
'Thomas'
);


INSERT INTO flight
VALUES (
'1346',
'346',
'2020-12-16 07:30:00',
'LAX',
44,
'2020-12-16 08:00:00',
'JFK',
104,
'2020-12-16 10:00:00',
'Scheduled',
0,
100,
0,
100,
0,
100,
TRUE,
TRUE
);


INSERT INTO pilot (flight_id, first_name, last_name)
VALUES (
'1346',
'John',
'Smith'
);


INSERT INTO flight
VALUES (
'1347',
'340',
'2020-12-16 08:30:00',
'LAX',
26,
'2020-12-16 09:00:00',
'LAS',
1,
'2020-12-16 12:00:00',
'Scheduled',
0,
100,
0,
100,
0,
100,
TRUE,
TRUE
);


INSERT INTO pilot (flight_id, first_name, last_name)
VALUES (
'1347',
'William',
'Davis'
);


INSERT INTO flight
VALUES (
'1348',
'321',
'2020-12-16 06:30:00',
'LAS',
16,
'2020-12-16 07:00:00',
'LAX',
95,
'2020-12-16 10:00:00',
'Scheduled',
0,
50,
0,
50,
0,
50,
FALSE,
FALSE
);


INSERT INTO pilot (flight_id, first_name, last_name)
VALUES (
'1348',
'James',
'Garcia'
);


INSERT INTO flight
VALUES (
'1349',
'346',
'2020-12-16 07:30:00',
'LAS',
10,
'2020-12-16 08:00:00',
'DEN',
90,
'2020-12-16 10:00:00',
'Scheduled',
0,
100,
0,
100,
0,
100,
TRUE,
TRUE
);


INSERT INTO pilot (flight_id, first_name, last_name)
VALUES (
'1349',
'James',
'Lee'
);


INSERT INTO flight
VALUES (
'1350',
'330',
'2020-12-10 05:30:00',
'LAS',
48,
'2020-12-10 06:00:00',
'DEN',
73,
'2020-12-10 08:00:00',
'Scheduled',
0,
100,
0,
100,
0,
100,
TRUE,
TRUE
);


INSERT INTO pilot (flight_id, first_name, last_name)
VALUES (
'1350',
'Michael',
'Davis'
);


INSERT INTO flight
VALUES (
'1351',
'318',
'2020-12-17 06:30:00',
'LAX',
97,
'2020-12-17 07:00:00',
'MCO',
95,
'2020-12-17 10:00:00',
'Scheduled',
0,
50,
0,
50,
0,
50,
FALSE,
FALSE
);


INSERT INTO pilot (flight_id, first_name, last_name)
VALUES (
'1351',
'Ethan',
'Smith'
);


INSERT INTO flight
VALUES (
'1352',
'345',
'2020-12-17 12:30:00',
'DFW',
96,
'2020-12-17 13:00:00',
'MCO',
55,
'2020-12-17 16:00:00',
'Scheduled',
0,
100,
0,
100,
0,
100,
TRUE,
TRUE
);


INSERT INTO pilot (flight_id, first_name, last_name)
VALUES (
'1352',
'John',
'Harris'
);


INSERT INTO flight
VALUES (
'1353',
'319',
'2020-12-17 03:30:00',
'DFW',
47,
'2020-12-17 04:00:00',
'DEN',
91,
'2020-12-17 06:00:00',
'Scheduled',
0,
50,
0,
50,
0,
50,
FALSE,
FALSE
);


INSERT INTO pilot (flight_id, first_name, last_name)
VALUES (
'1353',
'Alex',
'Wang'
);


INSERT INTO flight
VALUES (
'1354',
'342',
'2020-12-17 04:30:00',
'LAX',
109,
'2020-12-17 05:00:00',
'LAS',
84,
'2020-12-17 07:00:00',
'Scheduled',
0,
100,
0,
100,
0,
100,
TRUE,
TRUE
);


INSERT INTO pilot (flight_id, first_name, last_name)
VALUES (
'1354',
'William',
'Lee'
);


INSERT INTO flight
VALUES (
'1355',
'319',
'2020-12-17 09:30:00',
'ATL',
11,
'2020-12-17 10:00:00',
'LAS',
70,
'2020-12-17 13:00:00',
'Scheduled',
0,
50,
0,
50,
0,
50,
FALSE,
FALSE
);


INSERT INTO pilot (flight_id, first_name, last_name)
VALUES (
'1355',
'Ethan',
'Smith'
);


INSERT INTO flight
VALUES (
'1356',
'342',
'2020-12-17 06:30:00',
'LAS',
111,
'2020-12-17 07:00:00',
'LAX',
75,
'2020-12-17 10:00:00',
'Scheduled',
0,
100,
0,
100,
0,
100,
TRUE,
TRUE
);


INSERT INTO pilot (flight_id, first_name, last_name)
VALUES (
'1356',
'Ethan',
'Anderson'
);


INSERT INTO flight
VALUES (
'1357',
'340',
'2020-12-17 11:30:00',
'ORD',
45,
'2020-12-17 12:00:00',
'ATL',
3,
'2020-12-17 15:00:00',
'Scheduled',
0,
100,
0,
100,
0,
100,
TRUE,
TRUE
);


INSERT INTO pilot (flight_id, first_name, last_name)
VALUES (
'1357',
'James',
'Wang'
);


INSERT INTO flight
VALUES (
'1358',
'342',
'2020-12-17 07:30:00',
'ORD',
87,
'2020-12-17 08:00:00',
'JFK',
64,
'2020-12-17 10:00:00',
'Scheduled',
0,
100,
0,
100,
0,
100,
TRUE,
TRUE
);


INSERT INTO pilot (flight_id, first_name, last_name)
VALUES (
'1358',
'Jacob',
'Garcia'
);


INSERT INTO flight
VALUES (
'1359',
'319',
'2020-12-17 11:30:00',
'DEN',
95,
'2020-12-17 12:00:00',
'SFO',
9,
'2020-12-17 15:00:00',
'Scheduled',
0,
50,
0,
50,
0,
50,
FALSE,
FALSE
);


INSERT INTO pilot (flight_id, first_name, last_name)
VALUES (
'1359',
'William',
'Brown'
);


INSERT INTO flight
VALUES (
'1360',
'342',
'2020-12-17 11:30:00',
'SEA',
2,
'2020-12-17 12:00:00',
'ATL',
43,
'2020-12-17 15:00:00',
'Scheduled',
0,
100,
0,
100,
0,
100,
TRUE,
TRUE
);


INSERT INTO pilot (flight_id, first_name, last_name)
VALUES (
'1360',
'William',
'Harris'
);


INSERT INTO flight
VALUES (
'1361',
'340',
'2020-12-17 05:30:00',
'SEA',
20,
'2020-12-17 06:00:00',
'DFW',
23,
'2020-12-17 08:00:00',
'Scheduled',
0,
100,
0,
100,
0,
100,
TRUE,
TRUE
);


INSERT INTO pilot (flight_id, first_name, last_name)
VALUES (
'1361',
'Ethan',
'Brown'
);


INSERT INTO flight
VALUES (
'1362',
'321',
'2020-12-17 03:30:00',
'DFW',
23,
'2020-12-17 04:00:00',
'LAS',
7,
'2020-12-17 06:00:00',
'Scheduled',
0,
50,
0,
50,
0,
50,
FALSE,
FALSE
);


INSERT INTO pilot (flight_id, first_name, last_name)
VALUES (
'1362',
'Mason',
'Brown'
);


INSERT INTO flight
VALUES (
'1363',
'343',
'2020-12-17 09:30:00',
'DEN',
91,
'2020-12-17 10:00:00',
'ORD',
109,
'2020-12-17 13:00:00',
'Scheduled',
0,
100,
0,
100,
0,
100,
TRUE,
TRUE
);


INSERT INTO pilot (flight_id, first_name, last_name)
VALUES (
'1363',
'James',
'Anderson'
);


INSERT INTO flight
VALUES (
'1364',
'346',
'2020-12-17 03:30:00',
'JFK',
41,
'2020-12-17 04:00:00',
'ATL',
29,
'2020-12-17 06:00:00',
'Scheduled',
0,
100,
0,
100,
0,
100,
TRUE,
TRUE
);


INSERT INTO pilot (flight_id, first_name, last_name)
VALUES (
'1364',
'Liam',
'Davis'
);


INSERT INTO flight
VALUES (
'1365',
'318',
'2020-12-17 08:30:00',
'LAS',
40,
'2020-12-17 09:00:00',
'ORD',
42,
'2020-12-17 12:00:00',
'Scheduled',
0,
50,
0,
50,
0,
50,
FALSE,
FALSE
);


INSERT INTO pilot (flight_id, first_name, last_name)
VALUES (
'1365',
'Michael',
'Miller'
);


INSERT INTO flight
VALUES (
'1366',
'318',
'2020-12-17 08:30:00',
'MCO',
66,
'2020-12-17 09:00:00',
'ORD',
59,
'2020-12-17 12:00:00',
'Scheduled',
0,
50,
0,
50,
0,
50,
FALSE,
FALSE
);


INSERT INTO pilot (flight_id, first_name, last_name)
VALUES (
'1366',
'William',
'Garcia'
);


INSERT INTO flight
VALUES (
'1367',
'310',
'2020-12-17 03:30:00',
'DEN',
14,
'2020-12-17 04:00:00',
'ORD',
26,
'2020-12-17 06:00:00',
'Scheduled',
0,
100,
0,
100,
0,
100,
TRUE,
TRUE
);


INSERT INTO pilot (flight_id, first_name, last_name)
VALUES (
'1367',
'Noah',
'Anderson'
);


INSERT INTO flight
VALUES (
'1368',
'343',
'2020-12-17 12:30:00',
'SFO',
107,
'2020-12-17 13:00:00',
'SEA',
39,
'2020-12-17 16:00:00',
'Scheduled',
0,
100,
0,
100,
0,
100,
TRUE,
TRUE
);


INSERT INTO pilot (flight_id, first_name, last_name)
VALUES (
'1368',
'Michael',
'Davis'
);


INSERT INTO flight
VALUES (
'1369',
'340',
'2020-12-17 04:30:00',
'MCO',
10,
'2020-12-17 05:00:00',
'LAS',
76,
'2020-12-17 07:00:00',
'Scheduled',
0,
100,
0,
100,
0,
100,
TRUE,
TRUE
);


INSERT INTO pilot (flight_id, first_name, last_name)
VALUES (
'1369',
'Liam',
'Thomas'
);


INSERT INTO flight
VALUES (
'1370',
'319',
'2020-12-17 11:30:00',
'ATL',
38,
'2020-12-17 12:00:00',
'DEN',
99,
'2020-12-17 15:00:00',
'Scheduled',
0,
50,
0,
50,
0,
50,
FALSE,
FALSE
);


INSERT INTO pilot (flight_id, first_name, last_name)
VALUES (
'1370',
'John',
'Smith'
);


INSERT INTO flight
VALUES (
'1371',
'321',
'2020-12-17 08:30:00',
'DEN',
28,
'2020-12-17 09:00:00',
'SFO',
72,
'2020-12-17 12:00:00',
'Scheduled',
0,
50,
0,
50,
0,
50,
FALSE,
FALSE
);


INSERT INTO pilot (flight_id, first_name, last_name)
VALUES (
'1371',
'Alex',
'Wang'
);


INSERT INTO flight
VALUES (
'1372',
'310',
'2020-12-17 11:30:00',
'ATL',
12,
'2020-12-17 12:00:00',
'MCO',
92,
'2020-12-17 15:00:00',
'Scheduled',
0,
100,
0,
100,
0,
100,
TRUE,
TRUE
);


INSERT INTO pilot (flight_id, first_name, last_name)
VALUES (
'1372',
'John',
'Miller'
);


INSERT INTO flight
VALUES (
'1373',
'330',
'2020-12-17 04:30:00',
'SEA',
30,
'2020-12-17 05:00:00',
'JFK',
74,
'2020-12-17 07:00:00',
'Scheduled',
0,
100,
0,
100,
0,
100,
TRUE,
TRUE
);


INSERT INTO pilot (flight_id, first_name, last_name)
VALUES (
'1373',
'Michael',
'Anderson'
);


INSERT INTO flight
VALUES (
'1374',
'321',
'2020-12-17 12:30:00',
'MCO',
55,
'2020-12-17 13:00:00',
'LAS',
60,
'2020-12-17 16:00:00',
'Scheduled',
0,
50,
0,
50,
0,
50,
FALSE,
FALSE
);


INSERT INTO pilot (flight_id, first_name, last_name)
VALUES (
'1374',
'Noah',
'Anderson'
);


INSERT INTO flight
VALUES (
'1375',
'310',
'2020-12-17 04:30:00',
'SFO',
106,
'2020-12-17 05:00:00',
'SEA',
83,
'2020-12-17 07:00:00',
'Scheduled',
0,
100,
0,
100,
0,
100,
TRUE,
TRUE
);


INSERT INTO pilot (flight_id, first_name, last_name)
VALUES (
'1375',
'Ethan',
'Garcia'
);


INSERT INTO flight
VALUES (
'1376',
'310',
'2020-12-17 06:30:00',
'JFK',
16,
'2020-12-17 07:00:00',
'SEA',
64,
'2020-12-17 10:00:00',
'Scheduled',
0,
100,
0,
100,
0,
100,
TRUE,
TRUE
);


INSERT INTO pilot (flight_id, first_name, last_name)
VALUES (
'1376',
'Ethan',
'Miller'
);


INSERT INTO flight
VALUES (
'1377',
'319',
'2020-12-17 05:30:00',
'MCO',
13,
'2020-12-17 06:00:00',
'DEN',
110,
'2020-12-17 08:00:00',
'Scheduled',
0,
50,
0,
50,
0,
50,
FALSE,
FALSE
);


INSERT INTO pilot (flight_id, first_name, last_name)
VALUES (
'1377',
'Alex',
'Miller'
);


INSERT INTO flight
VALUES (
'1378',
'345',
'2020-12-17 06:30:00',
'ATL',
12,
'2020-12-17 07:00:00',
'MCO',
23,
'2020-12-17 10:00:00',
'Scheduled',
0,
100,
0,
100,
0,
100,
TRUE,
TRUE
);


INSERT INTO pilot (flight_id, first_name, last_name)
VALUES (
'1378',
'John',
'Miller'
);


INSERT INTO flight
VALUES (
'1379',
'321',
'2020-12-17 12:30:00',
'MCO',
62,
'2020-12-17 13:00:00',
'JFK',
109,
'2020-12-17 16:00:00',
'Scheduled',
0,
50,
0,
50,
0,
50,
FALSE,
FALSE
);


INSERT INTO pilot (flight_id, first_name, last_name)
VALUES (
'1379',
'Michael',
'Thomas'
);


INSERT INTO flight
VALUES (
'1380',
'343',
'2020-12-17 10:30:00',
'DEN',
32,
'2020-12-17 11:00:00',
'LAS',
30,
'2020-12-17 13:00:00',
'Scheduled',
0,
100,
0,
100,
0,
100,
TRUE,
TRUE
);


INSERT INTO pilot (flight_id, first_name, last_name)
VALUES (
'1380',
'Mason',
'Thomas'
);


INSERT INTO flight
VALUES (
'1381',
'346',
'2020-12-17 08:30:00',
'SFO',
103,
'2020-12-17 09:00:00',
'MCO',
49,
'2020-12-17 12:00:00',
'Scheduled',
0,
100,
0,
100,
0,
100,
TRUE,
TRUE
);


INSERT INTO pilot (flight_id, first_name, last_name)
VALUES (
'1381',
'John',
'Smith'
);


INSERT INTO flight
VALUES (
'1382',
'340',
'2020-12-17 03:30:00',
'DFW',
14,
'2020-12-17 04:00:00',
'MCO',
91,
'2020-12-17 06:00:00',
'Scheduled',
0,
100,
0,
100,
0,
100,
TRUE,
TRUE
);


INSERT INTO pilot (flight_id, first_name, last_name)
VALUES (
'1382',
'Michael',
'Davis'
);


INSERT INTO flight
VALUES (
'1383',
'342',
'2020-12-17 12:30:00',
'MCO',
30,
'2020-12-17 13:00:00',
'LAS',
80,
'2020-12-17 16:00:00',
'Scheduled',
0,
100,
0,
100,
0,
100,
TRUE,
TRUE
);


INSERT INTO pilot (flight_id, first_name, last_name)
VALUES (
'1383',
'Mason',
'Davis'
);


INSERT INTO flight
VALUES (
'1384',
'343',
'2020-12-17 08:30:00',
'JFK',
34,
'2020-12-17 09:00:00',
'DEN',
29,
'2020-12-17 12:00:00',
'Scheduled',
0,
100,
0,
100,
0,
100,
TRUE,
TRUE
);


INSERT INTO pilot (flight_id, first_name, last_name)
VALUES (
'1384',
'Mason',
'Lee'
);


INSERT INTO flight
VALUES (
'1385',
'310',
'2020-12-17 10:30:00',
'DEN',
63,
'2020-12-17 11:00:00',
'JFK',
26,
'2020-12-17 13:00:00',
'Scheduled',
0,
100,
0,
100,
0,
100,
TRUE,
TRUE
);


INSERT INTO pilot (flight_id, first_name, last_name)
VALUES (
'1385',
'Liam',
'Miller'
);


INSERT INTO flight
VALUES (
'1386',
'345',
'2020-12-17 06:30:00',
'ORD',
22,
'2020-12-17 07:00:00',
'LAS',
19,
'2020-12-17 10:00:00',
'Scheduled',
0,
100,
0,
100,
0,
100,
TRUE,
TRUE
);


INSERT INTO pilot (flight_id, first_name, last_name)
VALUES (
'1386',
'Jacob',
'Brown'
);


INSERT INTO flight
VALUES (
'1387',
'342',
'2020-12-17 11:30:00',
'DEN',
57,
'2020-12-17 12:00:00',
'SFO',
4,
'2020-12-17 15:00:00',
'Scheduled',
0,
100,
0,
100,
0,
100,
TRUE,
TRUE
);


INSERT INTO pilot (flight_id, first_name, last_name)
VALUES (
'1387',
'Liam',
'Anderson'
);


INSERT INTO flight
VALUES (
'1388',
'318',
'2020-12-17 06:30:00',
'JFK',
64,
'2020-12-17 07:00:00',
'SFO',
87,
'2020-12-17 10:00:00',
'Scheduled',
0,
50,
0,
50,
0,
50,
FALSE,
FALSE
);


INSERT INTO pilot (flight_id, first_name, last_name)
VALUES (
'1388',
'Noah',
'Miller'
);


INSERT INTO flight
VALUES (
'1389',
'343',
'2020-12-17 11:30:00',
'SFO',
78,
'2020-12-17 12:00:00',
'DEN',
88,
'2020-12-17 15:00:00',
'Scheduled',
0,
100,
0,
100,
0,
100,
TRUE,
TRUE
);


INSERT INTO pilot (flight_id, first_name, last_name)
VALUES (
'1389',
'Alex',
'Brown'
);


INSERT INTO flight
VALUES (
'1390',
'345',
'2020-12-17 04:30:00',
'LAS',
19,
'2020-12-17 05:00:00',
'ORD',
99,
'2020-12-17 07:00:00',
'Scheduled',
0,
100,
0,
100,
0,
100,
TRUE,
TRUE
);


INSERT INTO pilot (flight_id, first_name, last_name)
VALUES (
'1390',
'James',
'Lee'
);


INSERT INTO flight
VALUES (
'1391',
'340',
'2020-12-17 06:30:00',
'DFW',
13,
'2020-12-17 07:00:00',
'DEN',
58,
'2020-12-17 10:00:00',
'Scheduled',
0,
100,
0,
100,
0,
100,
TRUE,
TRUE
);


INSERT INTO pilot (flight_id, first_name, last_name)
VALUES (
'1391',
'Mason',
'Anderson'
);


INSERT INTO flight
VALUES (
'1392',
'345',
'2020-12-17 06:30:00',
'ATL',
85,
'2020-12-17 07:00:00',
'MCO',
28,
'2020-12-17 10:00:00',
'Scheduled',
0,
100,
0,
100,
0,
100,
TRUE,
TRUE
);


INSERT INTO pilot (flight_id, first_name, last_name)
VALUES (
'1392',
'John',
'Thomas'
);


INSERT INTO flight
VALUES (
'1393',
'342',
'2020-12-17 03:30:00',
'ORD',
15,
'2020-12-17 04:00:00',
'LAS',
67,
'2020-12-17 06:00:00',
'Scheduled',
0,
100,
0,
100,
0,
100,
TRUE,
TRUE
);


INSERT INTO pilot (flight_id, first_name, last_name)
VALUES (
'1393',
'Alex',
'Davis'
);


INSERT INTO flight
VALUES (
'1394',
'330',
'2020-12-17 10:30:00',
'JFK',
67,
'2020-12-17 11:00:00',
'ATL',
34,
'2020-12-17 13:00:00',
'Scheduled',
0,
100,
0,
100,
0,
100,
TRUE,
TRUE
);


INSERT INTO pilot (flight_id, first_name, last_name)
VALUES (
'1394',
'Alex',
'Garcia'
);


INSERT INTO flight
VALUES (
'1395',
'310',
'2020-12-17 08:30:00',
'ATL',
99,
'2020-12-17 09:00:00',
'ORD',
111,
'2020-12-17 12:00:00',
'Scheduled',
0,
100,
0,
100,
0,
100,
TRUE,
TRUE
);


INSERT INTO pilot (flight_id, first_name, last_name)
VALUES (
'1395',
'Mason',
'Wang'
);


INSERT INTO flight
VALUES (
'1396',
'340',
'2020-12-17 04:30:00',
'ORD',
66,
'2020-12-17 05:00:00',
'LAX',
27,
'2020-12-17 07:00:00',
'Scheduled',
0,
100,
0,
100,
0,
100,
TRUE,
TRUE
);


INSERT INTO pilot (flight_id, first_name, last_name)
VALUES (
'1396',
'William',
'Anderson'
);


INSERT INTO flight
VALUES (
'1397',
'346',
'2020-12-17 10:30:00',
'DEN',
83,
'2020-12-17 11:00:00',
'LAX',
36,
'2020-12-17 13:00:00',
'Scheduled',
0,
100,
0,
100,
0,
100,
TRUE,
TRUE
);


INSERT INTO pilot (flight_id, first_name, last_name)
VALUES (
'1397',
'Noah',
'Smith'
);


INSERT INTO flight
VALUES (
'1398',
'310',
'2020-12-17 07:30:00',
'SFO',
85,
'2020-12-17 08:00:00',
'MCO',
23,
'2020-12-17 10:00:00',
'Scheduled',
0,
100,
0,
100,
0,
100,
TRUE,
TRUE
);


INSERT INTO pilot (flight_id, first_name, last_name)
VALUES (
'1398',
'Mason',
'Miller'
);


INSERT INTO flight
VALUES (
'1399',
'343',
'2020-12-17 07:30:00',
'DEN',
62,
'2020-12-17 08:00:00',
'LAX',
11,
'2020-12-17 10:00:00',
'Scheduled',
0,
100,
0,
100,
0,
100,
TRUE,
TRUE
);


INSERT INTO pilot (flight_id, first_name, last_name)
VALUES (
'1399',
'Michael',
'Wang'
);


INSERT INTO flight
VALUES (
'1400',
'345',
'2020-12-10 12:30:00',
'SEA',
75,
'2020-12-10 13:00:00',
'DFW',
27,
'2020-12-10 16:00:00',
'Scheduled',
0,
100,
0,
100,
0,
100,
TRUE,
TRUE
);


INSERT INTO pilot (flight_id, first_name, last_name)
VALUES (
'1400',
'Noah',
'Smith'
);


INSERT INTO flight
VALUES (
'1401',
'318',
'2020-12-18 05:30:00',
'LAX',
6,
'2020-12-18 06:00:00',
'DEN',
12,
'2020-12-18 08:00:00',
'Scheduled',
0,
50,
0,
50,
0,
50,
FALSE,
FALSE
);


INSERT INTO pilot (flight_id, first_name, last_name)
VALUES (
'1401',
'James',
'Davis'
);


INSERT INTO flight
VALUES (
'1402',
'343',
'2020-12-18 06:30:00',
'LAS',
74,
'2020-12-18 07:00:00',
'MCO',
105,
'2020-12-18 10:00:00',
'Scheduled',
0,
100,
0,
100,
0,
100,
TRUE,
TRUE
);


INSERT INTO pilot (flight_id, first_name, last_name)
VALUES (
'1402',
'Noah',
'Lee'
);


INSERT INTO flight
VALUES (
'1403',
'318',
'2020-12-18 11:30:00',
'JFK',
101,
'2020-12-18 12:00:00',
'MCO',
32,
'2020-12-18 15:00:00',
'Scheduled',
0,
50,
0,
50,
0,
50,
FALSE,
FALSE
);


INSERT INTO pilot (flight_id, first_name, last_name)
VALUES (
'1403',
'Ethan',
'Miller'
);


INSERT INTO flight
VALUES (
'1404',
'343',
'2020-12-18 08:30:00',
'SEA',
12,
'2020-12-18 09:00:00',
'ATL',
36,
'2020-12-18 12:00:00',
'Scheduled',
0,
100,
0,
100,
0,
100,
TRUE,
TRUE
);


INSERT INTO pilot (flight_id, first_name, last_name)
VALUES (
'1404',
'James',
'Davis'
);


INSERT INTO flight
VALUES (
'1405',
'340',
'2020-12-18 03:30:00',
'LAX',
29,
'2020-12-18 04:00:00',
'MCO',
65,
'2020-12-18 06:00:00',
'Scheduled',
0,
100,
0,
100,
0,
100,
TRUE,
TRUE
);


INSERT INTO pilot (flight_id, first_name, last_name)
VALUES (
'1405',
'Liam',
'Harris'
);


INSERT INTO flight
VALUES (
'1406',
'345',
'2020-12-18 09:30:00',
'SFO',
10,
'2020-12-18 10:00:00',
'DFW',
14,
'2020-12-18 13:00:00',
'Scheduled',
0,
100,
0,
100,
0,
100,
TRUE,
TRUE
);


INSERT INTO pilot (flight_id, first_name, last_name)
VALUES (
'1406',
'Liam',
'Wang'
);


INSERT INTO flight
VALUES (
'1407',
'321',
'2020-12-18 06:30:00',
'MCO',
75,
'2020-12-18 07:00:00',
'ATL',
72,
'2020-12-18 10:00:00',
'Scheduled',
0,
50,
0,
50,
0,
50,
FALSE,
FALSE
);


INSERT INTO pilot (flight_id, first_name, last_name)
VALUES (
'1407',
'Liam',
'Wang'
);


INSERT INTO flight
VALUES (
'1408',
'342',
'2020-12-18 06:30:00',
'SEA',
93,
'2020-12-18 07:00:00',
'LAX',
99,
'2020-12-18 10:00:00',
'Scheduled',
0,
100,
0,
100,
0,
100,
TRUE,
TRUE
);


INSERT INTO pilot (flight_id, first_name, last_name)
VALUES (
'1408',
'Michael',
'Lee'
);


INSERT INTO flight
VALUES (
'1409',
'310',
'2020-12-18 04:30:00',
'SEA',
2,
'2020-12-18 05:00:00',
'LAX',
16,
'2020-12-18 07:00:00',
'Scheduled',
0,
100,
0,
100,
0,
100,
TRUE,
TRUE
);


INSERT INTO pilot (flight_id, first_name, last_name)
VALUES (
'1409',
'Jacob',
'Davis'
);


INSERT INTO flight
VALUES (
'1410',
'346',
'2020-12-18 06:30:00',
'SEA',
90,
'2020-12-18 07:00:00',
'JFK',
104,
'2020-12-18 10:00:00',
'Scheduled',
0,
100,
0,
100,
0,
100,
TRUE,
TRUE
);


INSERT INTO pilot (flight_id, first_name, last_name)
VALUES (
'1410',
'Mason',
'Wang'
);


INSERT INTO flight
VALUES (
'1411',
'310',
'2020-12-18 10:30:00',
'MCO',
43,
'2020-12-18 11:00:00',
'SFO',
24,
'2020-12-18 13:00:00',
'Scheduled',
0,
100,
0,
100,
0,
100,
TRUE,
TRUE
);


INSERT INTO pilot (flight_id, first_name, last_name)
VALUES (
'1411',
'Mason',
'Davis'
);


INSERT INTO flight
VALUES (
'1412',
'346',
'2020-12-18 04:30:00',
'LAS',
99,
'2020-12-18 05:00:00',
'MCO',
107,
'2020-12-18 07:00:00',
'Scheduled',
0,
100,
0,
100,
0,
100,
TRUE,
TRUE
);


INSERT INTO pilot (flight_id, first_name, last_name)
VALUES (
'1412',
'Alex',
'Brown'
);


INSERT INTO flight
VALUES (
'1413',
'321',
'2020-12-18 07:30:00',
'JFK',
18,
'2020-12-18 08:00:00',
'ORD',
47,
'2020-12-18 10:00:00',
'Scheduled',
0,
50,
0,
50,
0,
50,
FALSE,
FALSE
);


INSERT INTO pilot (flight_id, first_name, last_name)
VALUES (
'1413',
'Ethan',
'Smith'
);


INSERT INTO flight
VALUES (
'1414',
'319',
'2020-12-18 11:30:00',
'ORD',
9,
'2020-12-18 12:00:00',
'LAX',
110,
'2020-12-18 15:00:00',
'Scheduled',
0,
50,
0,
50,
0,
50,
FALSE,
FALSE
);


INSERT INTO pilot (flight_id, first_name, last_name)
VALUES (
'1414',
'Mason',
'Harris'
);


INSERT INTO flight
VALUES (
'1415',
'321',
'2020-12-18 08:30:00',
'DFW',
47,
'2020-12-18 09:00:00',
'DEN',
18,
'2020-12-18 12:00:00',
'Scheduled',
0,
50,
0,
50,
0,
50,
FALSE,
FALSE
);


INSERT INTO pilot (flight_id, first_name, last_name)
VALUES (
'1415',
'Jacob',
'Brown'
);


INSERT INTO flight
VALUES (
'1416',
'319',
'2020-12-18 12:30:00',
'LAX',
22,
'2020-12-18 13:00:00',
'JFK',
6,
'2020-12-18 16:00:00',
'Scheduled',
0,
50,
0,
50,
0,
50,
FALSE,
FALSE
);


INSERT INTO pilot (flight_id, first_name, last_name)
VALUES (
'1416',
'James',
'Smith'
);


INSERT INTO flight
VALUES (
'1417',
'321',
'2020-12-18 11:30:00',
'JFK',
44,
'2020-12-18 12:00:00',
'ORD',
110,
'2020-12-18 15:00:00',
'Scheduled',
0,
50,
0,
50,
0,
50,
FALSE,
FALSE
);


INSERT INTO pilot (flight_id, first_name, last_name)
VALUES (
'1417',
'Noah',
'Anderson'
);


INSERT INTO flight
VALUES (
'1418',
'319',
'2020-12-18 03:30:00',
'ATL',
62,
'2020-12-18 04:00:00',
'LAX',
74,
'2020-12-18 06:00:00',
'Scheduled',
0,
50,
0,
50,
0,
50,
FALSE,
FALSE
);


INSERT INTO pilot (flight_id, first_name, last_name)
VALUES (
'1418',
'Ethan',
'Davis'
);


INSERT INTO flight
VALUES (
'1419',
'340',
'2020-12-18 11:30:00',
'SFO',
91,
'2020-12-18 12:00:00',
'LAX',
44,
'2020-12-18 15:00:00',
'Scheduled',
0,
100,
0,
100,
0,
100,
TRUE,
TRUE
);


INSERT INTO pilot (flight_id, first_name, last_name)
VALUES (
'1419',
'Mason',
'Wang'
);


INSERT INTO flight
VALUES (
'1420',
'319',
'2020-12-18 12:30:00',
'MCO',
60,
'2020-12-18 13:00:00',
'SEA',
50,
'2020-12-18 16:00:00',
'Scheduled',
0,
50,
0,
50,
0,
50,
FALSE,
FALSE
);


INSERT INTO pilot (flight_id, first_name, last_name)
VALUES (
'1420',
'Mason',
'Brown'
);


INSERT INTO flight
VALUES (
'1421',
'318',
'2020-12-18 08:30:00',
'ATL',
55,
'2020-12-18 09:00:00',
'SFO',
59,
'2020-12-18 12:00:00',
'Scheduled',
0,
50,
0,
50,
0,
50,
FALSE,
FALSE
);


INSERT INTO pilot (flight_id, first_name, last_name)
VALUES (
'1421',
'Jacob',
'Davis'
);


INSERT INTO flight
VALUES (
'1422',
'330',
'2020-12-18 10:30:00',
'MCO',
36,
'2020-12-18 11:00:00',
'ATL',
65,
'2020-12-18 13:00:00',
'Scheduled',
0,
100,
0,
100,
0,
100,
TRUE,
TRUE
);


INSERT INTO pilot (flight_id, first_name, last_name)
VALUES (
'1422',
'Ethan',
'Miller'
);


INSERT INTO flight
VALUES (
'1423',
'346',
'2020-12-18 04:30:00',
'SEA',
23,
'2020-12-18 05:00:00',
'ATL',
38,
'2020-12-18 07:00:00',
'Scheduled',
0,
100,
0,
100,
0,
100,
TRUE,
TRUE
);


INSERT INTO pilot (flight_id, first_name, last_name)
VALUES (
'1423',
'Jacob',
'Wang'
);


INSERT INTO flight
VALUES (
'1424',
'319',
'2020-12-18 09:30:00',
'MCO',
39,
'2020-12-18 10:00:00',
'ORD',
41,
'2020-12-18 13:00:00',
'Scheduled',
0,
50,
0,
50,
0,
50,
FALSE,
FALSE
);


INSERT INTO pilot (flight_id, first_name, last_name)
VALUES (
'1424',
'William',
'Wang'
);


INSERT INTO flight
VALUES (
'1425',
'346',
'2020-12-18 12:30:00',
'MCO',
90,
'2020-12-18 13:00:00',
'SFO',
43,
'2020-12-18 16:00:00',
'Scheduled',
0,
100,
0,
100,
0,
100,
TRUE,
TRUE
);


INSERT INTO pilot (flight_id, first_name, last_name)
VALUES (
'1425',
'James',
'Harris'
);


INSERT INTO flight
VALUES (
'1426',
'310',
'2020-12-18 09:30:00',
'DEN',
45,
'2020-12-18 10:00:00',
'JFK',
7,
'2020-12-18 13:00:00',
'Scheduled',
0,
100,
0,
100,
0,
100,
TRUE,
TRUE
);


INSERT INTO pilot (flight_id, first_name, last_name)
VALUES (
'1426',
'Liam',
'Davis'
);


INSERT INTO flight
VALUES (
'1427',
'321',
'2020-12-18 06:30:00',
'ATL',
20,
'2020-12-18 07:00:00',
'ORD',
1,
'2020-12-18 10:00:00',
'Scheduled',
0,
50,
0,
50,
0,
50,
FALSE,
FALSE
);


INSERT INTO pilot (flight_id, first_name, last_name)
VALUES (
'1427',
'Mason',
'Wang'
);


INSERT INTO flight
VALUES (
'1428',
'343',
'2020-12-18 04:30:00',
'SEA',
47,
'2020-12-18 05:00:00',
'DEN',
29,
'2020-12-18 07:00:00',
'Scheduled',
0,
100,
0,
100,
0,
100,
TRUE,
TRUE
);


INSERT INTO pilot (flight_id, first_name, last_name)
VALUES (
'1428',
'James',
'Lee'
);


INSERT INTO flight
VALUES (
'1429',
'319',
'2020-12-18 12:30:00',
'JFK',
28,
'2020-12-18 13:00:00',
'MCO',
28,
'2020-12-18 16:00:00',
'Scheduled',
0,
50,
0,
50,
0,
50,
FALSE,
FALSE
);


INSERT INTO pilot (flight_id, first_name, last_name)
VALUES (
'1429',
'Jacob',
'Davis'
);


INSERT INTO flight
VALUES (
'1430',
'319',
'2020-12-18 08:30:00',
'SFO',
6,
'2020-12-18 09:00:00',
'ORD',
78,
'2020-12-18 12:00:00',
'Scheduled',
0,
50,
0,
50,
0,
50,
FALSE,
FALSE
);


INSERT INTO pilot (flight_id, first_name, last_name)
VALUES (
'1430',
'Noah',
'Lee'
);


INSERT INTO flight
VALUES (
'1431',
'340',
'2020-12-18 11:30:00',
'MCO',
107,
'2020-12-18 12:00:00',
'JFK',
54,
'2020-12-18 15:00:00',
'Scheduled',
0,
100,
0,
100,
0,
100,
TRUE,
TRUE
);


INSERT INTO pilot (flight_id, first_name, last_name)
VALUES (
'1431',
'John',
'Thomas'
);


INSERT INTO flight
VALUES (
'1432',
'319',
'2020-12-18 09:30:00',
'ATL',
110,
'2020-12-18 10:00:00',
'JFK',
45,
'2020-12-18 13:00:00',
'Scheduled',
0,
50,
0,
50,
0,
50,
FALSE,
FALSE
);


INSERT INTO pilot (flight_id, first_name, last_name)
VALUES (
'1432',
'Jacob',
'Harris'
);


INSERT INTO flight
VALUES (
'1433',
'340',
'2020-12-18 07:30:00',
'DFW',
22,
'2020-12-18 08:00:00',
'SFO',
44,
'2020-12-18 10:00:00',
'Scheduled',
0,
100,
0,
100,
0,
100,
TRUE,
TRUE
);


INSERT INTO pilot (flight_id, first_name, last_name)
VALUES (
'1433',
'Liam',
'Wang'
);


INSERT INTO flight
VALUES (
'1434',
'346',
'2020-12-18 03:30:00',
'MCO',
35,
'2020-12-18 04:00:00',
'DEN',
43,
'2020-12-18 06:00:00',
'Scheduled',
0,
100,
0,
100,
0,
100,
TRUE,
TRUE
);


INSERT INTO pilot (flight_id, first_name, last_name)
VALUES (
'1434',
'Alex',
'Harris'
);


INSERT INTO flight
VALUES (
'1435',
'342',
'2020-12-18 12:30:00',
'MCO',
42,
'2020-12-18 13:00:00',
'LAS',
59,
'2020-12-18 16:00:00',
'Scheduled',
0,
100,
0,
100,
0,
100,
TRUE,
TRUE
);


INSERT INTO pilot (flight_id, first_name, last_name)
VALUES (
'1435',
'Noah',
'Harris'
);


INSERT INTO flight
VALUES (
'1436',
'342',
'2020-12-18 10:30:00',
'LAS',
27,
'2020-12-18 11:00:00',
'ATL',
2,
'2020-12-18 13:00:00',
'Scheduled',
0,
100,
0,
100,
0,
100,
TRUE,
TRUE
);


INSERT INTO pilot (flight_id, first_name, last_name)
VALUES (
'1436',
'James',
'Miller'
);


INSERT INTO flight
VALUES (
'1437',
'318',
'2020-12-18 07:30:00',
'SEA',
10,
'2020-12-18 08:00:00',
'DFW',
44,
'2020-12-18 10:00:00',
'Scheduled',
0,
50,
0,
50,
0,
50,
FALSE,
FALSE
);


INSERT INTO pilot (flight_id, first_name, last_name)
VALUES (
'1437',
'Jacob',
'Lee'
);


INSERT INTO flight
VALUES (
'1438',
'342',
'2020-12-18 06:30:00',
'SFO',
63,
'2020-12-18 07:00:00',
'ORD',
92,
'2020-12-18 10:00:00',
'Scheduled',
0,
100,
0,
100,
0,
100,
TRUE,
TRUE
);


INSERT INTO pilot (flight_id, first_name, last_name)
VALUES (
'1438',
'James',
'Harris'
);


INSERT INTO flight
VALUES (
'1439',
'330',
'2020-12-18 03:30:00',
'SFO',
33,
'2020-12-18 04:00:00',
'ATL',
91,
'2020-12-18 06:00:00',
'Scheduled',
0,
100,
0,
100,
0,
100,
TRUE,
TRUE
);


INSERT INTO pilot (flight_id, first_name, last_name)
VALUES (
'1439',
'Michael',
'Garcia'
);


INSERT INTO flight
VALUES (
'1440',
'343',
'2020-12-18 04:30:00',
'LAX',
17,
'2020-12-18 05:00:00',
'LAS',
20,
'2020-12-18 07:00:00',
'Scheduled',
0,
100,
0,
100,
0,
100,
TRUE,
TRUE
);


INSERT INTO pilot (flight_id, first_name, last_name)
VALUES (
'1440',
'Liam',
'Wang'
);


INSERT INTO flight
VALUES (
'1441',
'318',
'2020-12-18 11:30:00',
'LAX',
92,
'2020-12-18 12:00:00',
'ORD',
60,
'2020-12-18 15:00:00',
'Scheduled',
0,
50,
0,
50,
0,
50,
FALSE,
FALSE
);


INSERT INTO pilot (flight_id, first_name, last_name)
VALUES (
'1441',
'John',
'Davis'
);


INSERT INTO flight
VALUES (
'1442',
'345',
'2020-12-18 03:30:00',
'SEA',
38,
'2020-12-18 04:00:00',
'JFK',
2,
'2020-12-18 06:00:00',
'Scheduled',
0,
100,
0,
100,
0,
100,
TRUE,
TRUE
);


INSERT INTO pilot (flight_id, first_name, last_name)
VALUES (
'1442',
'Liam',
'Brown'
);


INSERT INTO flight
VALUES (
'1443',
'343',
'2020-12-18 07:30:00',
'DEN',
62,
'2020-12-18 08:00:00',
'MCO',
65,
'2020-12-18 10:00:00',
'Scheduled',
0,
100,
0,
100,
0,
100,
TRUE,
TRUE
);


INSERT INTO pilot (flight_id, first_name, last_name)
VALUES (
'1443',
'Noah',
'Harris'
);


INSERT INTO flight
VALUES (
'1444',
'342',
'2020-12-18 12:30:00',
'SFO',
24,
'2020-12-18 13:00:00',
'MCO',
96,
'2020-12-18 16:00:00',
'Scheduled',
0,
100,
0,
100,
0,
100,
TRUE,
TRUE
);


INSERT INTO pilot (flight_id, first_name, last_name)
VALUES (
'1444',
'Alex',
'Miller'
);


INSERT INTO flight
VALUES (
'1445',
'340',
'2020-12-18 07:30:00',
'DFW',
25,
'2020-12-18 08:00:00',
'DEN',
64,
'2020-12-18 10:00:00',
'Scheduled',
0,
100,
0,
100,
0,
100,
TRUE,
TRUE
);


INSERT INTO pilot (flight_id, first_name, last_name)
VALUES (
'1445',
'Michael',
'Harris'
);


INSERT INTO flight
VALUES (
'1446',
'318',
'2020-12-18 04:30:00',
'LAS',
44,
'2020-12-18 05:00:00',
'SEA',
55,
'2020-12-18 07:00:00',
'Scheduled',
0,
50,
0,
50,
0,
50,
FALSE,
FALSE
);


INSERT INTO pilot (flight_id, first_name, last_name)
VALUES (
'1446',
'William',
'Davis'
);


INSERT INTO flight
VALUES (
'1447',
'342',
'2020-12-18 10:30:00',
'DFW',
28,
'2020-12-18 11:00:00',
'LAS',
76,
'2020-12-18 13:00:00',
'Scheduled',
0,
100,
0,
100,
0,
100,
TRUE,
TRUE
);


INSERT INTO pilot (flight_id, first_name, last_name)
VALUES (
'1447',
'Mason',
'Anderson'
);


INSERT INTO flight
VALUES (
'1448',
'330',
'2020-12-18 07:30:00',
'LAX',
33,
'2020-12-18 08:00:00',
'ORD',
81,
'2020-12-18 10:00:00',
'Scheduled',
0,
100,
0,
100,
0,
100,
TRUE,
TRUE
);


INSERT INTO pilot (flight_id, first_name, last_name)
VALUES (
'1448',
'Mason',
'Garcia'
);


INSERT INTO flight
VALUES (
'1449',
'318',
'2020-12-18 11:30:00',
'LAS',
88,
'2020-12-18 12:00:00',
'ORD',
12,
'2020-12-18 15:00:00',
'Scheduled',
0,
50,
0,
50,
0,
50,
FALSE,
FALSE
);


INSERT INTO pilot (flight_id, first_name, last_name)
VALUES (
'1449',
'Alex',
'Thomas'
);


INSERT INTO flight
VALUES (
'1450',
'321',
'2020-12-10 03:30:00',
'SFO',
83,
'2020-12-10 04:00:00',
'DEN',
34,
'2020-12-10 06:00:00',
'Scheduled',
0,
50,
0,
50,
0,
50,
FALSE,
FALSE
);


INSERT INTO pilot (flight_id, first_name, last_name)
VALUES (
'1450',
'Jacob',
'Anderson'
);


INSERT INTO flight
VALUES (
'1451',
'345',
'2020-12-19 06:30:00',
'SEA',
103,
'2020-12-19 07:00:00',
'LAX',
78,
'2020-12-19 10:00:00',
'Scheduled',
0,
100,
0,
100,
0,
100,
TRUE,
TRUE
);


INSERT INTO pilot (flight_id, first_name, last_name)
VALUES (
'1451',
'Liam',
'Anderson'
);


INSERT INTO flight
VALUES (
'1452',
'346',
'2020-12-19 05:30:00',
'DFW',
2,
'2020-12-19 06:00:00',
'LAX',
103,
'2020-12-19 08:00:00',
'Scheduled',
0,
100,
0,
100,
0,
100,
TRUE,
TRUE
);


INSERT INTO pilot (flight_id, first_name, last_name)
VALUES (
'1452',
'Noah',
'Davis'
);


INSERT INTO flight
VALUES (
'1453',
'321',
'2020-12-19 11:30:00',
'JFK',
2,
'2020-12-19 12:00:00',
'LAX',
14,
'2020-12-19 15:00:00',
'Scheduled',
0,
50,
0,
50,
0,
50,
FALSE,
FALSE
);


INSERT INTO pilot (flight_id, first_name, last_name)
VALUES (
'1453',
'Michael',
'Anderson'
);


INSERT INTO flight
VALUES (
'1454',
'342',
'2020-12-19 09:30:00',
'MCO',
30,
'2020-12-19 10:00:00',
'ORD',
26,
'2020-12-19 13:00:00',
'Scheduled',
0,
100,
0,
100,
0,
100,
TRUE,
TRUE
);


INSERT INTO pilot (flight_id, first_name, last_name)
VALUES (
'1454',
'Michael',
'Thomas'
);


INSERT INTO flight
VALUES (
'1455',
'340',
'2020-12-19 06:30:00',
'ATL',
94,
'2020-12-19 07:00:00',
'SFO',
9,
'2020-12-19 10:00:00',
'Scheduled',
0,
100,
0,
100,
0,
100,
TRUE,
TRUE
);


INSERT INTO pilot (flight_id, first_name, last_name)
VALUES (
'1455',
'Michael',
'Smith'
);


INSERT INTO flight
VALUES (
'1456',
'340',
'2020-12-19 04:30:00',
'ORD',
98,
'2020-12-19 05:00:00',
'MCO',
10,
'2020-12-19 07:00:00',
'Scheduled',
0,
100,
0,
100,
0,
100,
TRUE,
TRUE
);


INSERT INTO pilot (flight_id, first_name, last_name)
VALUES (
'1456',
'William',
'Davis'
);


INSERT INTO flight
VALUES (
'1457',
'321',
'2020-12-19 10:30:00',
'DEN',
73,
'2020-12-19 11:00:00',
'DFW',
27,
'2020-12-19 13:00:00',
'Scheduled',
0,
50,
0,
50,
0,
50,
FALSE,
FALSE
);


INSERT INTO pilot (flight_id, first_name, last_name)
VALUES (
'1457',
'Michael',
'Lee'
);


INSERT INTO flight
VALUES (
'1458',
'345',
'2020-12-19 08:30:00',
'LAS',
99,
'2020-12-19 09:00:00',
'SEA',
57,
'2020-12-19 12:00:00',
'Scheduled',
0,
100,
0,
100,
0,
100,
TRUE,
TRUE
);


INSERT INTO pilot (flight_id, first_name, last_name)
VALUES (
'1458',
'Liam',
'Anderson'
);


INSERT INTO flight
VALUES (
'1459',
'330',
'2020-12-19 11:30:00',
'ATL',
39,
'2020-12-19 12:00:00',
'ORD',
47,
'2020-12-19 15:00:00',
'Scheduled',
0,
100,
0,
100,
0,
100,
TRUE,
TRUE
);


INSERT INTO pilot (flight_id, first_name, last_name)
VALUES (
'1459',
'Mason',
'Smith'
);


INSERT INTO flight
VALUES (
'1460',
'342',
'2020-12-19 08:30:00',
'JFK',
58,
'2020-12-19 09:00:00',
'ORD',
26,
'2020-12-19 12:00:00',
'Scheduled',
0,
100,
0,
100,
0,
100,
TRUE,
TRUE
);


INSERT INTO pilot (flight_id, first_name, last_name)
VALUES (
'1460',
'Liam',
'Wang'
);


INSERT INTO flight
VALUES (
'1461',
'321',
'2020-12-19 09:30:00',
'JFK',
57,
'2020-12-19 10:00:00',
'MCO',
62,
'2020-12-19 13:00:00',
'Scheduled',
0,
50,
0,
50,
0,
50,
FALSE,
FALSE
);


INSERT INTO pilot (flight_id, first_name, last_name)
VALUES (
'1461',
'Noah',
'Wang'
);


INSERT INTO flight
VALUES (
'1462',
'345',
'2020-12-19 06:30:00',
'SEA',
82,
'2020-12-19 07:00:00',
'JFK',
50,
'2020-12-19 10:00:00',
'Scheduled',
0,
100,
0,
100,
0,
100,
TRUE,
TRUE
);


INSERT INTO pilot (flight_id, first_name, last_name)
VALUES (
'1462',
'Ethan',
'Harris'
);


INSERT INTO flight
VALUES (
'1463',
'343',
'2020-12-19 11:30:00',
'SFO',
66,
'2020-12-19 12:00:00',
'ORD',
61,
'2020-12-19 15:00:00',
'Scheduled',
0,
100,
0,
100,
0,
100,
TRUE,
TRUE
);


INSERT INTO pilot (flight_id, first_name, last_name)
VALUES (
'1463',
'Alex',
'Brown'
);


INSERT INTO flight
VALUES (
'1464',
'346',
'2020-12-19 09:30:00',
'ORD',
62,
'2020-12-19 10:00:00',
'LAS',
91,
'2020-12-19 13:00:00',
'Scheduled',
0,
100,
0,
100,
0,
100,
TRUE,
TRUE
);


INSERT INTO pilot (flight_id, first_name, last_name)
VALUES (
'1464',
'John',
'Brown'
);


INSERT INTO flight
VALUES (
'1465',
'346',
'2020-12-19 08:30:00',
'ORD',
109,
'2020-12-19 09:00:00',
'SEA',
29,
'2020-12-19 12:00:00',
'Scheduled',
0,
100,
0,
100,
0,
100,
TRUE,
TRUE
);


INSERT INTO pilot (flight_id, first_name, last_name)
VALUES (
'1465',
'Michael',
'Lee'
);


INSERT INTO flight
VALUES (
'1466',
'345',
'2020-12-19 09:30:00',
'ORD',
19,
'2020-12-19 10:00:00',
'JFK',
100,
'2020-12-19 13:00:00',
'Scheduled',
0,
100,
0,
100,
0,
100,
TRUE,
TRUE
);


INSERT INTO pilot (flight_id, first_name, last_name)
VALUES (
'1466',
'Michael',
'Harris'
);


INSERT INTO flight
VALUES (
'1467',
'319',
'2020-12-19 06:30:00',
'LAS',
75,
'2020-12-19 07:00:00',
'MCO',
107,
'2020-12-19 10:00:00',
'Scheduled',
0,
50,
0,
50,
0,
50,
FALSE,
FALSE
);


INSERT INTO pilot (flight_id, first_name, last_name)
VALUES (
'1467',
'John',
'Garcia'
);


INSERT INTO flight
VALUES (
'1468',
'340',
'2020-12-19 03:30:00',
'DFW',
79,
'2020-12-19 04:00:00',
'SFO',
12,
'2020-12-19 06:00:00',
'Scheduled',
0,
100,
0,
100,
0,
100,
TRUE,
TRUE
);


INSERT INTO pilot (flight_id, first_name, last_name)
VALUES (
'1468',
'John',
'Anderson'
);


INSERT INTO flight
VALUES (
'1469',
'343',
'2020-12-19 07:30:00',
'DFW',
34,
'2020-12-19 08:00:00',
'SFO',
76,
'2020-12-19 10:00:00',
'Scheduled',
0,
100,
0,
100,
0,
100,
TRUE,
TRUE
);


INSERT INTO pilot (flight_id, first_name, last_name)
VALUES (
'1469',
'Liam',
'Brown'
);


INSERT INTO flight
VALUES (
'1470',
'342',
'2020-12-19 10:30:00',
'JFK',
73,
'2020-12-19 11:00:00',
'LAX',
20,
'2020-12-19 13:00:00',
'Scheduled',
0,
100,
0,
100,
0,
100,
TRUE,
TRUE
);


INSERT INTO pilot (flight_id, first_name, last_name)
VALUES (
'1470',
'Noah',
'Garcia'
);


INSERT INTO flight
VALUES (
'1471',
'343',
'2020-12-19 06:30:00',
'DFW',
19,
'2020-12-19 07:00:00',
'JFK',
73,
'2020-12-19 10:00:00',
'Scheduled',
0,
100,
0,
100,
0,
100,
TRUE,
TRUE
);


INSERT INTO pilot (flight_id, first_name, last_name)
VALUES (
'1471',
'John',
'Wang'
);


INSERT INTO flight
VALUES (
'1472',
'321',
'2020-12-19 11:30:00',
'ORD',
77,
'2020-12-19 12:00:00',
'SFO',
50,
'2020-12-19 15:00:00',
'Scheduled',
0,
50,
0,
50,
0,
50,
FALSE,
FALSE
);


INSERT INTO pilot (flight_id, first_name, last_name)
VALUES (
'1472',
'John',
'Davis'
);


INSERT INTO flight
VALUES (
'1473',
'321',
'2020-12-19 11:30:00',
'SEA',
20,
'2020-12-19 12:00:00',
'DEN',
61,
'2020-12-19 15:00:00',
'Scheduled',
0,
50,
0,
50,
0,
50,
FALSE,
FALSE
);


INSERT INTO pilot (flight_id, first_name, last_name)
VALUES (
'1473',
'Michael',
'Harris'
);


INSERT INTO flight
VALUES (
'1474',
'346',
'2020-12-19 08:30:00',
'LAX',
55,
'2020-12-19 09:00:00',
'JFK',
11,
'2020-12-19 12:00:00',
'Scheduled',
0,
100,
0,
100,
0,
100,
TRUE,
TRUE
);


INSERT INTO pilot (flight_id, first_name, last_name)
VALUES (
'1474',
'James',
'Miller'
);


INSERT INTO flight
VALUES (
'1475',
'340',
'2020-12-19 09:30:00',
'LAX',
8,
'2020-12-19 10:00:00',
'MCO',
3,
'2020-12-19 13:00:00',
'Scheduled',
0,
100,
0,
100,
0,
100,
TRUE,
TRUE
);


INSERT INTO pilot (flight_id, first_name, last_name)
VALUES (
'1475',
'Liam',
'Miller'
);


INSERT INTO flight
VALUES (
'1476',
'343',
'2020-12-19 05:30:00',
'DEN',
32,
'2020-12-19 06:00:00',
'SFO',
103,
'2020-12-19 08:00:00',
'Scheduled',
0,
100,
0,
100,
0,
100,
TRUE,
TRUE
);


INSERT INTO pilot (flight_id, first_name, last_name)
VALUES (
'1476',
'James',
'Miller'
);


INSERT INTO flight
VALUES (
'1477',
'342',
'2020-12-19 06:30:00',
'MCO',
71,
'2020-12-19 07:00:00',
'SEA',
31,
'2020-12-19 10:00:00',
'Scheduled',
0,
100,
0,
100,
0,
100,
TRUE,
TRUE
);


INSERT INTO pilot (flight_id, first_name, last_name)
VALUES (
'1477',
'John',
'Wang'
);


INSERT INTO flight
VALUES (
'1478',
'318',
'2020-12-19 04:30:00',
'JFK',
106,
'2020-12-19 05:00:00',
'LAX',
24,
'2020-12-19 07:00:00',
'Scheduled',
0,
50,
0,
50,
0,
50,
FALSE,
FALSE
);


INSERT INTO pilot (flight_id, first_name, last_name)
VALUES (
'1478',
'Alex',
'Wang'
);


INSERT INTO flight
VALUES (
'1479',
'330',
'2020-12-19 03:30:00',
'DFW',
111,
'2020-12-19 04:00:00',
'MCO',
25,
'2020-12-19 06:00:00',
'Scheduled',
0,
100,
0,
100,
0,
100,
TRUE,
TRUE
);


INSERT INTO pilot (flight_id, first_name, last_name)
VALUES (
'1479',
'Ethan',
'Miller'
);


INSERT INTO flight
VALUES (
'1480',
'318',
'2020-12-19 07:30:00',
'JFK',
43,
'2020-12-19 08:00:00',
'SEA',
22,
'2020-12-19 10:00:00',
'Scheduled',
0,
50,
0,
50,
0,
50,
FALSE,
FALSE
);


INSERT INTO pilot (flight_id, first_name, last_name)
VALUES (
'1480',
'Michael',
'Garcia'
);


INSERT INTO flight
VALUES (
'1481',
'310',
'2020-12-19 10:30:00',
'SEA',
80,
'2020-12-19 11:00:00',
'DFW',
83,
'2020-12-19 13:00:00',
'Scheduled',
0,
100,
0,
100,
0,
100,
TRUE,
TRUE
);


INSERT INTO pilot (flight_id, first_name, last_name)
VALUES (
'1481',
'William',
'Garcia'
);


INSERT INTO flight
VALUES (
'1482',
'340',
'2020-12-19 06:30:00',
'SFO',
93,
'2020-12-19 07:00:00',
'LAS',
52,
'2020-12-19 10:00:00',
'Scheduled',
0,
100,
0,
100,
0,
100,
TRUE,
TRUE
);


INSERT INTO pilot (flight_id, first_name, last_name)
VALUES (
'1482',
'Ethan',
'Anderson'
);


INSERT INTO flight
VALUES (
'1483',
'318',
'2020-12-19 05:30:00',
'LAS',
46,
'2020-12-19 06:00:00',
'JFK',
72,
'2020-12-19 08:00:00',
'Scheduled',
0,
50,
0,
50,
0,
50,
FALSE,
FALSE
);


INSERT INTO pilot (flight_id, first_name, last_name)
VALUES (
'1483',
'William',
'Harris'
);


INSERT INTO flight
VALUES (
'1484',
'321',
'2020-12-19 10:30:00',
'SFO',
33,
'2020-12-19 11:00:00',
'SEA',
34,
'2020-12-19 13:00:00',
'Scheduled',
0,
50,
0,
50,
0,
50,
FALSE,
FALSE
);


INSERT INTO pilot (flight_id, first_name, last_name)
VALUES (
'1484',
'William',
'Wang'
);


INSERT INTO flight
VALUES (
'1485',
'310',
'2020-12-19 10:30:00',
'ORD',
104,
'2020-12-19 11:00:00',
'LAX',
78,
'2020-12-19 13:00:00',
'Scheduled',
0,
100,
0,
100,
0,
100,
TRUE,
TRUE
);


INSERT INTO pilot (flight_id, first_name, last_name)
VALUES (
'1485',
'Ethan',
'Garcia'
);


INSERT INTO flight
VALUES (
'1486',
'340',
'2020-12-19 11:30:00',
'LAS',
39,
'2020-12-19 12:00:00',
'DEN',
37,
'2020-12-19 15:00:00',
'Scheduled',
0,
100,
0,
100,
0,
100,
TRUE,
TRUE
);


INSERT INTO pilot (flight_id, first_name, last_name)
VALUES (
'1486',
'William',
'Davis'
);


INSERT INTO flight
VALUES (
'1487',
'343',
'2020-12-19 11:30:00',
'LAS',
36,
'2020-12-19 12:00:00',
'SEA',
70,
'2020-12-19 15:00:00',
'Scheduled',
0,
100,
0,
100,
0,
100,
TRUE,
TRUE
);


INSERT INTO pilot (flight_id, first_name, last_name)
VALUES (
'1487',
'Liam',
'Anderson'
);


INSERT INTO flight
VALUES (
'1488',
'345',
'2020-12-19 08:30:00',
'DFW',
37,
'2020-12-19 09:00:00',
'MCO',
111,
'2020-12-19 12:00:00',
'Scheduled',
0,
100,
0,
100,
0,
100,
TRUE,
TRUE
);


INSERT INTO pilot (flight_id, first_name, last_name)
VALUES (
'1488',
'James',
'Wang'
);


INSERT INTO flight
VALUES (
'1489',
'345',
'2020-12-19 08:30:00',
'ATL',
3,
'2020-12-19 09:00:00',
'DFW',
22,
'2020-12-19 12:00:00',
'Scheduled',
0,
100,
0,
100,
0,
100,
TRUE,
TRUE
);


INSERT INTO pilot (flight_id, first_name, last_name)
VALUES (
'1489',
'William',
'Smith'
);


INSERT INTO flight
VALUES (
'1490',
'319',
'2020-12-19 08:30:00',
'LAX',
83,
'2020-12-19 09:00:00',
'SEA',
6,
'2020-12-19 12:00:00',
'Scheduled',
0,
50,
0,
50,
0,
50,
FALSE,
FALSE
);


INSERT INTO pilot (flight_id, first_name, last_name)
VALUES (
'1490',
'John',
'Anderson'
);


INSERT INTO flight
VALUES (
'1491',
'330',
'2020-12-19 07:30:00',
'DFW',
85,
'2020-12-19 08:00:00',
'DEN',
69,
'2020-12-19 10:00:00',
'Scheduled',
0,
100,
0,
100,
0,
100,
TRUE,
TRUE
);


INSERT INTO pilot (flight_id, first_name, last_name)
VALUES (
'1491',
'Noah',
'Harris'
);


INSERT INTO flight
VALUES (
'1492',
'330',
'2020-12-19 04:30:00',
'SEA',
2,
'2020-12-19 05:00:00',
'ATL',
40,
'2020-12-19 07:00:00',
'Scheduled',
0,
100,
0,
100,
0,
100,
TRUE,
TRUE
);


INSERT INTO pilot (flight_id, first_name, last_name)
VALUES (
'1492',
'Jacob',
'Garcia'
);


INSERT INTO flight
VALUES (
'1493',
'346',
'2020-12-19 06:30:00',
'SFO',
80,
'2020-12-19 07:00:00',
'LAS',
62,
'2020-12-19 10:00:00',
'Scheduled',
0,
100,
0,
100,
0,
100,
TRUE,
TRUE
);


INSERT INTO pilot (flight_id, first_name, last_name)
VALUES (
'1493',
'Michael',
'Miller'
);


INSERT INTO flight
VALUES (
'1494',
'342',
'2020-12-19 07:30:00',
'DFW',
28,
'2020-12-19 08:00:00',
'SFO',
96,
'2020-12-19 10:00:00',
'Scheduled',
0,
100,
0,
100,
0,
100,
TRUE,
TRUE
);


INSERT INTO pilot (flight_id, first_name, last_name)
VALUES (
'1494',
'Mason',
'Brown'
);


INSERT INTO flight
VALUES (
'1495',
'319',
'2020-12-19 08:30:00',
'ATL',
47,
'2020-12-19 09:00:00',
'ORD',
23,
'2020-12-19 12:00:00',
'Scheduled',
0,
50,
0,
50,
0,
50,
FALSE,
FALSE
);


INSERT INTO pilot (flight_id, first_name, last_name)
VALUES (
'1495',
'Noah',
'Miller'
);


INSERT INTO flight
VALUES (
'1496',
'345',
'2020-12-19 06:30:00',
'ATL',
72,
'2020-12-19 07:00:00',
'LAX',
86,
'2020-12-19 10:00:00',
'Scheduled',
0,
100,
0,
100,
0,
100,
TRUE,
TRUE
);


INSERT INTO pilot (flight_id, first_name, last_name)
VALUES (
'1496',
'James',
'Smith'
);


INSERT INTO flight
VALUES (
'1497',
'343',
'2020-12-19 03:30:00',
'DEN',
63,
'2020-12-19 04:00:00',
'LAX',
59,
'2020-12-19 06:00:00',
'Scheduled',
0,
100,
0,
100,
0,
100,
TRUE,
TRUE
);


INSERT INTO pilot (flight_id, first_name, last_name)
VALUES (
'1497',
'James',
'Brown'
);


INSERT INTO flight
VALUES (
'1498',
'321',
'2020-12-19 08:30:00',
'ATL',
53,
'2020-12-19 09:00:00',
'ORD',
64,
'2020-12-19 12:00:00',
'Scheduled',
0,
50,
0,
50,
0,
50,
FALSE,
FALSE
);


INSERT INTO pilot (flight_id, first_name, last_name)
VALUES (
'1498',
'Mason',
'Thomas'
);


INSERT INTO flight
VALUES (
'1499',
'310',
'2020-12-19 10:30:00',
'JFK',
73,
'2020-12-19 11:00:00',
'SEA',
26,
'2020-12-19 13:00:00',
'Scheduled',
0,
100,
0,
100,
0,
100,
TRUE,
TRUE
);


INSERT INTO pilot (flight_id, first_name, last_name)
VALUES (
'1499',
'Jacob',
'Harris'
);


