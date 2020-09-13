
import QtQuick 2.1
import Sailfish.Silica 1.0
import "../../js/UIConstants.js" as UIConstants
import "../../js/reittiopas.js" as Reittiopas
import "../../js/storage.js" as Storage
import "../../js/helper.js" as Helper
import "../../js/favorites.js" as Favorites
import "../../js/recentitems.js" as RecentItems
import "../../components"

Column {
    width: parent.width
    anchors.left: parent.left
    anchors.leftMargin: Theme.paddingSmall
    anchors.horizontalCenter: parent.horizontalCenter
    anchors.top: header.bottom

    property alias timeButton: timeButton
    property alias timeBy: timeBy

    function updateValues(fromValue, toValue) {
        from.value = fromValue
        to.value = toValue
    }

    signal paramsChanged(var params)
    ComboBox {
        id: from
        width: parent.width
        label: "Departure"
        description: "Select journeys starting point"
        value: appWindow.locationParameters.from.name || "Choose location"
        menu: ContextMenu {
            ListItem {
                MenuItem {
                    text: "Search"
                }
                onClicked: function() {
                    var dialog = pageStack.push(Qt.resolvedUrl("../dialogs/SearchAddress.qml"))
                    dialog.accepted.connect(function() {
                        from.value = appWindow.locationParameters.from.name
                        paramsChanged({})
                    })
                }
                onPressAndHold: {
                    from.value = "Using GPS"
                    fromGPS.timer.running = true
                }
            }
            ListItem {
                MenuItem {
                    text: "Map"
                }
                onClicked: function() {
                    var dialog = pageStack.push(
                        Qt.resolvedUrl("../dialogs/Map.qml"),
                        {
                            inputCoord: appWindow.locationParameters.from.coord || '',
                            resultName: appWindow.locationParameters.from.name || ''
                        }
                    )
                    dialog.accepted.connect(function() {
                        appWindow.locationParameters.from = JSON.parse(JSON.stringify(dialog.resultObject))
                        from.value = appWindow.locationParameters.from.name
                        paramsChanged({})
                    })
                }
                onPressAndHold: {
                    from.value = "Using GPS"
                    fromGPS.timer.running = true
                }
            }
            ListItem {
                MenuItem {
                    text: "Favorite"
                }
                onClicked: function() {
                    favoritesModel.clear()
                    Favorites.getFavorites(favoritesModel)
                    favoritesModel.insert(0, {name: qsTr("Current location"),coord:"0,0"})
                    recentItemsModel.clear()
                    RecentItems.getRecentItems(recentItemsModel)
                    var dialog = pageStack.push(Qt.resolvedUrl("../dialogs/FavoriteRecentItemSelection.qml"),
                        {
                            model: favoritesModel,
                            model2: recentItemsModel,
                        }
                    )
                    dialog.accepted.connect(function() {
                        appWindow.locationParameters.from = JSON.parse(JSON.stringify(dialog.resultObject))
                        from.value = appWindow.locationParameters.from.name
                        paramsChanged({})
                    })
                }
                onPressAndHold: {
                    if(appWindow.locationParameters.from.name && appWindow.locationParameters.from.coord) {
                        if(("OK" === Favorites.addFavorite(appWindow.locationParameters.from))) {
                            favoritesModel.clear()
                            Favorites.getFavorites(favoritesModel)
                            appWindow.useNotification( qsTr("Location added to favorite places") )
                        } else {
                            appWindow.useNotification(qsTr("Location already in the favorite places"))
                        }
                    } else {
                        appWindow.useNotification(qsTr("No location to put into favorites"))
                    }
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
                paramsChanged({})
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
            ListItem {
                MenuItem {
                    text: "Search"
                }
                onClicked: function() {
                    var dialog = pageStack.push(Qt.resolvedUrl("../dialogs/SearchAddress.qml"), { departure: false })
                    dialog.accepted.connect(function() {
                        to.value = appWindow.locationParameters.to.name
                        paramsChanged({})
                    })
                }
                onPressAndHold: {
                    to.value = "Using GPS"
                    toGPS.timer.running = true
                }
            }
            ListItem {
                MenuItem {
                    text: "Map"
                }
                onClicked: function() {
                    var dialog = pageStack.push(
                        Qt.resolvedUrl("../dialogs/Map.qml"),
                        {
                            inputCoord: appWindow.locationParameters.to.coord || '',
                            resultName: appWindow.locationParameters.to.name || ''
                        }
                    )
                    dialog.accepted.connect(function() {
                        appWindow.locationParameters.to = JSON.parse(JSON.stringify(dialog.resultObject))
                        to.value = appWindow.locationParameters.to.name
                        paramsChanged({})
                    })
                }
                onPressAndHold: {
                    to.value = "Using GPS"
                    toGPS.timer.running = true
                }
            }
            ListItem {
                MenuItem {
                    text: "Favorite"
                }
                onClicked: function() {
                    favoritesModel.clear()
                    Favorites.getFavorites(favoritesModel)
                    favoritesModel.insert(0, {name: qsTr("Current location"),coord:"0,0"})
                    recentItemsModel.clear()
                    RecentItems.getRecentItems(recentItemsModel)
                    var dialog = pageStack.push(Qt.resolvedUrl("../dialogs/FavoriteRecentItemSelection.qml"),
                    {
                        departure: false,
                        model: favoritesModel,
                        model2: recentItemsModel,
                    })
                    dialog.accepted.connect(function() {
                        appWindow.locationParameters.to = JSON.parse(JSON.stringify(dialog.resultObject))
                        to.value = appWindow.locationParameters.to.name
                        paramsChanged({})
                    })
                }
                onPressAndHold: {
                    if(appWindow.locationParameters.to.name && appWindow.locationParameters.to.coord) {
                        if(("OK" === Favorites.addFavorite(appWindow.locationParameters.to))) {
                            favoritesModel.clear()
                            Favorites.getFavorites(favoritesModel)
                            appWindow.useNotification( qsTr("Location added to favorite places") )
                        } else {
                            appWindow.useNotification(qsTr("Location already in the favorite places"))
                        }
                    } else {
                        appWindow.useNotification(qsTr("No location to put into favorites"))
                    }
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
                paramsChanged({})
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
                    paramsChanged({})
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
            paramsChanged({})
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
            paramsChanged({})
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
            paramsChanged({})
    }
    }

    ValueToggle {
        id: timeBy
        label: qsTr("Time by")
        firstValue: qsTr("Departure")
        secondValue: qsTr("Arrival")
        onClicked: {
            appWindow.locationParameters.datetime.timeBy = firstActive ? "departure" : "arrival"
            paramsChanged({})
        }
    }
}

