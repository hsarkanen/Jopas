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

Item {
    property date myTime
    property bool timeNow: true
    property bool dateToday: dateButton.dateToday
    width: parent.width
    height: 50
    anchors.left: parent.left

    function setTimeNow() {
        timeButton.updateTime()
        dateButton.updateDate()
    }

    // Handle status of the TextSwitches when element is clicked, parameter now is true if nowSwitch was clicked
    function handleSwitchesCheckedState(now) {
        if (now && !nowSwitch.checked) {
            nowSwitch.checked = true
            timeSwitch.checked = false
            timeNow = true
        }
        else if (!now && !timeSwitch.checked) {
            timeSwitch.checked = true
            nowSwitch.checked = false
            timeNow = false
        }
        // no need to do anything else
    }

    onMyTimeChanged: {
        timeButton.storedDate = myTime
        timeButton.text = Qt.formatTime(myTime, "hh:mm")
    }

    TextSwitch {
        id: nowSwitch
        anchors.left: parent.left
        anchors.verticalCenter: parent.verticalCenter
        width: 154
        text: qsTr("Now")
        checked: true
        automaticCheck: false
        onClicked: handleSwitchesCheckedState(true)
    }
    Item {
        anchors.left: nowSwitch.right
        anchors.verticalCenter: parent.verticalCenter
        width: Screen.width - nowSwitch.width
        Switch {
            id: timeSwitch
            width: Theme.itemSizeSmall
            checked: false
            automaticCheck: false
            anchors.left: parent.left
            anchors.verticalCenter: parent.verticalCenter
            onClicked: handleSwitchesCheckedState(false)
        }
        DateButton {
            id: dateButton
            anchors.left: timeSwitch.right
            anchors.verticalCenter: parent.verticalCenter
            onClicked: handleSwitchesCheckedState(false)
            onDateChanged: {
                myTime = new Date(newDate.getFullYear(), newDate.getMonth(), newDate.getDate(),
                                           myTime.getHours()? myTime.getHours() : 0,
                                                              myTime.getMinutes()? myTime.getMinutes() : 0)
            }
        }
        Spacing { id: dateButtonSpacing; anchors.left: dateButton.right; width: 15 }
        TimeButton {
            id: timeButton
            anchors.left: dateButtonSpacing.right
            anchors.verticalCenter: parent.verticalCenter
            onClicked: handleSwitchesCheckedState(false)
            onTimeChanged: {
                myTime = new Date(myTime.getFullYear()? myTime.getFullYear() : 0,
                                                                 myTime.getMonth()? myTime.getMonth() : 0,
                                                                                    myTime.getDate()? myTime.getDate() : 0,
                                                                                                      newTime.getHours(), newTime.getMinutes())
            }
        }
        IconButton {
            anchors.left: timeButton.right
            anchors.verticalCenter: parent.verticalCenter
            icon.source: "image://theme/icon-m-clear"
            onClicked: {
                setTimeNow()
                handleSwitchesCheckedState(false)
            }
        }
    }
}
