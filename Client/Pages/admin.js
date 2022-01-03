
let flight;
function insertFakeStuff(numOfBookings) {
    fakeBookings(numOfBookings).then(status => {
        if(status===200)
        {
            document.getElementsByClassName("status")[1].innerHTML =
                `<span style="color: green; font-size: 10pt">ADDITIONS SUCCESSFUL</span>`;

            document.getElementsByClassName("status")[1].style.opacity = "1";
            setTimeout(function() {
                document.getElementsByClassName("status")[1].style.opacity="0";
            }, 2000);


        }
    });
}

async function fakeBookings(numOfBookings) {

    return (await fetch('http://localhost:5000/fakeBookings',
        {method: "POST",
            headers: {"Content-Type": "application/json"},
            body: JSON.stringify({numOfBookings: numOfBookings})})).status;
}

function viewFlightInfo(flightID) {
    try {
        flightInfo(flightID).then((value)=> {
            var standbyTable = document.createElement("DIV");
            standbyTable.setAttribute("class", "admin-flight-info block-section");
            standbyTable.innerHTML =
                `<div class="standby">
                    <div class="subtitle">
                        <span>Standby</span>
                        <button id="viewStandby" class="button-small" onclick="viewStandby()">View</button>
                    </div>
    
                    <div class="block-content">
                        <table class="standby-table" style="display: none">
                            <thead>
                            <tr>
                                <th>Standby Position</th>
                                <th>Booking Reference Number</th>
                            </tr>
                            </thead>
                            <tbody>
                            <tr class="spacer"></tr>
                            </tbody>
                        </table>
                    </div>
                </div>`;

            if(value==='404')
            {
                document.getElementsByClassName("status")[0].innerHTML =
                    `<span style="color: red; font-size: 10pt">FLIGHT NOT FOUND</span>`;

                document.getElementsByClassName("status")[0].style.opacity = "1";
                setTimeout(function() {
                    document.getElementsByClassName("status")[0].style.opacity="0";
                }, 2000);
            }
            else
            {
                let block = document.querySelector(".view-flight-info.block-section");

                flight = value;
                let viewButton = document.querySelector("#viewFlightInfo");

                if(viewButton.innerHTML==='View')
                {
                    viewButton.innerHTML = "Hide";
                    block.appendChild(standbyTable);
                }
                else
                {
                    standbyTable = block.lastElementChild;
                    viewButton.innerHTML = "View";
                    block.removeChild(standbyTable);
                }
                const table = document.querySelector(".standby-table").getElementsByTagName('tbody')[0];
                flight.forEach(val => {
                    var row = table.insertRow();
                    insertStandby(row, val);
                })
            }

        });
    } catch(err) {
        console.log(err.message);
    }

}

function insertStandby(row, data) {
    var position = row.insertCell();
    position.innerHTML = data.position;

    var bookRef = row.insertCell();
    bookRef.innerHTML = data.book_ref;
}

async function flightInfo(flightID) {
    try {
        let response = await fetch(`http://localhost:5000/admin/flightInfo?flightID=${flightID}`);
        if(response.ok) {
            return response.json();
        } else if(response.status === 404) {
            return '404';
        }
    } catch(err) {
        return err;
    }

}

function viewStandby() {
    const table = document.querySelector(".standby-table");
    const showButton = document.querySelector("#viewStandby");

    if(showButton.innerHTML==='View')
    {
        table.style.display = "table";
        showButton.innerHTML = "Hide";
    }
    else
    {
        table.style.display = "none";
        showButton.innerHTML = "View";
    }
}