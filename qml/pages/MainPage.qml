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
import Sailfish.Silica 1.0
import "../js/UIConstants.js" as UIConstants
import "../js/reittiopas.js" as Reittiopas
import "../js/storage.js" as Storage
import "../js/helper.js" as Helper
import "../js/favorites.js" as Favorites
import "../components"

Page {
    id: mainPage

    property date myTime

    onMyTimeChanged: console.debug("Time changed: " + myTime)

    /* Current location acquired with GPS */
    property variant currentCoord: ''
    property variant currentName: ''

    /* Values entered in "To" field */
    property variant toCoord: ''
    property variant toName: ''

    /* Values entered in "From" field */
    property variant fromCoord: ''
    property variant fromName: ''

    property bool endpointsValid: (toCoord && (fromCoord || currentCoord))

    onEndpointsValidChanged: {
        /* if we receive coordinates we are waiting for, start route search */
        if(state == "waiting_route" && endpointsValid) {
            var parameters = {}
            setRouteParameters(parameters)
            pageStack.push(Qt.resolvedUrl("ResultPage.qml"), { search_parameters: parameters })
            state = "normal"
        }
    }

    onStatusChanged: {
        if (status == PageStatus.Activating) {
            appWindow.coverLine1 = ''
            appWindow.coverLine2 = ''
            appWindow.coverLine3 = 'JollaOpas'
            appWindow.coverLine6 = ''

            appWindow.coverLine4 = appWindow.currentApi.charAt(0).toUpperCase() + appWindow.currentApi.slice(1)

            var allowGps = Storage.getSetting("gps")
            if(allowGps == "true") {
                appWindow.gpsEnabled = true
                appWindow.coverLine5 = qsTr('GPS enabled')
            }
            else {
                appWindow.coverLine5 = qsTr('GPS disabled')
            }

            // Refresh favorite routes if api has been changed in SettingsPage
            favoriteRoutesModel.clear()
            Favorites.getFavoriteRoutes('normal', appWindow.currentApi, favoriteRoutesModel)
            // Prevent the keyboard to popup instantly when swithcing back to mainPage
            mainPage.forceActiveFocus()
        }
    }

    function newRoute(name, coord) {
        /* clear all other pages from the stack */
        while(pageStack.depth > 1)
            pageStack.pop(null, true)

        /* bring application to front */
        QmlApplicationViewer.showFullScreen()

        /* Update time */
        timeButton.updateTime()
        dateButton.updateDate()

        /* Update new destination to "to" */
        to.updateLocation(name, 0, coord)

        /* Remove user input location and use gps location */
        from.clear()

        /* use current location if available - otherwise wait for it */
        if(currentCoord != "") {
            var parameters = {}
            setRouteParameters(parameters)
            pageStack.push(Qt.resolvedUrl("ResultPage.qml"), { search_parameters: parameters })
        }
        else if(appWindow.gpsEnabled == false) {
            displayPopupMessage( qsTr("Positioning service disabled from application settings") )
        }
        else {
            state = "waiting_route"
        }
    }

    Component.onCompleted: {
        timeButton.updateTime()
        dateButton.updateDate()
        appWindow.currentApi = Storage.getSetting("api")
    }

    states: [
        State {
            name: "normal"
        },
        State {
            name: "waiting_route"
        }
    ]

    state: "normal"

    function setRouteParameters(parameters) {
        var walking_speed = Storage.getSetting("walking_speed")
        var optimize = Storage.getSetting("optimize")
        var change_margin = Storage.getSetting("change_margin")

        parameters.from_name = fromName ? fromName : currentName
        parameters.from = fromCoord ? fromCoord : currentCoord
        parameters.to_name = toName
        parameters.to = toCoord

        parameters.time = mainPage.myTime
        parameters.timetype = timeTypeSwitch.departure ? "departure" : "arrival"
        parameters.walk_speed = walking_speed == "Unknown"?"70":walking_speed
        parameters.optimize = optimize == "Unknown"?"default":optimize
        parameters.change_margin = change_margin == "Unknown"?"3":Math.floor(change_margin)
        parameters.transport_types = ["ferry"]
        if(Storage.getSetting("train_disabled") != "true")
            parameters.transport_types.push("train")
        if(Storage.getSetting("bus_disabled") != "true") {
            parameters.transport_types.push("bus")
            parameters.transport_types.push("uline")
            parameters.transport_types.push("service")
        }
        if(Storage.getSetting("metro_disabled") != "true")
            parameters.transport_types.push("metro")
        if(Storage.getSetting("tram_disabled") != "true")
            parameters.transport_types.push("tram")
    }

    Rectangle {
        id: waiting
        color: "black"
        z: 250
        opacity: mainPage.state == "normal" ? 0.0 : 0.7

        Behavior on opacity {
            PropertyAnimation { duration: 200 }
        }

        anchors.fill: parent
        MouseArea {
            anchors.fill: parent
            enabled: mainPage.state != "normal"
            onClicked: mainPage.state = "normal"
        }
    }

    BusyIndicator {
        id: busyIndicator
        z: 260
        running: mainPage.state != "normal"
        anchors.centerIn: parent
        size: BusyIndicatorSize.Large
    }

    SilicaFlickable {
        anchors.fill: parent
        contentHeight: parent.height

        PullDownMenu {
            MenuItem { text: qsTr("Settings"); onClicked: { pageStack.push(Qt.resolvedUrl("SettingsPage.qml")) } }
            MenuItem { text: qsTr("Exception info"); visible: appWindow.currentApi === "helsinki"; onClicked: pageStack.push(Qt.resolvedUrl("ExceptionsPage.qml")) }
            MenuItem { text: qsTr("Manage favorite places"); onClicked: pageStack.push(Qt.resolvedUrl("FavoritesPage.qml")) }
            MenuItem {
                enabled: endpointsValid
                text: qsTr("Add as favorite route");
                onClicked: {
                    var fromNameToAdd = fromName ? fromName : currentName
                    var fromCoordToAdd = fromCoord ? fromCoord : currentCoord
                    var res = Favorites.addFavoriteRoute('normal', appWindow.currentApi, fromCoordToAdd, fromNameToAdd, toCoord, toName, favoriteRoutesModel)
                    if (res === "OK") {
                        displayPopupMessage( qsTr("Favorite route added") )
                    }
                    else {
                        displayPopupMessage( qsTr("Maximum amount of favorite routes is 4!") )
                    }
                }
            }
        }

        Column {
            id: content_column
    //         spacing: appWindow.inPortrait? UIConstants.DEFAULT_MARGIN : UIConstants.DEFAULT_MARGIN / 2
            width: parent.width - Theme.paddingLarge
            anchors.horizontalCenter: parent.horizontalCenter

            Item {
                width: parent.width
                height: from.height + to.height + UIConstants.DEFAULT_MARGIN

                LocationEntry {
                    id: from
                    type: qsTr("From")
                    isFrom: true
                    onLocationDone: {
                        fromName = name
                        fromCoord = coord
                    }
                    onCurrentLocationDone: {
                        currentName = name
                        currentCoord = coord
                    }
                    onLocationError: {
                        /* error in getting current position, cancel the wait */
                        mainPage.state = "normal"
                    }
                }

                Spacing { id: location_spacing; anchors.top: from.bottom; height: 30 }

                SwitchLocation {
                    anchors.bottom: to.top
                    from: from
                    to: to
                }

                LocationEntry {
                    id: to
                    type: qsTr("To")
                    onLocationDone: {
                        toName = name
                        toCoord = coord
                    }
                    anchors.top: location_spacing.bottom
                }
            }

            TimeTypeSwitch {
                id: timeTypeSwitch
            }

            Row {
                height: 60
                anchors.horizontalCenter: parent.horizontalCenter

                DateButton {
                    id: dateButton
                    onDateChanged: {
                        mainPage.myTime = new Date(newDate.getFullYear(), newDate.getMonth(), newDate.getDate(),
                                                   myTime.getHours()? myTime.getHours() : 0,
                                                   myTime.getMinutes()? myTime.getMinutes() : 0)
                    }
                }

                Spacing { width: 20 }

                TimeButton {
                    id: timeButton
                    onTimeChanged: {
                        mainPage.myTime = new Date(myTime.getFullYear()? myTime.getFullYear() : 0,
                                                myTime.getMonth()? myTime.getMonth() : 0,
                                                myTime.getDate()? myTime.getDate() : 0,
                                                newTime.getHours(), newTime.getMinutes())
                    }
                }

                Spacing { width: 20 }

                Button {
                    text: qsTr("Now")
                    anchors.verticalCenter: parent.verticalCenter
                    width: 100
                    onClicked: {
                        timeButton.updateTime()
                        dateButton.updateDate()
                    }
                }
            }

            Button {
                anchors.horizontalCenter: parent.horizontalCenter
                enabled: endpointsValid
                text: qsTr("Search")
                onClicked: {
                    var parameters = {}
                    setRouteParameters(parameters)
                    pageStack.push(Qt.resolvedUrl("ResultPage.qml"), { search_parameters: parameters })
                }
            }
        }

        Spacing { id: favorites_spacing; anchors.top: content_column.bottom; height: 5 }


        Item {
            id: headeritem
            width: parent.width - Theme.paddingLarge
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.top: favorites_spacing.bottom
            height: favoriteRouteHeader.height + UIConstants.DEFAULT_MARGIN
            Text {
                id: favoriteRouteHeader
                color: Theme.primaryColor
                font.pixelSize: 36
                text: qsTr("Favorite routes")
            }
        }

        SilicaListView {
            id: favoriteRouteList
            anchors.top: headeritem.bottom
            anchors.bottom: parent.bottom
            spacing: 5
            width: parent.width
            model: favoriteRoutesModel
            delegate: favoriteRouteManageDelegate
            property Item contextMenu

            ViewPlaceholder {
                enabled: favoriteRouteList.count == 0
                verticalOffset: -300
                text: qsTr("No saved favorite routes")
            }

            Component {
                id: contextMenuComponent

                ContextMenu {
                    id: menu
                    property Item currentItem
                    MenuItem {
                        text: qsTr("Add to Cover")
                        onClicked: menu.currentItem.addToCover()
                    }

                    MenuItem {
                        text: qsTr("Remove")
                        onClicked: menu.currentItem.remove()
                    }
                }
            }
        }

        ListModel {
            id: favoriteRoutesModel
        }

        Component {
            id: favoriteRouteManageDelegate

            BackgroundItem {
                id: rootItem
                width: ListView.view.width
                height: menuOpen ? Theme.itemSizeSmall + favoriteRouteList.contextMenu.height : Theme.itemSizeSmall

                property bool menuOpen: favoriteRouteList.contextMenu != null && favoriteRouteList.contextMenu.parent === rootItem

                function addToCover() {
                    Favorites.addFavoriteRoute('cover', appWindow.currentApi, modelFromCoord, modelFromName, modelToCoord, modelToName)
                    displayPopupMessage( qsTr("Favorite route added to cover action.") )
                }

                function remove() {
                    remorse.execute(rootItem, qsTr("Deleting"), function() {
                        Favorites.deleteFavoriteRoute(modelRouteIndex, appWindow.currentApi, favoriteRoutesModel)
                    })
                }

                onClicked:{
                    var parameters = {}
                    setRouteParameters(parameters)
                    parameters.from_name = modelFromName
                    parameters.from = modelFromCoord
                    parameters.to_name = modelToName
                    parameters.to = modelToCoord
                    pageStack.push(Qt.resolvedUrl("ResultPage.qml"), { search_parameters: parameters })
                }

                onPressAndHold: {
                    if (!favoriteRouteList.contextMenu) {
                        favoriteRouteList.contextMenu = contextMenuComponent.createObject(favoriteRouteList)
                    }

                    favoriteRouteList.contextMenu.currentItem = rootItem
                    favoriteRouteList.contextMenu.show(rootItem)
                }

                Label {
                    id: label
                    height: Theme.itemSizeSmall
                    text: modelFromName + " - " + modelToName + " "
                    width: parent.width
                    color: Theme.primaryColor
                    verticalAlignment: Text.AlignVCenter
                    horizontalAlignment: Text.AlignHCenter
                }

                RemorseItem { id: remorse }
            }
        }
    }

    // Added InfoBanner here as a workaround to display it correctly above all other UI elements, fixing the z-order from the one in main.qml isn't trivial
    InfoBanner {
        id: infoBanner
        z: 1
    }
    function displayPopupMessage(message) {
        infoBanner.displayError(message)
    }
}
