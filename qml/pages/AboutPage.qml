import QtQuick 2.6
import Sailfish.Silica 1.0


Page {
    id: page
    allowedOrientations: Orientation.Portrait //All

    SilicaFlickable {
        id: listView
        anchors.fill: parent
        contentHeight: idColumn.height  // Tell SilicaFlickable the height of its content.

        VerticalScrollDecorator {}

        Column {
            id: idColumn
            x: Theme.paddingLarge
            width: parent.width - 2*x

            Label {
                width: parent.width
                height: Theme.itemSizeLarge
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
                font.pixelSize: Theme.fontSizeLarge
                color: Theme.primaryColor
                text: qsTr("Expenditure")
            }
            Item {
                width: parent.width
                height: Theme.paddingLarge
            }
            Image {
                width: parent.width
                height: Theme.itemSizeHuge
                source: "../cover/harbour-expenditure.png"
                sourceSize.width: height
                sourceSize.height: height
                fillMode: Image.PreserveAspectFit
            }
            Item {
                width: parent.width
                height: Theme.paddingLarge * 2.5
            }
            Label {
                x: Theme.paddingMedium
                width: parent.width - 2*x
                horizontalAlignment: Text.AlignHCenter
                font.pixelSize: Theme.fontSizeExtraSmall
                wrapMode: Text.Wrap
                text: qsTr("Expenditure is a tool to track and split bills, project or trip expenses in multiple currencies among groups.")

            }
            Label {
                x: Theme.paddingMedium
                width: parent.width - 2*x
                horizontalAlignment: Text.AlignHCenter
                font.pixelSize: Theme.fontSizeExtraSmall
                wrapMode: Text.Wrap
                text: qsTr("Thanksgiving, feedback and support is always welcome.")
                bottomPadding: Theme.paddingLarge * 2
            }
            Label {
                x: Theme.paddingMedium
                width: parent.width - 2*x
                horizontalAlignment: Text.AlignHCenter
                font.pixelSize: Theme.fontSizeExtraSmall
                wrapMode: Text.Wrap
                text: qsTr("Troubleshooting:")
                    + "\n" + qsTr("In case of any database error tap 10x on the word 'Settings' for cleanup options.")
                bottomPadding: Theme.paddingLarge * 2
            }
            Label {
                width: parent.width
                horizontalAlignment: Text.AlignHCenter
                font.pixelSize: Theme.fontSizeExtraSmall
                color: Theme.secondaryColor
                wrapMode: Text.Wrap
                text: qsTr("Contact:")
                + "\n" + qsTr("Copyright © 2022 Tobias Planitzer")
                + "\n" + ("tp.labs@protonmail.com")
                + "\n" + qsTr("License: GPL v3")
            }
            Item {
                width: parent.width
                height: Theme.paddingLarge * 2.5
            }
        }
    } // end Silica Flickable
}
