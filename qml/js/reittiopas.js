/**********************************************************************
*
* This file is part of the JollaOpas, forked from Jopas originally
* forked from Meegopas.
* More information:
*
*   https://github.com/hsarkanen/JollaOpas
*   https://github.com/rasjani/Jopas
*   https://github.com/junousia/Meegopas
*
* Author: Heikki Sarkanen <heikki.sarkanen@gmail.com>
* Original author: Jukka Nousiainen <nousiaisenjukka@gmail.com>
* Other contributors:
*   Jani Mikkonen <jani.mikkonen@gmail.com>
*   Jonni Rainisto <jonni.rainisto@gmail.com>
*   Mohammed Sameer <msameer@foolab.org>
*   Clovis Scotti <scotti@ieee.org>
*   Benoit HERVIER <khertan@khertan.net>
*
* All assets contained within this project are copyrighted by their
* respectful authors.
*
* This program is free software: you can redistribute it and/or modify
* it under the terms of the GNU General Public License as published by
* the Free Software Foundation, either version 3 of the License, or
* (at your option) any later version.
*
* See full license at http://www.gnu.org/licenses/gpl-3.0.html
*
**********************************************************************/

.pragma library

var API = {}
API['digitransitgeocoding'] = {}
API['digitransitgeocoding'].URL = 'https://api.digitransit.fi/'

/****************************************************************************************************/
/*                     address to location                                                          */
/****************************************************************************************************/
function get_geocode(term, model, region) {
    model.done = false;
    var size = 10;
    var queryType = 'geocoding/v1/search';
    var query = "size=" + size + "&text=" + term;
    if (region.boundarycirclelat && region.boundarycirclelon) {
        query = query + "&boundary.circle.lat=" + region.boundarycirclelat + "&boundary.circle.lon=" + region.boundarycirclelon
                    + "&boundary.circle.radius=" + 40;
    }

    var http_request = new XMLHttpRequest();
    var url = API['digitransitgeocoding'].URL + queryType + '?' + query;
//    console.debug(url);
    http_request.open("GET", url);
    http_request.onreadystatechange = function() {
        if (http_request.readyState === XMLHttpRequest.DONE) {
            try {
                var a = JSON.parse(http_request.responseText);
                for (var index in a.features) {
                    a.features[index].properties.coord = a.features[index].geometry.coordinates[0] + "," +
                        a.features[index].geometry.coordinates[1];
                    model.append(a.features[index].properties);
                }
            } catch (error) {
                console.log(error)
            }
            model.done = true;
        }
    }
    http_request.ontimeout = function () {
        model.timeout = true;
        model.done = true;
    }
    http_request.send();
}

/****************************************************************************************************/
/*                     location to address                                                          */
/****************************************************************************************************/
function get_reverse_geocode(latitude, longitude, model, api_type) {
    model.done = false;
    api_type = api_type || 'helsinki';
    var size = 1;
    var queryType = 'geocoding/v1/reverse';
    var query = "point.lat=" + latitude + "&point.lon=" + longitude + "&size=" + size;

//    console.debug(API['digitransitgeocoding'].URL + queryType + '?' + query);
    var http_request = new XMLHttpRequest();
    http_request.open("GET", API['digitransitgeocoding'].URL + queryType + '?' + query);
    // console.log(query)
    http_request.onreadystatechange = function() {
        if (http_request.readyState === XMLHttpRequest.DONE) {
            try {
                var a = JSON.parse(http_request.responseText);
                for (var index in a.features) {
                    a.features[index].properties.coord = a.features[index].geometry.coordinates[0] + "," +
                        a.features[index].geometry.coordinates[1];
                    model.append(a.features[index].properties);
                }
            } catch (error) {
                console.log(error)
            }
            model.done = true;
        }
    }
    http_request.ontimeout = function () {
        model.timeout = true;
        model.done = true;
    }
    http_request.send();
}

/****************************************************************************************************/
/*                     Reittiopas query class                                                       */
/****************************************************************************************************/
function get_route(parameters, itineraries_model, itineraries_json, region) {
    itineraries_model.done = false;
    var size = 5;
    var queryType = 'routing/v1/routers/' + region.apiName + '/index/graphql';

//    console.debug(JSON.stringify(parameters));
    var graphqlFromLon = parameters.from.split(',', 2)[0]
    var graphqlFromLat = parameters.from.split(',', 2)[1]
    var graphqlToLon = parameters.to.split(',', 2)[0]
    var graphqlToLat = parameters.to.split(',', 2)[1]
    var graphqlDate = Qt.formatDate(parameters.jstime, "yyyy-MM-dd");
    var graphqlTime = Qt.formatTime(parameters.jstime, "hh:mm:ss");
    var graphqlTransferTime = parameters.change_margin * 60;
    var graphqlWalkBoardCost = parameters.change_reluctance * 60;
    var graphqlWalkReluctance = parameters.walk_reluctance;
    var graphqlNumberOfItinaries = 5;
    var graphqlWalkSpeed = parameters.walk_speed / 60;
    var graphqlArriveBy = ""
    if (parameters.arriveBy) {
        graphqlArriveBy = " arriveBy: true "
    }
    var query = '{plan(from:{lat:' + graphqlFromLat + ',lon:' + graphqlFromLon + '},to:{lat:'
            + graphqlToLat + ',lon:' + graphqlToLon + '},date:"' + graphqlDate + '",time:"'
            + graphqlTime + '",numItineraries:' + graphqlNumberOfItinaries
            + ',minTransferTime:' + graphqlTransferTime + ',walkBoardCost:'
            + graphqlWalkBoardCost + ',walkReluctance:' + graphqlWalkReluctance
            + ',walkSpeed:' + graphqlWalkSpeed;
    // Show all results for the Finland region.
    if (region.identifier !== "finland") {
        query = query + ',modes:"' + parameters.modes + '"';
    }

    // Get Arrival and Departure times for stops
    query = query + graphqlArriveBy + '){itineraries{walkDistance,duration,startTime,endTime,legs{mode,route{shortName,gtfsId},trip{gtfsId},duration,startTime,endTime,from{lat,lon,name,stop{code,name,stoptimesForPatterns(numberOfDepartures:10,startTime:';
    query = query + Math.floor(parameters.jstime.getTime()/1000) + '){pattern{route{gtfsId}},stoptimes{scheduledArrival,scheduledDeparture,trip{gtfsId}}}}},to{lat,lon,name,stop{code,name,stoptimesForPatterns(numberOfDepartures:10,startTime:';
    query = query + Math.floor(parameters.jstime.getTime()/1000) + '){pattern{route{gtfsId}},stoptimes{scheduledArrival,scheduledDeparture,trip{gtfsId}}}}},distance,legGeometry{points},intermediateStops{lat,lon,code,name,stoptimesForPatterns(numberOfDepartures:10,startTime:';
    query = query + Math.floor(parameters.jstime.getTime()/1000) + '){pattern{route{gtfsId}},stoptimes{scheduledArrival,scheduledDeparture,trip{gtfsId}}}}}}}}';

    console.debug(query);
    var http_request = new XMLHttpRequest();
    http_request.open("POST", API['digitransitgeocoding'].URL + queryType);
    http_request.setRequestHeader("Content-Type", "application/graphql");
    http_request.setRequestHeader("Accept", "*/*")
    http_request.onreadystatechange = function() {
        if (http_request.readyState === XMLHttpRequest.DONE) {
            itineraries_json = JSON.parse(http_request.responseText);
            // console.debug("Query json result: " + JSON.stringify(itineraries_json));
            for (var index in itineraries_json.data.plan.itineraries) {
                var output = {}
                var route = itineraries_json.data.plan.itineraries[index]
                output.length = 0
                output.duration = Math.round(route.duration/60)
                output.start = new Date(route.startTime)
                output.finish = new Date(route.endTime)
                output.first_transport = null
                output.last_transport = null
                output.walk = route.walkDistance
                output.legs = []
                for (var leg in route.legs) {
                    var legdata = route.legs[leg]
                    output.legs[leg] = {
                        "type": legdata.mode.toLowerCase(),
                        "code": legdata.route ? legdata.route.shortName : "",
                        "gtfsId": legdata.route ? legdata.route.gtfsId.split(':', 2)[1] : "",
                        "shortCode": legdata.from.stop ? legdata.from.stop.name : "",
                        "length": legdata.distance,
                        "polyline": legdata.legGeometry.points,
                        "duration": Math.round(legdata.duration/60),
                        "from": {},
                        "to": {},
                        "locs": [],
                        "leg_number": leg
                    }
                    output.legs[leg].from.name = (leg == 0) ? parameters.from_name : (legdata.from.name ? legdata.from.name : "")
                    output.legs[leg].from.time = new Date(legdata.startTime)
                    output.legs[leg].from.shortCode = legdata.from.stop ? legdata.from.stop.code : ""
                    output.legs[leg].from.latitude = legdata.from.lat
                    output.legs[leg].from.longitude = legdata.from.lon
                    if (legdata.from.stop
                            && legdata.from.stop.stoptimesForPatterns
                            && legdata.trip
                            && legdata.route
                            && legdata.trip.gtfsId
                            && legdata.route.gtfsId) {
                        var fromTime = processStoptimes(legdata.from.stop.stoptimesForPatterns, legdata.trip.gtfsId, legdata.route.gtfsId)
                        output.legs[leg].from.arrTime = fromTime && fromTime.scheduledArrival ? fromTime.scheduledArrival : 0
                        output.legs[leg].from.depTime = fromTime && fromTime.scheduledDeparture ? fromTime.scheduledDeparture : 0
                    }
                    output.legs[leg].to.name = (leg == route.legs.length-1) ? parameters.to_name : (legdata.to.name ? legdata.to.name : "")
                    output.legs[leg].to.time = new Date(legdata.endTime)
                    output.legs[leg].to.shortCode = legdata.to.stop ? legdata.to.stop.code : ""
                    output.legs[leg].to.latitude = legdata.to.lat
                    output.legs[leg].to.longitude = legdata.to.lon
                    if (legdata.to.stop
                            && legdata.to.stop.stoptimesForPatterns
                            && legdata.trip
                            && legdata.route
                            && legdata.trip.gtfsId
                            && legdata.route.gtfsId) {
                        var toTime = processStoptimes(legdata.to.stop.stoptimesForPatterns, legdata.trip.gtfsId, legdata.route.gtfsId)
                        output.legs[leg].to.arrTime = toTime && toTime.scheduledArrival ? toTime.scheduledArrival : 0
                        output.legs[leg].to.depTime = toTime && toTime.scheduledDeparture ? toTime.scheduledDeparture : 0
                    }
                    for (var stopindex in legdata.intermediateStops) {
                        var locdata = legdata.intermediateStops[stopindex]
                        var stoptime
                        var timediff
                        if (locdata.stoptimesForPatterns && legdata.trip.gtfsId && legdata.route.gtfsId) {
                            stoptime = processStoptimes(locdata.stoptimesForPatterns, legdata.trip.gtfsId, legdata.route.gtfsId)
                            if (stoptime && stopindex - 1 >= 0) {
                                timediff = stoptime.scheduledArrival - output.legs[leg].locs[stopindex-1].depTime
                            } else if(stoptime) {
                                timediff = stoptime.scheduledArrival - output.legs[leg].from.depTime
                            }
                        }
                        output.legs[leg].locs[stopindex] = {
                            "name" : locdata.name,
                            "shortCode" : locdata.code,
                            "latitude" : locdata.lat,
                            "longitude" : locdata.lon,
                            "arrTime" : stoptime && stoptime.scheduledArrival ? stoptime.scheduledArrival : 0,
                            "depTime" : stoptime && stoptime.scheduledDeparture ? stoptime.scheduledDeparture : 0,
                            "time_diff": timediff || 0
                        }
                    }
                    /* update the first and last time using any other transportation than walking */
                    if(!output.first_transport && legdata.mode !== "WALK") {
                        output.first_transport = new Date(legdata.startTime)
                    }
                    if(legdata.mode !== "WALK") {
                        output.last_transport = output.legs[leg].to.time
                    }
                }
                itineraries_model.append(output);
            }
            itineraries_model.done = true;
        }
    }
    http_request.send(query);
}
function processStoptimes(stoptimesPatterns, tripGtfsId, routeGtdsId) {
    for (var idx in stoptimesPatterns) {
        var stoptimePattern = stoptimesPatterns[idx]
        if (stoptimePattern.pattern && stoptimePattern.pattern.route && stoptimePattern.pattern.route.gtfsId === routeGtdsId) {
            for (var stIdx in stoptimePattern.stoptimes) {
                var stopTime = stoptimePattern.stoptimes[stIdx]
                if (stopTime.trip && stopTime.trip.gtfsId === tripGtfsId) {
                    return stopTime
                }
            }
        }
    }
}
