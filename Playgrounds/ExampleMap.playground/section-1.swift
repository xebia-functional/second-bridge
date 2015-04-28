

import UIKit
import Swift47Deg

var str = "Playground Example Map"

//Maps can be created easily:

let myMap1 : Map<String> = ["MI" : "Michigan", "OH" : "Ohio", "WI" : "Wisconsin", "IA" : "Iowa"]
myMap1.size

//Maps contain distinct pairings:

let myMap2 : Map<String> = ["MI" : "Michigan", "OH" : "Ohio", "WI" : "Wisconsin", "WI" : "Wisconsin"]
myMap2.size

//:Maps can be added to easily:

let myMap3 : Map<String> = ["MI" : "Michigan", "OH" : "Ohio", "WI" : "Wisconsin", "WI" : "Wisconsin"]
let aNewMap = myMap3 + ["IL":"Illinois"]
aNewMap.contains("IL")

//Map values can be iterated:

let myMap4 :  Map<String> = ["MI" : "Michigan", "OH" : "Ohio", "WI" : "Wisconsin", "MI" : "Michigan"]
let map4Values = myMap4.values()
map4Values.count == 3
map4Values.first
let lastElement = map4Values.last

//Maps insertion with duplicate key updates previous entry with subsequent value:

let myMap5 : Map<String> = ["MI" : "Michigan", "OH" : "Ohio", "WI" : "Wisconsin", "MI" : "Meechigan"]
let map5Values = myMap5.values()
map5Values.count == 3
myMap5["MI"] == "Meechigan"

//Map keys may be of mixed type:

let myMap6 : Map = ["Ann Arbor" : "MI", 49931 : "MI"]
myMap6["Ann Arbor"] == "MI"
myMap6[49931] == "MI"

//Mixed type values can be added to a map:

var myMap7 : Map = ["Ann Arbor" : [48103, 48104, 48108], 49931 : "MI"]
myMap7[12345] = "Michigan"
myMap7.size == 3





