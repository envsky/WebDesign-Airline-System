

//STILL HAVE ACCESS TO VARIABLE flight FROM flightInfo.js ONCE IT IS DEFINED


var passengers = [];

function travelerInfo(flight) {
    for(i=1;i<=flight.travelers; i++)
    {
        const passengerNum = i;
        var block =document.createElement("DIV");
        block.className += "passenger-info block-section";
        block.id = "passenger" + i;
        document.getElementsByClassName("passenger-info block")[0].appendChild(block);
        $('#passenger'+i).load("../../Components/passengerForm.html", function() {
            this.getElementsByClassName("subtitle")[0].innerHTML += passengerNum;
            $(':required').one('blur keydown', function() {
                $(this).addClass('touched');
            });
        });
        passengers.push(block);
    }
}

function flightUnavailable() {
    document.getElementsByClassName("container")[0].style.display='none';
    var unavailable = document.createElement("DIV");
    unavailable.setAttribute("class", "container no-flights");
    unavailable.style.display = "block";
    var mainHead = document.createElement("p");
    mainHead.innerHTML = "We're sorry, it looks like this flight is not available anymore.";
    var extraText = document.createElement("p");
    extraText.innerHTML = "Keep searching, we may have other available flights between these cities at different times."
    unavailable.appendChild(mainHead);
    unavailable.appendChild(extraText);

    var nextPageHolder = document.createElement("DIV");
    nextPageHolder.setAttribute("id", "nextPageHolder");

    var homepageLink = document.createElement("a");
    homepageLink.setAttribute("id", "nextPage");
    homepageLink.setAttribute("href", "../airlineweb.html");
    homepageLink.style.width = "173px";
    homepageLink.innerHTML = "Back to Homepage";
    nextPageHolder.appendChild(homepageLink);
    unavailable.appendChild(nextPageHolder);
    document.getElementsByTagName("body")[0].appendChild(unavailable);

    localStorage.removeItem("date");
    localStorage.removeItem("flight");
}

async function purchase() {
    try
    {   //Get passenger info in 2D array
        var passengerInfo = [];
        passengers.forEach((pass)=>{
            var dobMonth = pass.getElementsByClassName("dobMonth")[0].value;
            var dobDay = pass.getElementsByClassName("dobDay")[0].value;
            var dobYear = pass.getElementsByClassName("dobYear")[0].value;
            var date_of_birth = new Date(dobYear, dobMonth-1, dobDay);
            passengerInfo.push(
                {first_name: pass.getElementsByClassName("firstName")[0].value,
                last_name: pass.getElementsByClassName("lastName")[0].value,
                date_of_birth: date_of_birth});
        });
        const contactInfo =
            {email: document.getElementsByClassName("email")[0].value,
            phone: document.getElementsByClassName("phoneNumber")[0].value};
        //VOUCHER CODE TO BE ADDED TODO

        const paymentInfo =
            {cardNum: document.getElementsByName("cardNum")[0].value,
            nameOnCard: document.getElementsByName("nameOnCard")[0].value,
            expMonth: document.getElementsByName("cardExpiryMonth")[0].value,
            expYear: document.getElementsByName("cardExpiryYear")[0].value};

        const info =
            {flight: JSON.parse(localStorage.getItem("flight")),
            passengerInfo: passengerInfo,
            contactInfo: contactInfo,
            paymentInfo: paymentInfo};

        const response = await fetch("http://localhost:5000/purchase",
        {method: "POST",
            headers: {"Content-Type": "application/json"},
            body: JSON.stringify(info)});
        if(response.status === 200)
        {
            var resp = await response.json();
            localStorage.setItem("response", JSON.stringify(resp));
            window.location.replace("./confirmation.html");
        }
        else if(response.status === 403) {
            flightUnavailable();
        }

    } catch(err) {
        console.log(err.message);
    }
}


