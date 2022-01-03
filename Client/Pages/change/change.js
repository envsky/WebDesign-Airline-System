
const changeInfo = JSON.parse(localStorage.getItem("changeInfo"));

async function getBooking(changeInfo, type) {
    try {
        const response = await fetch("http://localhost:5000/booking/?"+$.param({
            bookRef: changeInfo.bookRef,
            type: type
        }));

        if(response.status === 200) {
            let resp = await response.json();
            localStorage.setItem('flight', JSON.stringify(resp));
        }
        else if(response.status === 404) {
            bookingNotFound();
        }
        return response.status;

    }
    catch (err) {
        console.log(err.message);
    }
}

function startDatepicker() {
    var today = new Date();
    var max = new Date();
    max.setDate(max.getDate()+61);
    $('#date').datepicker({
        dateFormat: "mm/dd/yy",
        minDate: today,
        maxDate: max,
        altFormat: "yy-mm-dd",
        altField: "#alt-date"

    });
}
function bookingNotFound() {

    document.getElementsByClassName("container")[0].innerHTML =
        `<div class="container error-text" style="display: block;">
        <p>We're sorry, it looks like we can't find this booking.</p>
        <p>Please make sure you have entered the booking number correctly (CASE SENSITIVE).</p>
        </div>
        <div id="nextPageHolder">
            <a id="nextPage" onclick="clearLocalStorage()" href="../airlineweb.html" style="width: 173px;">Back to Homepage</a>
        </div>`;
}

function displayPassengers() {
    window.passengers = JSON.parse(localStorage.getItem("flight")).travelers;
    var passBlockContent = document.getElementsByClassName("block-content")[0];
    var passengerBlock;
    passengers.forEach(function(pass) {
       passengerBlock =
        `<div class="input-field">
            <label class="encompassing-label">
                <input type="checkbox" class="passenger">
                    ${pass.first_name} ${pass.last_name}
            </label>
        </div>`;
        passBlockContent.innerHTML += passengerBlock;

    });
}
function getPassengersCancel() {
    var checkboxes = Array.from(document.getElementsByTagName("input"));
    var checkboxCheck = checkboxes.map(input => {return input.checked});
    var passengersChecked = window.passengers.filter((pass, index) => {return checkboxCheck[index]});
    passengersChecked = passengersChecked.map(pass => {return pass.id});

    if(passengersChecked.length === 0)
    {
        alert("Please select at least one passenger.");
        return false;
    }
    var changeInfo = JSON.parse(localStorage.getItem("changeInfo"));
    changeInfo.travelersCancel = passengersChecked;
    localStorage.setItem("changeInfo", JSON.stringify(changeInfo));

}

