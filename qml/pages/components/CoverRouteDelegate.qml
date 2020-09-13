import QtQuick 2.1
import Sailfish.Silica 1.0
import "../../js/helper.js" as Helper

Column {
    id: waypointColumn
    width: appCover.width
    Timer {
        id: differenceTimer
        interval: 1000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: {
            clockTick()
        }
    }

    // update the clocks on the cover
    function clockTick() {
        var model = routeModel.get(routeView.currentIndex)
        if(!model) return
        var stopTime = model.from.time
        timeLeftLabel.text = Helper.prettyTimeFromSeconds(Helper.timestampDifferenceInSeconds(null, stopTime))
    }
    Row {
        width: parent.width
        Label {
            font.pixelSize: Theme.fontSizeMedium
            width: parent.width
            horizontalAlignment: Text.AlignHCenter

            property string schedTime: Helper.prettyTime(from.time)
            property date realTime: from.time
            property string realTimeAcc: "min"

            // format the time according to properties
            function timeFormat() {
                // use scheduled time if we don't have real time
                if (realTime.getTime() === 0) { // there is a strange bug, that causes the leg's getTime to be 7200000. This is a workaround.hasOwnProperty()
                    return schedTime
                } else {
                    // if we have real time, show it according to the accuracy
                    if (realTimeAcc === "sec") {
                        return Qt.formatDateTime(realTime, "hh:mm:ss")
                    } else {
                        return Qt.formatDateTime(realTime, "hh:mm")
                    }
                }
            }

            id: timeView
            text: timeFormat()
            onRealTimeChanged: {
                if (realTime.getTime() !== 0) {
                    textZoom.start()
                }
            }

            NumberAnimation {
                id: textZoom
                target: timeView
                properties: "font.pixelSize"
                from: Theme.fontSizeMedium * 1.2
                to: Theme.fontSizeMedium
                duration: 500
            }
        }
    }
    Row {
        width: parent.width
        Label {
            id: stopName
            text: from.name
            font.pixelSize: Theme.fontSizeSmall
            width: parent.width
            wrapMode: Text.WordWrap
            horizontalAlignment: Text.AlignHCenter
        }
    }
    Row {
        width: parent.width
        Image {
            width: parent.width * 1/3
            id: lineImage
            source: "qrc:/images/" + type + ".png"
            fillMode: Image.PreserveAspectFit
            smooth: true
            anchors.verticalCenter: parent.verticalCenter
        }
        Column {
            width: parent.width * 2/3
            Label {
                id: lineNumber
                text: model.code ? model.code : Math.floor(length/100)/10 + " km"
                font.pixelSize: Theme.fontSizeExtraLarge
                horizontalAlignment: Text.AlignHCenter
                anchors.horizontalCenter: parent.horizontalCenter
            }
            Label {
                id: timeLeftLabel
                font.pixelSize: Theme.fontSizeMedium
                horizontalAlignment: Text.AlignHCenter
                anchors.horizontalCenter: lineNumber.horizontalCenter
            }
        }
    }
}
