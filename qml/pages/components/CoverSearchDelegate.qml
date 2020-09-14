import QtQuick 2.1
import Sailfish.Silica 1.0

Rectangle {
    width: searchView.width
    height: appCover.height / 5
    color: "transparent"
    Rectangle {
        color: (searchView.currentIndex == index ? Theme.highlightColor : Theme.secondaryColor )
        border.color: Theme.primaryColor
        border.width: 1
        opacity: (searchView.currentIndex == index ? 0.5 : 0.2)

        radius: 5
        smooth: true

        height: parent.height
        width: parent.width

        anchors {
            verticalCenter: parent.verticalCenter
        }
    }
    Column {
        anchors.right: parent.right
        anchors.verticalCenter: parent.verticalCenter
        anchors.rightMargin: Theme.paddingSmall
        anchors.leftMargin: Theme.paddingSmall

        Label {
            text: label
            anchors.right: parent.right
            color: Theme.secondaryColor
            font.pixelSize: Theme.fontSizeExtraSmall
        }
    }
}
