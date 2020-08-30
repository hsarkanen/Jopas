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
import "../js/recentitems.js" as RecentItems
import "../components"

Dialog {
    id: mainPage
    forwardNavigation: true
    canNavigateForward: paramsValid
    canAccept: paramsValid
    acceptDestination: Qt.resolvedUrl("ResultPage.qml")

    /* ReittiOpas query params */
    property bool paramsValid
    property variant searchParameters

    onParamsValidChanged: {
        /* if we receive coordinates we are waiting for, start route search */
        if(state == "waiting_route" && paramsValid) {
            var parameters = {}
            setRouteParameters(parameters)
            pageStack.push(Qt.resolvedUrl("ResultPage.qml"), { search_parameters: parameters })
            state = "normal"
        } else {
            setRouteParameters({})
        }
    }

    onAcceptPendingChanged: {
        mainPage.acceptDestinationInstance.search_parameters = searchParameters
        mainPage.acceptDestinationInstance.startSearch()
    }

    onStatusChanged: {
        if (status == PageStatus.Activating) {
            appWindow.coverAlignment = Text.AlignHCenter
            appWindow.coverHeader = "JollaOpas"
            appWindow.coverContents = appWindow.currentApi.charAt(0).toUpperCase() + appWindow.currentApi.slice(1)

            // Prevent the keyboard to popup instantly when swithcing back to mainPage
            mainPage.forceActiveFocus()
        }
    }

    function refreshFavoriteRoutes() {
            favoriteRoutesModel.clear()
            Favorites.getFavoriteRoutes("normal", appWindow.currentApi, favoriteRoutesModel)
    }

    function newRoute(name, coord) {
        /* clear all other pages from the stack */
        while(pageStack.depth > 1)
            pageStack.pop(null, true)

        /* bring application to front */
        QmlApplicationViewer.showFullScreen()

        /* Update time */
        timeSwitch.setTimeNow()

        /* Update new destination to "to" */
        to.updateLocation(name, 0, coord)

        /* Remove user input location and use gps location */
        from.clear()

        /* use current location if available - otherwise wait for it */
        if(appWindow.locationParameters.gps.coord) {
            var parameters = {}
            setRouteParameters(parameters)
            pageStack.push(Qt.resolvedUrl("ResultPage.qml"), { search_parameters: parameters })
        }
        else {
            state = "waiting_route"
        }
    }

    Component.onCompleted: {
        RecentItems.initialize()
        Favorites.initialize()
        timeButton.setTimeNow()
        appWindow.currentApi = Storage.getSetting("api")
        refreshFavoriteRoutes()
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
        try {
            var walking_speed = Storage.getSetting("walking_speed")
            var change_margin = Storage.getSetting("change_margin")
            var change_reluctance = Storage.getSetting("change_reluctance")
            var walk_reluctance = Storage.getSetting("walk_reluctance")
            var currentDate = new Date()

            // Only add to recentitems if the place is not from favorites and
            // user specified start point

            var fromFound = Helper.findModelItem(favoritesModel, function(item) {
                return item.name === appWindow.locationParameters.from.name
            })
            var toFound = Helper.findModelItem(favoritesModel, function(item) {
                return item.name === appWindow.locationParameters.to.name
            })
            if (appWindow.locationParameters.from.name && !fromFound) {
                RecentItems.addRecentItem(appWindow.locationParameters.from.name, appWindow.locationParameters.from.coord)
            }
            if (appWindow.locationParameters.to.name && !toFound) {
                RecentItems.addRecentItem(appWindow.locationParameters.to.name, appWindow.locationParameters.to.coord)
            }

            parameters.from_name = appWindow.locationParameters.from.name ? appWindow.locationParameters.from.name : appWindow.locationParameters.gps.name
            parameters.from = appWindow.locationParameters.from.coord ? appWindow.locationParameters.from.coord : appWindow.locationParameters.gps.coord
            parameters.to_name = appWindow.locationParameters.to.name
            parameters.to = appWindow.locationParameters.to.coord

            appWindow.locationParameters.from.name = parameters.from_name
            appWindow.locationParameters.from.coord = parameters.from

            currentDate.setFullYear(appWindow.locationParameters.datetime.year || currentDate.getFullYear())
            currentDate.setMonth(appWindow.locationParameters.datetime.month || currentDate.getMonth())
            currentDate.setDate(appWindow.locationParameters.datetime.date || currentDate.getDate())
            currentDate.setHours(appWindow.locationParameters.datetime.hour || currentDate.getHours())
            currentDate.setMinutes(appWindow.locationParameters.datetime.minute || currentDate.getMinutes())

            parameters.jstime = currentDate

            parameters.timetype = timeBy.firstActive ? "departure" : "arrival"
            parameters.arriveBy = !timeBy.firstActive

            parameters.walk_speed = walking_speed === "Unknown" ? "70" : walking_speed
            parameters.change_margin = change_margin === "Unknown" ? "3" : Math.floor(change_margin)
            parameters.change_reluctance = change_reluctance === "Unknown" ? "10" : Math.floor(change_reluctance)
            parameters.walk_reluctance = walk_reluctance === "Unknown" ? "2" : Math.floor(walk_reluctance)
            parameters.modes =""

        if (appWindow.currentApi === "helsinki") {
            if(Storage.getSetting("bus_disabled") === "false") {
                parameters.modes += "BUS,";
            }
            if(Storage.getSetting("tram_disabled") === "false") {
                parameters.modes += "TRAM,";
            }
            if(Storage.getSetting("metro_disabled") === "false") {
                parameters.modes += "SUBWAY,"
            }
            if(Storage.getSetting("train_disabled") === "false") {
                parameters.modes += "RAIL,";
            }
            if(Storage.getSetting("ferry_disabled") === "false") {
                parameters.modes += "FERRY,";
            }
        }
        else {
            parameters.modes += "BUS,"
        }
        parameters.modes += "WALK"
        } catch (err) {
            console.log("setRouteParameters", JSON.stringify(err))
            return false
    }
        if(!!parameters.from_name || !!parameters.from || !!parameters.to_name || !!parameters.to) {
            searchParameters = parameters
            return true
        }
        return  false
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

        ListModel {
            id: favoritesModel
        }
        ListModel {
            id: recentItemsModel
        }
        PullDownMenu {
            MenuItem { text: qsTr("Settings"); onClicked: { pageStack.push(Qt.resolvedUrl("SettingsPage.qml")) } }
            MenuItem { text: qsTr("Exception info"); visible: appWindow.currentApi === "helsinki"; onClicked: pageStack.push(Qt.resolvedUrl("ExceptionsPage.qml")) }
            MenuItem { text: qsTr("Manage favorite places"); onClicked: pageStack.push(Qt.resolvedUrl("FavoritesPage.qml")) }
            MenuItem {
                enabled: paramsValid
                text: qsTr("Add as favorite route");
                onClicked: {
                    var res = Favorites.addFavoriteRoute(
                        "normal",
                        appWindow.currentApi,
                        appWindow.locationParameters.from.coord ? appWindow.locationParameters.from.coord : appWindow.locationParameters.gps.coord,
                        appWindow.locationParameters.from.name ? appWindow.locationParameters.from.name : appWindow.locationParameters.gps.name,
                        appWindow.locationParameters.to.coord,
                        appWindow.locationParameters.to.name,
                        favoriteRoutesModel
                    )
                    if (res === "OK") {
                        displayPopupMessage( qsTr("Favorite route added") )
                    }
                    else {
                        displayPopupMessage( qsTr("Maximum amount of favorite routes is 4!") )
                    }
                }
            }
            MenuItem {
                text: qsTr("Get Return Route");
                onClicked: {
                    var fromObj = JSON.parse(JSON.stringify(appWindow.locationParameters.from))
                    var toObj = JSON.parse(JSON.stringify(appWindow.locationParameters.to))
                    appWindow.locationParameters.from = toObj
                    appWindow.locationParameters.to = fromObj
                    from.value = appWindow.locationParameters.from.name || "Choose Location"
                    to.value = appWindow.locationParameters.to.name || "Choose Location"
                    paramsValid = setRouteParameters({})
                }
            }
        }
        PageHeader { id: header ; title: qsTr("Search")}
        Column {
            id: content_column
            width: parent.width
            anchors.left: parent.left
            anchors.leftMargin: Theme.paddingSmall
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.top: header.bottom

            ComboBox {
                id: from
                width: parent.width
                label: "Departure"
                description: "Select journeys starting point"
                value: appWindow.locationParameters.from.name || "Choose location"
                menu: ContextMenu {
                    MenuItem {
                        text: "Search"
                        onClicked: function() {
                            var dialog = pageStack.push(Qt.resolvedUrl("./dialogs/SearchAddress.qml"))
                            dialog.accepted.connect(function() {
                                from.value = appWindow.locationParameters.from.name
                                paramsValid = setRouteParameters({})
                            })
                        }
                    }
                    MenuItem {
                        text: "Map"
                        onClicked: function() {
                            var dialog = pageStack.push(
                                Qt.resolvedUrl("./dialogs/Map.qml"),
                                {
                                    inputCoord: appWindow.locationParameters.from.coord || '',
                                    resultName: appWindow.locationParameters.from.name || ''
                                }
                            )
                            dialog.accepted.connect(function() {
                                appWindow.locationParameters.from = JSON.parse(JSON.stringify(dialog.resultObject))
                                from.value = appWindow.locationParameters.from.name
                                paramsValid = setRouteParameters({})
                            })
                        }
                    }
                    MenuItem {
                        text: "Favorite"
                        onClicked: function() {
                            favoritesModel.clear()
                            Favorites.getFavorites(favoritesModel)
                            favoritesModel.insert(0, {name: qsTr("Current location"),coord:"0,0"})
                            recentItemsModel.clear()
                            RecentItems.getRecentItems(recentItemsModel)
                            var dialog = pageStack.push(Qt.resolvedUrl("./dialogs/FavoriteRecentItemSelection.qml"),
                                {
                                    model: favoritesModel,
                                    model2: recentItemsModel,
                                }
                            )
                            dialog.accepted.connect(function() {
                                appWindow.locationParameters.from = JSON.parse(JSON.stringify(dialog.resultObject))
                                from.value = appWindow.locationParameters.from.name
                                paramsValid = setRouteParameters({})
                            })
                        }
                    }
                }
                onPressAndHold: function(){
                    from.value = "Using GPS"
                    fromGPS.timer.running = true
                }
                LocationSource {
                    id: fromGPS
                    onLocationFound: function() {
                        appWindow.locationParameters.from = appWindow.locationParameters.gps
                        from.value = appWindow.locationParameters.from.name
                        paramsValid = setRouteParameters({})
                    }
                    onNoLocationSource: function(){
                        appWindow.useNotification( qsTr("Location service unavailable") )
                        from.value = appWindow.locationParameters.from.name || "Choose location"
                    }
                }
            }
            ComboBox {
                id: to
                width: parent.width
                label: "Destination"
                description: "Select where journey ends"
                value: appWindow.locationParameters.to.name || "Choose location"
                menu: ContextMenu {
                    MenuItem {
                        text: "Search"
                        onClicked: function() {
                            var dialog = pageStack.push(Qt.resolvedUrl("./dialogs/SearchAddress.qml"), { departure: false })
                            dialog.accepted.connect(function() {
                                to.value = appWindow.locationParameters.to.name
                                paramsValid = setRouteParameters({})
                            })
                        }
                    }
                    MenuItem {
                        text: "Map"
                        onClicked: function() {
                            var dialog = pageStack.push(
                                Qt.resolvedUrl("./dialogs/Map.qml"),
                                {
                                    inputCoord: appWindow.locationParameters.to.coord || '',
                                    resultName: appWindow.locationParameters.to.name || ''
                                }
                            )
                            dialog.accepted.connect(function() {
                                appWindow.locationParameters.to = JSON.parse(JSON.stringify(dialog.resultObject))
                                to.value = appWindow.locationParameters.to.name
                                paramsValid = setRouteParameters({})
                            })
                        }
                    }
                    MenuItem {
                        text: "Favorite"
                        onClicked: function() {
                            favoritesModel.clear()
                            Favorites.getFavorites(favoritesModel)
                            favoritesModel.insert(0, {name: qsTr("Current location"),coord:"0,0"})
                            recentItemsModel.clear()
                            RecentItems.getRecentItems(recentItemsModel)
                            var dialog = pageStack.push(Qt.resolvedUrl("./dialogs/FavoriteRecentItemSelection.qml"),
                            {
                                departure: false,
                                model: favoritesModel,
                                model2: recentItemsModel,
                            })
                            dialog.accepted.connect(function() {
                                console.log(JSON.parse(JSON.stringify(dialog.resultObject)))
                                appWindow.locationParameters.to = JSON.parse(JSON.stringify(dialog.resultObject))
                                to.value = appWindow.locationParameters.to.name
                                paramsValid = setRouteParameters({})
                            })
                        }
                    }
                }
                onPressAndHold: function(){
                    to.value = "Using GPS"
                    toGPS.timer.running = true
                }
                LocationSource {
                    id: toGPS
                    onLocationFound: function() {
                        appWindow.locationParameters.to = appWindow.locationParameters.gps
                        to.value = appWindow.locationParameters.to.name
                        paramsValid = setRouteParameters({})
                    }
                    onNoLocationSource: function(){
                        appWindow.useNotification( qsTr("Location service unavailable") )
                        to.value = appWindow.locationParameters.to.name || "Choose location"
                    }
                    }
                }
            ValueToggle {
                id: dateToggle
                label: qsTr("Date")
                visible: !dateToggle.selectedDate
                property bool selectedDate

                function openDateDialog() {
                    var now = new Date()
                    var date = appWindow.locationParameters.datetime.date || now.getDate()
                    var month = appWindow.locationParameters.datetime.month || now.getMonth()
                    var year = appWindow.locationParameters.datetime.year || now.getFullYear()
                    var obj = pageStack.animatorPush("Sailfish.Silica.DatePickerDialog",
                                                     { date: new Date(year, month, date, 0, 0, 0) })

                    obj.pageCompleted.connect(function(page) {
                        page.accepted.connect(function() {
                            appWindow.locationParameters.datetime.date = page.date.getDate()
                            appWindow.locationParameters.datetime.month = page.date.getMonth()
                            appWindow.locationParameters.datetime.year = page.date.getFullYear()
                            selectedDate = true
                            paramsValid = setRouteParameters({})
                        })
                    })
                }

                function toggle() {
                    var d = new Date()
                    if (!dateToggle.firstActive) {
                        d.setDate(d.getDate() + 1)
                    }
                    appWindow.locationParameters.datetime.date = d.getDate()
                    appWindow.locationParameters.datetime.month = d.getMonth()
                    appWindow.locationParameters.datetime.year = d.getFullYear()
                    paramsValid = setRouteParameters({})
                }
                firstValue: "Today"
                secondValue: "Tomorrow"
                onPressAndHold: openDateDialog()
                onClicked: toggle()
                description: "Press and hold to select a custom date"
                onSelectedDateChanged: function() {
                    var now = new Date()
                    var date = appWindow.locationParameters.datetime.date || now.getDate()
                    var month = appWindow.locationParameters.datetime.month || now.getMonth()
                    var year = appWindow.locationParameters.datetime.year || now.getFullYear()
                    var time = new Date(year, month, date, 0, 0, 0)
                    var type = Formatter.TimeValueTwentyFourHours
                    dateLabel.value = Qt.formatDate(time)
                    paramsValid = setRouteParameters({})
                }
                }

            ValueButton {
                id: dateLabel
                visible: dateToggle.selectedDate
                label: qsTr("Date")
                width: parent.width
                onClicked: {
                    dateToggle.selectedDate = !dateToggle.selectedDate
                    dateToggle.toggle()
                }
                description: "Click to reset date"
                    }

            ValueButton {
                id: timeButton
                property bool update
                function openTimeDialog() {
                    var hour = appWindow.locationParameters.datetime.hour || 0
                    var minute = appWindow.locationParameters.datetime.minute || 0
                    var obj = pageStack.animatorPush("Sailfish.Silica.TimePickerDialog", {
                                                    hourMode: DateTime.TwentyFourHours,
                                                    hour: hour,
                                                    minute: minute
                                                })

                    obj.pageCompleted.connect(function(page) {
                        page.accepted.connect(function() {
                            appWindow.locationParameters.datetime.hour = page.hour
                            appWindow.locationParameters.datetime.minute = page.minute
                            update = !update
                        })
                    })
                }

                function setTimeNow() {
                    var now = new Date()
                    appWindow.locationParameters.datetime.hour = now.getHours()
                    appWindow.locationParameters.datetime.minute = now.getMinutes()
                    update = !update
            }

                label: "Time"
                width: parent.width
                onClicked: openTimeDialog()
                onPressAndHold: setTimeNow()
                onUpdateChanged: {
                    var hour = appWindow.locationParameters.datetime.hour || 0
                    var minute = appWindow.locationParameters.datetime.minute || 0
                    var time = new Date(0, 0, 0, hour, minute, 0)
                    var type = Formatter.TimeValueTwentyFourHours
                    value = Format.formatDate(time, type)
                    paramsValid = setRouteParameters({})
            }
            }

            ValueToggle {
                id: timeBy
                label: qsTr("Time by")
                firstValue: qsTr("Departure")
                secondValue: qsTr("Arrival")
                onClicked: {
                    paramsValid = setRouteParameters({})
                }
            }
        }

        Spacing { id: favorites_spacing; anchors.top: content_column.bottom; height: 5 * Theme.pixelRatio }


        Item {
            id: headeritem
            width: parent.width
            anchors.left: parent.left
            anchors.leftMargin: Theme.paddingSmall
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.top: favorites_spacing.bottom
            height: (favoriteRouteHeader.height + UIConstants.DEFAULT_MARGIN) * Theme.pixelRatio
            Text {
                id: favoriteRouteHeader
                color: Theme.highlightColor
                font.pixelSize: 36 * Theme.pixelRatio
                text: qsTr("Favorite routes")
            }
        }

        SilicaListView {
            id: favoriteRouteList
            anchors.top: headeritem.bottom
            anchors.bottom: parent.bottom
            spacing: 5 * Theme.pixelRatio
            width: parent.width
            model: favoriteRoutesModel
            delegate: favoriteRouteManageDelegate
            property Item contextMenu

            ViewPlaceholder {
                enabled: favoriteRouteList.count == 0
                // Not perfect, but shows the text on Jolla Phone, Jolla Tablet and Fairphone2 (was -300)
                verticalOffset: (favoriteRouteList.height - mainPage.height) * 0.5
                text: qsTr("No saved favorite routes")
            }

            Component {
                id: contextMenuComponent

                ContextMenu {
                    id: menu
                    property Item currentItem
                    MenuItem {
                        text: qsTr("Get Return Route")
                        onClicked: menu.currentItem.search(true)
                    }
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

                function search(reverse) {
                    appWindow.locationParameters.from.name = reverse ? modelToName : modelFromName
                    appWindow.locationParameters.from.coord = reverse ? modelToCoord : modelFromCoord
                    appWindow.locationParameters.to.name = reverse ? modelFromName : modelToName
                    appWindow.locationParameters.to.coord = reverse ? modelFromCoord : modelToCoord
                    from.value = appWindow.locationParameters.from.name
                    to.value = appWindow.locationParameters.to.name
                    paramsValid = setRouteParameters({})
                    pageStack.navigateForward()
                }

                onClicked: search()

                onPressAndHold: {
                    if (!favoriteRouteList.contextMenu) {
                        favoriteRouteList.contextMenu = contextMenuComponent.createObject(favoriteRouteList)
                    }

                    favoriteRouteList.contextMenu.currentItem = rootItem
                    favoriteRouteList.contextMenu.open(rootItem)
                }

                Label {
                    id: label
                    height: Theme.itemSizeSmall
                    text: modelFromName + " - " + modelToName + " "
                    width: parent.width
                    color: Theme.primaryColor
                    verticalAlignment: Text.AlignVCenter
                    horizontalAlignment: Text.AlignHCenter
                    elide: Text.ElideRight
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
