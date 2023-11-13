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

            SectionHeader{
                text: qsTr("About")
            }

            Image {
                id: logo
                source: "/usr/share/icons/hicolor/172x172/apps/harbour-expenditure.png"
                smooth: true
                height: parent.width / 2
                width: parent.width / 2
                anchors.horizontalCenter: parent.horizontalCenter
            }
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
            SectionHeader{
                text: qsTr("Troubleshooting")
            }

            Label {
                x: Theme.paddingMedium
                width: parent.width - 2*x
                horizontalAlignment: Text.AlignHCenter
                font.pixelSize: Theme.fontSizeExtraSmall
                wrapMode: Text.Wrap
                text: qsTr("In case of any database error tap 10x on the word 'Settings' for cleanup options.")
                bottomPadding: Theme.paddingLarge * 2
            }
            SectionHeader {
                text: qsTr("Source code")
            }

            Label {
                x: Theme.paddingMedium
                width: parent.width - 2*x
                horizontalAlignment: Text.AlignHCenter
                font.pixelSize: Theme.fontSizeExtraSmall
                wrapMode: Text.Wrap
                text: qsTr("Thanksgiving, feedback and support is always welcome.")
                bottomPadding: Theme.paddingLarge * 2
                onLinkActivated: Qt.openUrlExternally(link)
            }
            BackgroundItem{
                            width: parent.width
                            height: Theme.itemSizeMedium
                            Row{
                                width:parent.width - 2 * x
                                height: parent.height
                                x:Theme.horizontalPageMargin
                                spacing:Theme.paddingLarge

                                Label{
                                    width: parent.width - parent.spacing
                                    anchors.verticalCenter: parent.verticalCenter
                                    wrapMode: Text.WrapAnywhere
                                    font.pixelSize: Theme.fontSizeSmall

                                    text: "https://github.com/yajo10/harbour-expenditure"
                                    color: parent.parent.pressed ? Theme.highlightColor : Theme.primaryColor

                                }
                            }
                            onClicked: Qt.openUrlExternally("https://github.com/yajo10/harbour-expenditure")
                        }

            Label {
                width: parent.width
                horizontalAlignment: Text.AlignHCenter
                font.pixelSize: Theme.fontSizeExtraSmall
                color: Theme.secondaryColor
                wrapMode: Text.Wrap
                text: qsTr("First author:")
                + "\n" + qsTr("Tobias Planitzer")
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
