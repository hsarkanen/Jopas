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

import QtQuick 2.1
import QtLocation 5.0
import QtPositioning 5.0
import "../js/reittiopas.js" as Reittiopas
import "../js/UIConstants.js" as UIConstants
import "../js/helper.js" as Helper
import "../js/theme.js" as Theme

Item {
    id: map_element
    property bool positioningActive : true
    property alias flickable_map : flickable_map

    function next_station() {
        flickable_map.panToCoordinate(Helper.next_station())
    }

    function previous_station() {
        flickable_map.panToCoordinate(Helper.previous_station())
    }

    function first_station() {
        flickable_map.panToCoordinate(Helper.first_station())
    }

    function removeAll() {
        flickable_map.map.removeMapObject(root_group)
    }

    ListModel {
        id: stationModel
    }

    ListModel {
        id: stationTextModel
    }

    ListModel {
        id: stopModel
    }

    FlickableMap {
        id: flickable_map
        property alias start_point: startPoint
        property alias end_point: endPoint

        anchors.fill: parent

        // TODO: ?
        MapItemView {
            id: stationView
            model: stationModel
            delegate: MapQuickItem {
                coordinate.longitude: lng
                coordinate.latitude: lat
                sourceItem: Image {
                    smooth: true
                    height: 30
                    width: 30
                    source: "qrc:/images/stop.png"
                }
                anchorPoint.y: -30 * appWindow.scalingFactor / 2
                anchorPoint.x: -30 * appWindow.scalingFactor / 2
                z: 45
            }
        }

        // TODO: ?
        MapItemView {
            id: stationTextView
            model: stationTextModel
            delegate: MapQuickItem {
                coordinate.longitude: lng
                coordinate.latitude: lat
                sourceItem: Text {
                    // TODO: width and height?
                    font.pixelSize: UIConstants.FONT_LARGE * appWindow.scalingFactor
                    text: name
                }
                anchorPoint.y: 18
                anchorPoint.x: -(width/2)
                z: 48
            }
        }

        // This is the yellow squares representing stops
        MapItemView {
            id: stopView
            model: stopModel
            delegate: MapQuickItem {
                coordinate.longitude: lng
                coordinate.latitude: lat
                sourceItem: Image {
                    smooth: true
                    height: 20
                    width: 20
                    source: "qrc:/images/station.png"
                }

                anchorPoint.y: -20 * appWindow.scalingFactor / 2
                anchorPoint.x: -20 * appWindow.scalingFactor / 2
                z: 45
            }
        }

        // Trip start
        MapQuickItem {
            id: startPoint
            sourceItem: Image {
                smooth: true
                source: "qrc:/images/start.png"
                height: 50
                width: 50
            }

            anchorPoint.y: -50 * appWindow.scalingFactor + 5
            anchorPoint.x: -50 * appWindow.scalingFactor / 2
            z: 50
        }

        // Trip end
        MapQuickItem {
            id: endPoint
            sourceItem: Image {
                smooth: true
                source: "qrc:/images/finish.png"
                height: 50
                width: 50
            }

            anchorPoint.y: -50 * appWindow.scalingFactor + 5
            anchorPoint.x: -50 * appWindow.scalingFactor / 2
            z: 50
        }

    }

    // Route
    Component {
        id: polyline_component

        MapPolyline {
            line.width: 8 * appWindow.scalingFactor
            z: 30
            smooth: true
        }
    }

    PositionSource {
        id: positionSource
        updateInterval: 200
        active: appWindow.positioningActive
        onPositionChanged: {
            if(appWindow.followMode) {
                flickable_map.panToCoordinate(current_position.coordinate)
            }
        }
    }

    Connections {
        target: appWindow
        onFollowModeEnabled: {
            flickable_map.panToCoordinate(positionSource.position.coordinate)
        }
    }

    Binding {
        target: current_position
        property: "coordinate"
        value: positionSource.position.coordinate
    }

    MapQuickItem {
        id: current_position
        sourceItem: Image {
            smooth: true
            source: "qrc:/images/position.png"
            width: 30
            height: 30
        }

        visible: positionSource.position.latitudeValid && positionSource.position.longitudeValid && appWindow.positioningActive
        anchorPoint.y: -30  * appWindow.scalingFactor / 2
        anchorPoint.x: -30  * appWindow.scalingFactor / 2
        z: 49
    }

//    MapGroup {
//        id: root_group
//    }

    Component {
        id: coord_component

        Location {
            id: coord
        }
    }

    Component {
        id: stop

        MapQuickItem {
            id: stop_circle
            sourceItem: Image {
                smooth: true
                source: "qrc:/images/station.png"
                height: 20 * appWindow.scalingFactor
                width: 20 * appWindow.scalingFactor
            }
            anchorPoint.y: -20 * appWindow.scalingFactor / 2
            anchorPoint.x: -20 * appWindow.scalingFactor / 2
            z: 45
        }
    }
/*
    Component {
        id: endpoint
        MapQuickItem {
            sourceItem: Image {
                smooth: true
                height: 50 * appWindow.scalingFactor
                width: 50 * appWindow.scalingFactor
            }
            anchorPoint.y: -50 * appWindow.scalingFactor + 5
            anchorPoint.x: -50 * appWindow.scalingFactor / 2
            z: 50
        }
    }
*/
/*
    Component {
        id: group

        MapGroup {
            id: stop_group
            property alias station_text : station_text
            property alias station : station
            property alias route : route

            MapText {
                id: station_text
                smooth: true
                font.pixelSize: UIConstants.FONT_LARGE * appWindow.scalingFactor
                offset.x: -(width/2)
                offset.y: 18
                z: 48
            }

            MapImage {
                id: station
                sourceItem: Image {
                    smooth: true
                    source: "qrc:/images/stop.png"
                    height: 30 * appWindow.scalingFactor
                    width: 30 * appWindow.scalingFactor
                }
// TODO:
//                offset.y: -30 * appWindow.scalingFactor / 2
//                offset.x: -30 * appWindow.scalingFactor / 2
                z: 45
            }
            MapPolyline {
                id: route
                smooth: true
                border.width: 8 * appWindow.scalingFactor
                z: 30
            }
        }
    }
*/
    function initialize() {
        flickable_map.addMapItem(current_position)

        Helper.clear_objects()
        var endpoint_object
        var route_coord = []
        var current_route = Reittiopas.get_route_instance()
        current_route.dump_route(route_coord)

        for (var index in route_coord) {
            var endpointdata = route_coord[index]
            var paths = []

            if(index == 0) {
                add_station2(endpointdata.from, endpointdata.from.name)
                flickable_map.start_point.coordinate.longitude = endpointdata.from.longitude
                flickable_map.start_point.coordinate.latitude = endpointdata.from.latitude
            }

            add_station2(endpointdata.to, endpointdata.to.name)

            if(index == route_coord.length - 1) {
                  flickable_map.end_point.coordinate.longitude = endpointdata.to.longitude
                  flickable_map.end_point.coordinate.latitude = endpointdata.to.latitude
            }

            for(var shapeindex in endpointdata.shape) {
                var shapedata = endpointdata.shape[shapeindex]
                paths.push({"longitude": shapedata.x, "latitude": shapedata.y})
            }

            var p = polyline_component.createObject(flickable_map)
            p.line.color = Theme.theme['general'].TRANSPORT_COLORS[endpointdata.type]
            p.path = paths
            flickable_map.addMapItem(p)

            if(endpointdata.type != "walk") {
                for(var stopindex in endpointdata.locs) {
                    var loc = endpointdata.locs[stopindex]

                    if(stopindex != 0 && stopindex != endpointdata.locs.length - 1)
                        add_stop2(loc.latitude, loc.longitude)
                }
            }
        }
    }

    function add_station2(coord, name) {
        if (name != "") {
            // Append to name model
            stationModel.append({"lng": coord.longitude, "lat": coord.latitude, "name": name})
        }

        // Add the normal point for the station
        stationModel.append({"lng": coord.longitude, "lat": coord.latitude})
        Helper.add_station(coord)
    }

    function add_station(coord, name, map_group) {
        map_group.station_text.coordinate = coord
        map_group.station_text.text = name?name:""
        map_group.station.coordinate = coord

        Helper.add_station(coord)
    }

    function add_stop2(latitude, longitude) {
        stopModel.append({"lng": longitude, "lat": latitude})
    }

    function add_stop(latitude, longitude) {
        var stop_object = stop.createObject(appWindow)
        if(!stop_object) {
            console.debug("creating object failed")
            return
        }
        var coord = coord_component.createObject(appWindow)
        coord.latitude = latitude
        coord.longitude = longitude
        stop_object.coordinate = coord
        Helper.push_to_objects(stop_object)
    }
}
