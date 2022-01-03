

function changeText() {
    var value = document.getElementById('travelers').value;
    if(value > 1)
        document.getElementById('travelText').innerHTML = "travelers";
    else
        document.getElementById('travelText').innerHTML = "traveler";
}

function autocomplete(inp, arr) {
    /*the autocomplete function takes two arguments,
    the text field element and an array of possible autocompleted values:*/
    var currentFocus;
    /*execute a function when someone writes in the text field:*/
    inp.addEventListener("input", function(e) {
        var a, b, i, val = this.value;
        /*close any already open lists of autocompleted values*/
        closeAllLists();
        if (!val) { return false;}
        currentFocus = -1;
        /*create a DIV element that will contain the items (values):*/
        a = document.createElement("DIV");
        a.setAttribute("id", this.id + "autocomplete-list");
        a.setAttribute("class", "autocomplete-items");
        /*append the DIV element as a child of the autocomplete container:*/
        this.parentNode.appendChild(a);
        /*for each item in the array...*/
        for (i = 0; i < arr.length; i++) {
            /*check if the item starts with the same letters as the text field value:*/
            if (arr[i].toUpperCase().search(val.toUpperCase()) > -1) {
                /*create a DIV element for each matching element:*/
                b = document.createElement("DIV");
                /*make the matching letters bold:*/
                b.innerHTML = "<strong>" + arr[i].substr(0, val.length) + "</strong>";
                b.innerHTML += arr[i].substr(val.length);
                /*insert a input field that will hold the current array item's value:*/
                b.innerHTML += "<input type='hidden' value='" + arr[i] + "'>";
                /*execute a function when someone clicks on the item value (DIV element):*/
                b.addEventListener("click", function(e) {
                    /*insert the value for the autocomplete text field:*/
                    inp.value = this.getElementsByTagName("input")[0].value;
                    inp.nextElementSibling.value = inp.value.substr(inp.value.search("-")+2);
                    /*close the list of autocompleted values,
                    (or any other open lists of autocompleted values:*/
                    closeAllLists();
                });
                a.appendChild(b);
            }
        }

    });
    /*execute a function presses a key on the keyboard:*/
    inp.addEventListener("keydown", function(e) {
        var x = document.getElementById(this.id + "autocomplete-list");
        if (x) x = x.getElementsByTagName("div");
        if (e.keyCode == 40) {
            /*If the arrow DOWN key is pressed,
            increase the currentFocus variable:*/
            currentFocus++;
            /*and and make the current item more visible:*/
            addActive(x);
        } else if (e.keyCode == 38) { //up
            /*If the arrow UP key is pressed,
            decrease the currentFocus variable:*/
            currentFocus--;
            /*and and make the current item more visible:*/
            addActive(x);
        } else if (e.keyCode == 9) {
            /*If the TAB key is pressed,  pick the top selection.*/
            selectTopOption();
            closeAllLists();
        } else if (e.keyCode == 13) {
            /*If the ENTER key is pressed, prevent the form from being submitted,*/
            e.preventDefault();
            if (currentFocus > -1) {
                /*and simulate a click on the "active" item:*/
                if (x) x[currentFocus].click();
            }
        }
    });
    function addActive(x) {
        /*a function to classify an item as "active":*/
        if (!x) return false;
        /*start by removing the "active" class on all items:*/
        removeActive(x);
        if (currentFocus >= x.length) currentFocus = 0;
        if (currentFocus < 0) currentFocus = (x.length - 1);
        /*add class "autocomplete-active":*/
        x[currentFocus].classList.add("autocomplete-active");
    }
    function removeActive(x) {
        /*a function to remove the "active" class from all autocomplete items:*/
        for (var i = 0; i < x.length; i++) {
            x[i].classList.remove("autocomplete-active");
        }
    }
    function closeAllLists(elmnt) {
        /*close all autocomplete lists in the document,
        except the one passed as an argument:*/
        var x = document.getElementsByClassName("autocomplete-items");
        for (var i = 0; i < x.length; i++) {
            if (elmnt != x[i] && elmnt != inp) {
                x[i].parentNode.removeChild(x[i]);
            }
        }
    }
    function selectTopOption() {
        if(document.getElementById(inp.id+"autocomplete-list") !== null)
        {
            inp.value = document.getElementById(inp.id+"autocomplete-list").firstChild.lastChild.value;
            inp.nextElementSibling.value = inp.value.substr(inp.value.search("-")+2);
        }
    }
    /*execute a function when someone clicks in the document:*/
    document.addEventListener("click", function (e) {
        selectTopOption();
        closeAllLists(e.target);
    });
}

function insertDate() {
    localStorage.setItem("date", document.getElementById("alt-date").value);
}
function insertDateStatus() {
    localStorage.setItem("date", document.getElementById("alt-date-status").value);
}
function insertChangeInfo() {
    var radio = document.querySelector('input[name=change_cancel]:checked').value;
    const items = {"bookRef": document.getElementById("bookRef").value};
    localStorage.setItem("changeInfo", JSON.stringify(items));
    if (radio === 'change')
        window.location.href = "change/change.html";
    else
        window.location.href="change/cancel.html";
    return false;
}

async function getCities() {
    try {
        const response = await fetch('http://localhost:5000/cities');
        const jsonData = await response.json();
        for(i=0; i < jsonData.length; i++)
        {
            cities[i] = jsonData[i].city.trim() + " - " + jsonData[i].airport_code;
        }
    }
    catch(err) {
        console.log(err.message);
    }
}

function checkIn() {
    try {
        const info =
            {bookRef: document.getElementById("checkInBookRef").value,
            numBag: document.getElementById("checkInBag").value};

        checkInOnDB(info).then(status=> {
            if(status === 200)
            {
                window.location.href="checkIn/success.html";
            }
            else if(status === 403) {
                window.location.href="checkIn/failed.html";
            }
        });
        return false;
    }
    catch(err) {
        console.log(err.message);
    }
}

async function checkInOnDB(info) {
    const response = await fetch('http://localhost:5000/checkIn',
        {method: "PUT",
            headers: {"Content-Type": "application/json"},
            body: JSON.stringify(info)});
    return response.status;
}

let cities = [];

function homepageStart() {
    setInterval(function() {
        $('#slideshow > img:first')
            .fadeOut(2500)
            .next()
            .show()
            .end()
            .appendTo('#slideshow');
    }, 25000);

    $("#slideshow > img:gt(0)").hide();
    $('#book').show();
    $('#status').hide();
    $('#change').hide();
    $('#checkIn').hide();

    var today = new Date();
    var max = new Date();
    var min = new Date();
    min.setMonth(today.getMonth()-2);
    max.setDate(max.getDate()+61);
    $('#date').datepicker({
        dateFormat: "mm/dd/yy",
        minDate: today,
        maxDate: max,
        altFormat: "yy-mm-dd",
        altField: "#alt-date"

    });
    $('#dateStatus').datepicker({
        dateFormat: "mm/dd/yy",
        minDate: min,
        maxDate: max,
        altFormat: "yy-mm-dd",
        altField: "#alt-date-status"

    });

    $('#bookShow').click(function() {
        $('#status').hide();
        $('#change').hide();
        $('#book').show();
        $('#checkIn').hide();
        $('#idCaret').css('left','13.5%');

    });
    $('#statusShow').click(function() {
        $('#book').hide();
        $('#change').hide();
        $('#checkIn').hide();
        $('#status').show();
        $('#idCaret').css('left','37.8%');
    });
    $('#changeShow').click(function() {
        $('#book').hide();
        $('#status').hide();
        $('#checkIn').hide();
        $('#change').show();
        $('#idCaret').css('left','64.8%');
    });
    $('#checkInShow').click(function() {
        $('#book').hide();
        $('#change').hide();
        $('#status').hide();
        $('#checkIn').show();
        $('#idCaret').css('left','86.9%');
    });

    getCities();

}


