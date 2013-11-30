var empty_object = {};

var stooge = {
    "first-name": "Jerome",
    "last-name": "Howard"
};

var flight = {
    airline: "Oceanic",
    number: 815,
    departure: {
        IATA: "SYD",
        time: "2004-09-22 14:55",
        city: "Sydney"
    },
    arrival: {
        IATA: "LAX",
        time: "2004-09-23 10:42",
        city: "Los Angeles"
    }
};

print(stooge["first-name"]);     // "Jerome"
print(flight.departure.IATA);    // "SYD"
print(stooge["middle-name"]);    // undefined
print(flight.status);            // undefined
print(stooge["FIRST-NAME"]);     // undefined

stooge["first-name"] = "Jerom";
stooge["middle-name"] = "Lester";
stooge.nickname = "Curly";
flight.equipment = {
    model: "Boeing 777"
};
flight.status = "overdue";

var middle = stooge["middle-name"];
var status = flight.status;

var x = stooge;
x.nickname = "Curl";
var nick = stooge.nickname;

var a = {}, b = {}, c = {};
var d,e,f;
d = e = f = {};
