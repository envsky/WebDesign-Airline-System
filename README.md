# COSC3380 HW4
Database ER Design, Normalization, and Web App for An Airline Database System  

Preferred system: Windows

## Getting Started

### Prerequisites
- node.js installed on local machine (nodejs.org)
- Access to a web browser (Firefox recommended)
- Local database server

### Installation

- Create the file Server/password.txt and insert your local database username and password as follows:
```text
 username
 password
```

  Start up the server
  + Open a new Terminal window
  + Navigate to /Server with cd command
  + Type:
```text
npm install
```
+ Start both the web and database servers by typing:
```text
./runserver.sh
```
  Open up web interface
  + Open a new window in your web browser
  + Type into the URL:
```text
localhost:8000/Pages/airlineweb.html
```
  
This is the main homepage for booking flights. Start by selecting the starting city/airport and destination.
Flights are available from 12/10/2020 to 12/19/2020 (date can be changed in createdb.sql), and up to 5 ticket can be purchased at once.
If there is any confusion, please watch our short video explaining setup and usage.

##Outline
### The Client

- Components
    + bookStepProgressbar.html
    + changeStepProgressbar.html
    + flightInfo.html
    + flightInfo.js
    + header.html
    + passengerForm.html
    + styling.css

- Pages
    + booking
    + change
    + checkIn
    + status
    + admin.html
    + admin.js
    + airlineweb.html : main web page
    + airlineweb.js

### The Server

- createdb.sql : setting up the database
- db.js : connect the webserver to the database
- index.js : communicate with the client
- password.txt : store user access information
- processing.js : generate information about the flight
- queryBank.js : communicate with the database
- performBookings.js : create random bookings


