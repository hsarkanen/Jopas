/**********************************************************************
*
* This file is part of the Jopas, forked from Meegopas.
* More information:
*
*   https://github.com/rasjani/Jopas
*   https://github.com/junousia/Meegopas
*
* Author: Jani Mikkonen <jani.mikkonen@gmail.com>
* Original author: Jukka Nousiainen <nousiaisenjukka@gmail.com>
* Other contributors:
*   Jonni Rainisto <jonni.rainisto@gmail.com>
*   Mohammed Sameer <msameer@foolab.org>
*   Clovis Scotti <scotti@ieee.org>
*   Benoit HERVIER <khertan@khertan.net>
*   Heikki Sarkanen <heikki.sarkanen@gmail.com>
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

/* Modified from the example by Clovis Scotti <scotti@ieee.org>, http://cpscotti.com/blog/?p=52, released with GPL 3.0 */

import QtQuick 2.1
import QtLocation 5.0
import Sailfish.Silica 1.0

Map {
    id: map
    anchors.fill: parent
    zoomLevel: 16
    clip: true
    gesture.enabled: !appWindow.followMode
    gesture.flickDeceleration: 4000

    Rectangle {
        anchors.fill: map
        // TODO: bad color
        color: "black"
        opacity: mapTypeMenu.active ? 1.0 : 0.0
        Behavior on opacity {
            NumberAnimation { duration: 250 }
        }
        MouseArea {
            anchors.fill: parent
            enabled: mapTypeMenu.active
        }
    }

    plugin: Plugin {
        name: "nokia"

        PluginParameter {
            name: "app_id"
            value: "ETjZnV1eZZ5o0JmN320V"
        }

        PluginParameter {
            name: "token"
            value: "QYpeZ4z7gwhQr7iW0hOTUQ%3D%3D"
        }
    }

    center {
        latitude: 60.1687069096
        longitude: 24.9407379411
    }

    function panToCoordinate(coordinate) {
        map.panToLatLong(coordinate.latitude, coordinate.longitude)
    }

    function panToLatLong(latitude,longitude) {
        map.center.latitude = latitude
        map.center.longitude = longitude
    }

    MapQuickItem {
        width: 50 // width of MapButton
        anchors.left: parent.left
        anchors.verticalCenter: parent.verticalCenter

        sourceItem: Column {
            id: col
            width: parent.width
            spacing: 16

            MapButton {
                id: mapType
                visible: map.supportedMapTypes.length > 1
                source: "qrc:/images/maptype.png"
                onClicked: {
                    mapTypeMenu.show(map)
                }

                ContextMenu {
                    id: mapTypeMenu

                    Repeater {
                        model: map.supportedMapTypes.length
                        MenuItem {
                            text: map.supportedMapTypes[modelData].description
                            visible: map.supportedMapTypes[modelData].mobile
                            onClicked: map.activeMapType = map.supportedMapTypes[modelData]
                        }
                    }
                }
            }

            MapButton {
                source: "qrc:/images/current.png"
                selected: appWindow.followMode
                onClicked: appWindow.followMode = !appWindow.followMode
            }
        }
    }
}
