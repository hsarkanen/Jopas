import QtQuick 2.1
import Sailfish.Silica 1.0

Rectangle {
    height: appCover.height / 5
    width: parent.width
    color: "transparent"

    Rectangle {
        color: (itinerariesView.currentIndex == index ? Theme.highlightColor : Theme.secondaryColor )
        border.color: Theme.primaryColor
        border.width: 1
        opacity: (itinerariesView.currentIndex == index ? 0.5 : 0.2)

        radius: 5
        smooth: true

        height: parent.height
        width: parent.width

        anchors {
            verticalCenter: parent.verticalCenter
        }
    }

    Column {
        anchors.verticalCenter: parent.verticalCenter
        anchors.left: parent.left
        anchors.leftMargin: Theme.paddingSmall

        Label {
            text: Qt.formatTime(start, "hh:mm")
            color: Theme.secondaryColor
            font.pixelSize: Theme.fontSizeSmall
        }

        Label {
            text: {
                if (legs.get(0) && legs.get(0).type !== "walk" ) {
                    return legs.get(0).code;
                }
                else if (legs.get(1) && legs.get(1).type !== "walk" ) {
                    return legs.get(1).code;
                }
            }
            color: Theme.secondaryColor
            font.pixelSize: Theme.fontSizeSmall
        }
    }

    Flow {
        anchors.verticalCenter: parent.verticalCenter
        anchors.horizontalCenter: parent.horizontalCenter

        Repeater {
            id: repeater
            model: legs
            Column {
                visible: repeater.count == 1 ? true : (type == "walk") ? false : true
                Image {
                    id: transportIcon
                    source: "qrc:/images/" + type + ".png"
                    smooth: true
                    height: Theme.iconSizeExtraSmall
                    width: height
                }
            }
        }
    }

    Column {
        anchors.right: parent.right
        anchors.verticalCenter: parent.verticalCenter
        anchors.rightMargin: Theme.paddingSmall
        anchors.leftMargin: Theme.paddingSmall

        Label {
            text: Qt.formatTime(finish, "hh:mm")
            anchors.right: parent.right
            color: Theme.secondaryColor
            font.pixelSize: Theme.fontSizeSmall
        }

        Label {
            text: Math.floor(walk/100)/10 + " km"
            horizontalAlignment: Qt.AlignRight
            color: Theme.secondaryColor
            font.pixelSize: Theme.fontSizeSmall
        }
    }
}
