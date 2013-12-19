var empty_object;
var stooge;
var flight;
var middle;
var status;
var x;
var nick;
var a;
var b;
var c;
var d;
var e;
var f;

empty_object = {};

stooge = {
    "first-name": "Jerome",
    "last-name": "Howard"
};

flight = {
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

middle = stooge["middle-name"];
status = flight.status;

x = stooge;
x.nickname = "Curl";
nick = stooge.nickname;

a = {}; b = {}; c = {};
d = e = f = {};
