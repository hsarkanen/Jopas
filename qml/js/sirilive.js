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
API['helsinki'] = {}
API['helsinki'].URL = 'http://dev.hsl.fi/siriaccess/vm/json'

API['tampere'] = {}
API['tampere'].URL = 'http://data.itsfactory.fi/siriaccess/vm/rest'

//sirilive instance
var _instance = null
var _http_request = null
var _request_parent = null

function SiriLive() {
    this.model = null
}

SiriLive.prototype.api_request = function() {
    _http_request = new XMLHttpRequest()
    this.model.done = false

    _request_parent = this
    _http_request.onreadystatechange = _request_parent.result_handler

    _http_request.open("GET", API[this.api_type].URL)
    _http_request.send()
}

function new_live_instance(vehicle_model, api_type) {
    if(_instance)
        delete _instance

    _instance = new LiveResult(vehicle_model, api_type)
    return _instance
}

function get_live_instance() {
    return _instance
}

LiveResult.prototype = new SiriLive()
LiveResult.prototype.constructor = LiveResult
function LiveResult(vehicle_model, api_type) {
    this.api_type = api_type
    this.model = vehicle_model
    this.api_request()
}

LiveResult.prototype.result_handler = function() {
    if (_http_request.readyState == XMLHttpRequest.DONE) {
        if (_http_request.status != 200 && _http_request.status != 304) {
            //console.debug('HTTP error ' + _http_request.status)
            this.model.done = true
            return
        }
    } else {
        return
    }

    var parent = _request_parent
    var vehicles = JSON.parse(_http_request.responseText)

    _request_parent.parse_json(vehicles, parent)
    _request_parent.model.done = true
}

LiveResult.prototype.parse_json = function(vehicles, parent) {
    if (typeof parent.model.clear === "function") {
        parent.model.clear()
    }
    for (var monitoredVehicle in vehicles.Siri.ServiceDelivery.VehicleMonitoringDelivery[0].VehicleActivity) {
        var vehicleData = vehicles.Siri.ServiceDelivery.VehicleMonitoringDelivery[0].VehicleActivity[monitoredVehicle]
        parent.model.append({"modelLongitude" : vehicleData.MonitoredVehicleJourney.VehicleLocation.Longitude, "modelLatitude" : vehicleData.MonitoredVehicleJourney.VehicleLocation.Latitude, "modelCode" : vehicleData.MonitoredVehicleJourney.LineRef.value})
    }
}
