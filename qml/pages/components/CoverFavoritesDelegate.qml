import QtQuick 2.1
import Sailfish.Silica 1.0

Rectangle {
    width: favoritesView.width
    height: appCover.height / 5
    color: "transparent"

    Rectangle {
        color: (favoritesView.currentIndex == index ? Theme.highlightColor : Theme.secondaryColor )
        border.color: Theme.primaryColor
        border.width: 1
        opacity: (favoritesView.currentIndex == index ? 0.5 : 0.2)

        radius: 5
        smooth: true

        height: parent.height
        width: parent.width

        anchors {
            verticalCenter: parent.verticalCenter
        }
    }
    Column {
        id: idx
        anchors.left: parent.left
        anchors.verticalCenter: parent.verticalCenter
        anchors.rightMargin: Theme.paddingSmall
        anchors.leftMargin: Theme.paddingSmall

        Label {
            text: index + 1
            anchors.left: parent.left
            horizontalAlignment: Qt.AlignLeft
            color: Theme.secondaryColor
            font.pixelSize: Theme.fontSizeExtraSmall
        }
    }
    Column {
        anchors.right: parent.right
        anchors.verticalCenter: parent.verticalCenter
        anchors.rightMargin: Theme.paddingSmall
        anchors.leftMargin: Theme.paddingSmall

        Label {
            text: modelFromName
            anchors.right: parent.right
            //horizontalAlignment: Qt.AlignLeft
            color: Theme.secondaryColor
            font.pixelSize: Theme.fontSizeExtraSmall
        }

        Label {
            text: modelToName
            //horizontalAlignment: Qt.AlignLeft
            color: Theme.secondaryColor
            font.pixelSize: Theme.fontSizeExtraSmall
        }
    }
}
