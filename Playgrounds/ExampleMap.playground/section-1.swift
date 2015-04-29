
import UIKit
import Swift47Deg

let str = "Playground Example Map"

//Maps can be created easily:
let myMap1 : Map<String> = ["MI" : "Michigan", "OH" : "Ohio", "WI" : "Wisconsin", "IA" : "Iowa"]
myMap1.size == 4

//Maps contain distinct pairings:
let myMap2 : Map<String> = ["MI" : "Michigan", "OH" : "Ohio", "WI" : "Wisconsin", "WI" : "Wisconsin"]
myMap2.size == 3

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

//Maps may be accessed:
let myMap8 : Map = ["MI" : "Michigan", "OH" : "Ohio", "WI" : "Wisconsin", "IA" : "Iowa"]
myMap8["MI"] == "Michigan"
myMap8["IA"] == "Iowa"

//Map elements can be removed easily:
let myMap9 : Map = ["MI" : "Michigan", "OH" : "Ohio", "WI" : "Wisconsin", "IA" : "Iowa"]
let anewMap9 = myMap9 - "MI"
anewMap9.contains("MI")
myMap9.contains("MI")


//Map elements can be removed in multiple:

let myMap10 : Map = ["MI" : "Michigan", "OH" : "Ohio", "WI" : "Wisconsin", "IA" : "Iowa"]
let aNewMap10 = myMap10 -- ["MI", "OH"]
aNewMap10.contains("MI")
myMap10.contains("MI")
aNewMap10.contains("WI")
aNewMap10.size == 2
myMap10.size == 4

//Map elements can be removed with a tuple:
let myMap11 : Map  = ["MI" : "Michigan", "OH" : "Ohio", "WI" : "Wisconsin", "IA" : "Iowa"]
let aNewMap11 = myMap11 -- ["MI", "WI"]

aNewMap11.contains("MI")
myMap11.contains("MI")

aNewMap11.contains("OH")
aNewMap11.size == 2
myMap11.size == 4

//Attempted removal of nonexistent elements from a map is handled gracefully:
let  myMap12 : Map  = ["MI" : "Michigan", "OH" : "Ohio", "WI" : "Wisconsin", "IA" : "Iowa"]
let aNewMap12 = myMap12 - "MN"
aNewMap12 == myMap12

//Map equivalency is independent of order:
let myMap13 : Map = ["MI" : "Michigan", "OH" : "Ohio", "WI" : "Wisconsin", "IA" : "Iowa"]
let myMap14 : Map = ["WI" : "Wisconsin", "MI" : "Michigan", "IA" : "Iowa", "OH" : "Ohio"]
myMap13 == (myMap14)


myMap12.map(2)



