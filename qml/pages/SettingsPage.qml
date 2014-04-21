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
*   Mohammed Samee <msameer@foolab.org>r
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
import Sailfish.Silica 1.0
import "../js/UIConstants.js" as UIConstants
import "../js/storage.js" as Storage
import "../js/theme.js" as Theme
import "../components"

Page {
    SilicaFlickable {
        id: settingsContent
        anchors.fill: parent
        contentHeight: content_column.height

        Component.onCompleted: {
            Storage.initialize()
            var setting = Storage.getSetting("api")
            currentApi.set_value(setting == "Unknown"?"helsinki" : setting)
            setting = Storage.getSetting("gps")
            gpsSwitch.set_value(setting == "Unknown"?"false" : setting)
            setting = Storage.getSetting("tram_disabled")
            tramSwitch.set_value(setting == "Unknown"?"false" : setting)
            setting = Storage.getSetting("bus_disabled")
            busSwitch.set_value(setting == "Unknown"?"false" : setting)
            setting = Storage.getSetting("metro_disabled")
            metroSwitch.set_value(setting == "Unknown"?"false" : setting)
            setting = Storage.getSetting("train_disabled")
            trainSwitch.set_value(setting == "Unknown"?"false" : setting)
            setting = Storage.getSetting("optimize")
            optimizeRoute.set_value(setting == "Unknown"?"default" : setting)
            setting = Storage.getSetting("walking_speed")
            walkingSpeed.set_value(setting == "Unknown"?"70" : setting)
            setting = Storage.getSetting("change_margin")
            changeMargin.set_value(setting == "Unknown"?"3" : Math.floor(setting))
        }

        Grid {
            columns: 1
            id: content_column
            spacing: UIConstants.DEFAULT_MARGIN
            width: parent.width

            PageHeader {
                title: qsTr("Settings")
            }

            SectionHeader {
                text: qsTr("Region")
            }

            ComboBox {
                id: currentApi
                function set_value(value) {
                    var val = {"helsinki": 0, "tampere": 1}[value]
                    currentApi.currentIndex = val
                }

                label: qsTr("Active Region")
                menu: ContextMenu {
                    MenuItem {
                        text: "Helsinki"
                        onClicked: Storage.setSetting("api","helsinki")
                    }
                    MenuItem {
                       text: "Tampere"
                        onClicked: Storage.setSetting("api","tampere")
                    }
                }
            }
            TextSwitch {
                id: gpsSwitch
                function updateDescription() {
                    if (gpsSwitch.checked)
                        gpsSwitch.description = "GPS is in use"
                    else
                        gpsSwitch.description = "GPS will not be used"
                }

                function set_value(value) {
                    var val = (value === "true")
                    gpsSwitch.checked = val
                    gpsSwitch.updateDescription()
                }
                text: "Toggle GPS Usage"
                description: ""
                onCheckedChanged: {
                    var val = (checked?"true":"false")
                    appWindow.gpsEnabled = checked
                    Storage.setSetting("gps", val)
                    gpsSwitch.updateDescription()
                }
            }

            SectionHeader {
                text: qsTr("Route search parameters")
            }
            TextSwitch {
                id: busSwitch
                function updateDescription() {
                    if (busSwitch.checked)
                        busSwitch.description = "Route results will contain Buses"
                    else
                        busSwitch.description = "Route results will not contain Buses"
                }

                function set_value(value) {
                    var val = !(value === "true")
                    busSwitch.checked = val
                    busSwitch.updateDescription()
                }
                text: "Bus"
                description: ""
                onCheckedChanged: {
                    Storage.setSetting("bus_disabled", (!checked).toString())
                    busSwitch.updateDescription()
                }
            }
            TextSwitch {
                id: tramSwitch
                function updateDescription() {
                    if (tramSwitch.checked)
                        tramSwitch.description = "Route results will contain Trams"
                    else
                        tramSwitch.description = "Route results will not contain Trams"
                }

                function set_value(value) {
                    var val = !(value === "true")
                    tramSwitch.checked = val
                    tramSwitch.updateDescription()
                }
                text: "Tram"
                description: ""
                onCheckedChanged: {
                    Storage.setSetting("tram_disabled", (!checked).toString())
                    tramSwitch.updateDescription()
                }
            }
            TextSwitch {
                id: metroSwitch
                function updateDescription() {
                    if (metroSwitch.checked)
                        metroSwitch.description = "Route results will contain Metro"
                    else
                        metroSwitch.description = "Route results will not contain Metro"
                }

                function set_value(value) {
                    var val = !(value === "true")
                    metroSwitch.checked = val
                    metroSwitch.updateDescription()
                }
                text: "Metro"
                description: ""
                onCheckedChanged: {
                    Storage.setSetting("metro_disabled", (!checked).toString())
                    metroSwitch.updateDescription()
                }
            }
            TextSwitch {
                id: trainSwitch
                function updateDescription() {
                    if (trainSwitch.checked)
                        trainSwitch.description = "Route results will contain Trains"
                    else
                        trainSwitch.description = "Route results will not contain Trains"
                }

                function set_value(value) {
                    var val = !(value === "true")
                    trainSwitch.checked = val
                    trainSwitch.updateDescription()
                }
                text: "Train"
                description: ""
                onCheckedChanged: {
                    Storage.setSetting("train_disabled", (!checked).toString())
                    trainSwitch.updateDescription()
                }
            }

            Slider {
                id: changeMargin
                function set_value(value) {
                    changeMargin.value = value
                    changeMargin.updateLabel()
                }
                function updateLabel() {
                    changeMargin.label = "Change Margin (" + changeMargin.value + " minutes)"
                }
                width: parent.width
                minimumValue: 0
                maximumValue: 10
                value: 5
                stepSize: 1
                handleVisible: true
                onValueChanged: {
                    Storage.setSetting("change_margin", changeMargin.value)
                    changeMargin.updateLabel()
                }
            }

            ComboBox {
                id: optimizeRoute
                function set_value(value) {
                    var idx = {"default": 0, "fastest": 1, "least_transfers": 2, "least_walking": 3}[value]
                    optimizeRoute.currentIndex = idx
                }

                label: qsTr("Optimize Route by")
                menu: ContextMenu {
                    MenuItem {
                        text: qsTr("Default")
                        onClicked: Storage.setSetting('optimize','default')
                    }
                    MenuItem {
                        text: qsTr("Fastest")
                        onClicked: Storage.setSetting('optimize','fastest')
                    }
                    MenuItem {
                        text: qsTr("Least Transfers")
                        onClicked: Storage.setSetting('optimize','least_transfers')
                    }
                    MenuItem {
                        text: qsTr("Least Walking")
                        onClicked: Storage.setSetting('optimize','least_walking')
                    }
                }
            }

            ComboBox {
                id: walkingSpeed
                function set_value(value) {
                    var idx = {"70": 0, "100": 1, "120": 2, "150": 3}[value]
                    walkingSpeed.currentIndex = idx
                }

                label: qsTr("Walking speed")
                menu: ContextMenu {
                    MenuItem {
                        text: qsTr("Walking")
                        onClicked: Storage.setSetting('walking_speed','70')
                    }
                    MenuItem {
                        text: qsTr("Fast Walking")
                        onClicked: Storage.setSetting('walking_speed','100')
                    }
                    MenuItem {
                        text: qsTr("Very Fast Walking")
                        onClicked: Storage.setSetting('walking_speed','120')
                    }
                    MenuItem {
                        text: qsTr("Running")
                        onClicked: Storage.setSetting('walking_speed','150')
                    }
                }
            }
        }
    }
}
