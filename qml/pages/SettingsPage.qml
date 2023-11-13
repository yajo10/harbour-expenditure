import QtQuick 2.6
import Sailfish.Silica 1.0
import Sailfish.Pickers 1.0
import FileIO 1.0
import Nemo.Notifications 1.0



Dialog {
    id: pageSettings

    property int showMaintenanceButtonsCounter : 0
    property string notificationString : ""
    //property int oldProjectIndex

    allowedOrientations: Orientation.Portrait
    backNavigation: (bannerAddProject.opacity < 1) // && (updateEvenWhenCanceled === false)
    forwardNavigation: (bannerAddProject.opacity < 1)
    onOpened: {
        //console.log("old project index = " + activeProjectID_unixtime)
        showMaintenanceButtonsCounter = 0
        updateEvenWhenCanceled = false
        idComboboxProject.currentIndex = 0
        for (var j = 0; j < listModel_allProjects.count ; j++) {
            if (Number(listModel_allProjects.get(j).project_id_timestamp) === Number(storageItem.getSettings("activeProjectID_unixtime", 0))) {
                idComboboxProject.currentIndex = j
            }
        }
        idComboboxSortingExpenses.currentIndex = Number(storageItem.getSettings("sortOrderExpensesIndex", 0)) // 0=descending, 1=ascending
        idComboboxExchangeRateMode.currentIndex = Number(storageItem.getSettings("exchangeRateModeIndex", 0)) // 0=collective, 1=individual
        idComboboxShowInteractiveScrollbar.currentIndex = Number(storageItem.getSettings("interativeScrollbarMode", 0)) //0=standard, 1=interactive
        notificationString = ""
    }
    onDone: {
        if (result == DialogResult.Accepted) {
            writeDB_Settings()
        }
    }
    onRejected: {
        // in certain cases reload list even on cancel: if project was cleared, delted or created
        // then use previous activeProjectID_unixtime instead of the new one from dropdown menu
        if (updateEvenWhenCanceled === true) {
            loadActiveProjectInfos_FromDB(activeProjectID_unixtime)
            updateEvenWhenCanceled = false
        }
    }

    BannerAddProject {
        id: bannerAddProject
    }
    Banner2ButtonsChoice {
        id: banner2ButtonsChoice
    }
    Notification {
        id: notificationBackup
        expireTimeout: 4000
        //appName: qsTr("Expenditure")
        //icon: "image://theme/icon-lock-warning"

        function showSmall(message) {
            replacesId = 0
            previewSummary = ""
            previewBody = message
            publish()
        }
        function showBig(title, message) {
            replacesId = 0
            previewSummary = title
            previewBody = message
            publish()
        }
    }
    RemorsePopup {
        z: 10
        id: remorse_clearExchangeRatesDB
    }
    RemorsePopup {
        z: 10
        id: remorse_restoreBackupFile
    }
    ListModel {
        id: listModel_tempProjectExpenses
    }
    Component {
        id: idFolderPickerPage

        FolderPickerPage {
            dialogTitle: qsTr("Backup to")
            onSelectedPathChanged: {
                backupProjectExpenses( selectedPath )
            }
        }
    }
    Component {
       id: idFilePickerPage

       FilePickerPage {
           title: qsTr("Restore backup file")
           nameFilters: [ '*.csv' ]
           onSelectedContentPropertiesChanged: {
               var selectedPath = selectedContentProperties.filePath
               idTextFileBackup.source = selectedPath
               var tempProjectIndex_File = ((idTextFileBackup.text).split("\n"))[0]
               var tempProjectIndex = listModel_allProjects.get(idComboboxProject.currentIndex).project_id_timestamp
               var headlineText = qsTr("Restore backup - choose action")
               var otherText = qsTr("Replace deletes all former project-expenses and uses those from backup-file instead.") + " "
                            + qsTr("Merge keeps former project-expenses and adds those from backup-file which are not yet on the list.")
               if (parseInt(tempProjectIndex) !== parseInt(tempProjectIndex_File)) {
                   var detailText = qsTr("File info: This backup was created by a different project.")
               } else {
                   detailText = qsTr("File info: This backup was created by the original project.")
               }
               var choiceText_1 = qsTr("Replace")
               var choiceText_2 = qsTr("Merge")
               banner2ButtonsChoice.notify( Theme.rgba(Theme.highlightDimmerColor, 1), Theme.itemSizeLarge, headlineText, detailText, otherText, choiceText_1, choiceText_2, selectedPath )
           }
       }
    }
    TextFileIO {
        id: idTextFileBackup
    }



    SilicaFlickable{
        anchors.fill: parent
        contentHeight: column.height // tell overall height

        Column {
            id: column
            width: pageSettings.width

            DialogHeader {
                //title: qsTr("Settings")
            }
            Row {
                width: parent.width
                bottomPadding: Theme.paddingLarge

                Label {
                    id: idLabelSettingsHeader
                    width: parent.width / 6 * 5
                    leftPadding: Theme.paddingLarge
                    font.pixelSize: Theme.fontSizeExtraLarge
                    color: Theme.highlightColor
                    text: qsTr("Settings")

                    MouseArea {
                        anchors.fill: parent
                        onClicked: showMaintenanceButtonsCounter = showMaintenanceButtonsCounter + 1
                    }
                }
                IconButton {
                    width: parent.width / 6
                    anchors.verticalCenter: idLabelSettingsHeader.verticalCenter
                    icon.color: Theme.highlightColor
                    icon.scale: 1.1
                    icon.source: "image://theme/icon-m-about?"
                    onClicked: {
                        pageStack.animatorPush(Qt.resolvedUrl("AboutPage.qml"), {})
                    }
                }
            }
            Row {
                width: parent.width

                ComboBox {
                    id: idComboboxProject
                    width: (listModel_allProjects.count === 0) ? (parent.width / 6*5) : (parent.width / 6*4)
                    label: qsTr("Project")
                    menu: ContextMenu {

                        Repeater {
                            enabled: listModel_allProjects.count > 0
                            model: listModel_allProjects

                            MenuItem {
                                text: project_name
                            }
                        }
                    }

                    MouseArea {
                        enabled: listModel_allProjects.count === 0
                        anchors.fill: parent
                        preventStealing: true
                        onClicked: bannerAddProject.notify( Theme.rgba(Theme.highlightDimmerColor, 1), Theme.itemSizeLarge, "new", idComboboxProject.currentIndex )
                    }
                }
                IconButton {
                    visible: listModel_allProjects.count > 0
                    width: parent.width / 6
                    icon.source:  "image://theme/icon-m-edit?"
                    onClicked: {
                        bannerAddProject.notify( Theme.rgba(Theme.highlightDimmerColor, 1), Theme.itemSizeLarge, "edit", idComboboxProject.currentIndex )
                    }
                }
                IconButton {
                    width: parent.width / 6
                    icon.source:  "image://theme/icon-m-add?"
                    onClicked: {
                        bannerAddProject.notify( Theme.rgba(Theme.highlightDimmerColor, 1), Theme.itemSizeLarge, "new", idComboboxProject.currentIndex )
                    }
                }
            }
            ComboBox {
                id: idComboboxSortingExpenses
                width: parent.width
                label: qsTr("Sorting")

                menu: ContextMenu {
                    MenuItem {
                        text: qsTr("descending")
                    }
                    MenuItem {
                        text: qsTr("ascending")
                    }
                }
            }
            ComboBox {
                id: idComboboxExchangeRateMode
                width: parent.width
                label: qsTr("Exchange rate")
                menu: ContextMenu {
                    MenuItem {
                        text: qsTr("per currency (constant)")
                    }
                    MenuItem {
                        text: qsTr("per transaction (dates)")
                    }
                }
            }
            ComboBox {
                id: idComboboxShowInteractiveScrollbar
                width: parent.width
                label: qsTr("Scrollbar")
                menu: ContextMenu {
                    MenuItem {
                        text: qsTr("normal")
                    }
                    MenuItem {
                        text: qsTr("interactive (beta)")
                    }
                }
            }
            Column {
                visible: showMaintenanceButtonsCounter > 9
                width: parent.width
                topPadding: Theme.paddingLarge * 3
                spacing: Theme.paddingLarge

                Label {
                    width: parent.width
                    wrapMode: Text.WordWrap
                    horizontalAlignment: Text.AlignHCenter
                    color: Theme.errorColor
                    text: qsTr("Database cleanup - requires restart:")
                    leftPadding: Theme.paddingLarge + Theme.paddingSmall
                    rightPadding: leftPadding
                }
                Button {
                    text: qsTr("settings")
                    anchors.horizontalCenter: parent.horizontalCenter
                    onClicked: {
                        remorse_clearExchangeRatesDB.execute(qsTr("Delete stored settings?"), function() {
                            storageItem.removeFullTable( "settings_table" )
                        })
                    }
                }
                Button {
                    text: qsTr("exchange rates")
                    anchors.horizontalCenter: parent.horizontalCenter
                    onClicked: {
                        remorse_clearExchangeRatesDB.execute(qsTr("Delete stored exchange rates?"), function() {
                            storageItem.removeFullTable( "exchange_rates_table" )
                        })
                    }
                }
                Button {
                    text: qsTr("projects")
                    anchors.horizontalCenter: parent.horizontalCenter
                    onClicked: {
                        remorse_clearExchangeRatesDB.execute(qsTr("Delete stored projects?"), function() {
                            // remove all individual project expense tables
                            for (var j = 0; j < listModel_allProjects.count ; j++) {
                               var tempTablename = "table_" + listModel_allProjects.get(j).project_id_timestamp
                               storageItem.removeFullTable(tempTablename)
                            }
                            // remove all projects overview table
                            storageItem.removeFullTable( "projects_table" )
                            // set latest setting_id to zero
                            activeProjectID_unixtime = 0
                            storageItem.setSettings("activeProjectID_unixtime", activeProjectID_unixtime)
                            // update front page
                            updateEvenWhenCanceled = true
                        })
                    }
                }
            }
            Item {
                width: parent.width
                height: Theme.paddingLarge
            }
        }
    }



    // ******************************************** important functions ******************************************** //

    function writeDB_Settings() {
        storageItem.setSettings("sortOrderExpensesIndex", idComboboxSortingExpenses.currentIndex)
        sortOrderExpenses = idComboboxSortingExpenses.currentIndex
        listModel_activeProjectExpenses.quick_sort()

        storageItem.setSettings("exchangeRateModeIndex", idComboboxExchangeRateMode.currentIndex)
        exchangeRateMode = idComboboxExchangeRateMode.currentIndex

        storageItem.setSettings("interativeScrollbarMode", idComboboxShowInteractiveScrollbar.currentIndex)
        interativeScrollbarMode = idComboboxShowInteractiveScrollbar.currentIndex

        if (listModel_allProjects.count > 0) { // only works if a project is actually created and loaded, otherwise this gets triggered directly in BannerAddProject.qml
            storageItem.setSettings("activeProjectID_unixtime", Number(listModel_allProjects.get(idComboboxProject.currentIndex).project_id_timestamp))
            activeProjectID_unixtime = Number(listModel_allProjects.get(idComboboxProject.currentIndex).project_id_timestamp)
            loadActiveProjectInfos_FromDB(Number(listModel_allProjects.get(idComboboxProject.currentIndex).project_id_timestamp))
        }

        // ToDo: update base currency, if it was changed
    }

    function backupProjectExpenses(selectedPath) {
        listModel_tempProjectExpenses.clear()
        var tempProjectIndex = listModel_allProjects.get(idComboboxProject.currentIndex).project_id_timestamp
        var backupFileName = encodeURIComponent(listModel_allProjects.get(idComboboxProject.currentIndex).project_name) + "_backup.csv" //replaces misleading special characters with %-symbols
        var backupFilePath = selectedPath + "/" + backupFileName //StandardPaths.documents

        // check if project exists
        var currentProjectEntries = storageItem.getAllExpenses(listModel_allProjects.get(idComboboxProject.currentIndex).project_id_timestamp, "none")
        if (currentProjectEntries !== "none") {
            // generate temp project expenses list from chosen list
            for (var i = 0; i < currentProjectEntries.length ; i++) {
                listModel_tempProjectExpenses.append({
                    id_unixtime_created : Number(currentProjectEntries[i][0]).toFixed(0),
                    date_time : Number(currentProjectEntries[i][1]).toFixed(0),
                    expense_name : currentProjectEntries[i][2],
                    expense_sum : Number(currentProjectEntries[i][3]).toFixed(2),
                    expense_currency : currentProjectEntries[i][4],
                    expense_info : currentProjectEntries[i][5],
                    expense_payer : currentProjectEntries[i][6],
                    expense_members : currentProjectEntries[i][7],
                })
            }
            // create string from these temp info
            var toBackupString = tempProjectIndex + "\n"
                        + listModel_allProjects.get(idComboboxProject.currentIndex).project_name + "\n"
                        + "id_unixtime_created;*;date_time;*;expense_payer;*;expense_name;*;expense_sum;*;expense_currency;*;expense_members;*;expense_info" + "\n"
            for (var j = 0; j < listModel_tempProjectExpenses.count; j++) {
                toBackupString += listModel_tempProjectExpenses.get(j).id_unixtime_created
                        + ";*;" + listModel_tempProjectExpenses.get(j).date_time
                        + ";*;" + listModel_tempProjectExpenses.get(j).expense_payer
                        + ";*;" + listModel_tempProjectExpenses.get(j).expense_name
                        + ";*;" + listModel_tempProjectExpenses.get(j).expense_sum
                        + ";*;" + listModel_tempProjectExpenses.get(j).expense_currency
                        + ";*;" + listModel_tempProjectExpenses.get(j).expense_members
                        + ";*;" + listModel_tempProjectExpenses.get(j).expense_info
                        + "\n"
            }
            //console.log(toBackupString)

            // store in file and give notification
            idTextFileBackup.source = backupFilePath
            idTextFileBackup.text = toBackupString
            notificationString = backupFilePath

            //show notification somehow on top
            var headlineText = qsTr("Backup successful")
            var detailText = qsTr("File saved to:") + backupFilePath
            var triggerHiding = false
            notificationBackup.showBig(headlineText, detailText)
        }
    }

    function restoreProjectExpenses(selectedPath, selectedAction) {
        idTextFileBackup.source = selectedPath
        var loadTextString = (idTextFileBackup.text)
        var pos = loadTextString.lastIndexOf("\n") // ToDo: remove last occurance of "\n"
        var loadTextLinesArray = (loadTextString.substring(0,pos) + loadTextString.substring(pos+1)).split("\n")
        var tempStringExistingId_unixtime = ""
        //var tempProjectIndex = listModel_allProjects.get(idComboboxProject.currentIndex).project_id_timestamp

        // plausibility check on lines 0 to 2
        if (loadTextLinesArray[2] === "id_unixtime_created;*;date_time;*;expense_payer;*;expense_name;*;expense_sum;*;expense_currency;*;expense_members;*;expense_info") {
            var tempProjectIndex = listModel_allProjects.get(idComboboxProject.currentIndex).project_id_timestamp

            // if REPLACE: delete old entries in project-specific expense table in database, otherwise just MERGE
            if (selectedAction === "replace") {
                storageItem.deleteAllExpenses(tempProjectIndex)
            } else { //"merge"
                // generate expenses list for this project
                var currentProjectEntries = storageItem.getAllExpenses( activeProjectID_unixtime, "none")
                if (currentProjectEntries !== "none") {
                    for (var i = 0; i < currentProjectEntries.length ; i++) {
                        tempStringExistingId_unixtime += (currentProjectEntries[i][0]).toString() + ";"
                    }
                }
                //console.log(tempStringExistingId_unixtime)
            }

            // fill with backup entries
            for (i = 3; i < loadTextLinesArray.length; i++) {
                var tempExpenseLineArray = (loadTextLinesArray[i]).split(";*;")
                var project_name_table = tempProjectIndex
                var id_unixtime_created = tempExpenseLineArray[0]
                var date_time = tempExpenseLineArray[1]
                var expense_payer = tempExpenseLineArray[2]
                var expense_name = tempExpenseLineArray[3]
                var expense_sum = tempExpenseLineArray[4]
                var expense_currency = tempExpenseLineArray[5]
                var expense_members = tempExpenseLineArray[6]
                var expense_info = tempExpenseLineArray[7]

                if (selectedAction === "replace") {
                    storageItem.setExpense(project_name_table, id_unixtime_created.toString(), date_time.toString(), expense_name, expense_sum, expense_currency, expense_info, expense_payer, expense_members)
                    //console.log("entering DB -> " + tempExpenseLineArray)
                } else {
                    // check for double entries, only add if not existent
                    if (tempStringExistingId_unixtime.indexOf(id_unixtime_created.toString()) === -1) {
                        storageItem.setExpense(project_name_table, id_unixtime_created.toString(), date_time.toString(), expense_name, expense_sum, expense_currency, expense_info, expense_payer, expense_members)
                        //console.log("entering DB -> " + tempExpenseLineArray)
                    }
                }
            }

            //show notification somehow on top
            var headlineText = qsTr("Backup successfully restored.")
            if (selectedAction === "replace") {
                var detailText = qsTr("Project expenses have been overwritten by backup-file expenses.")
            } else {
                detailText = qsTr("Project expenses have been merged with backup-file expenses.")
            }
            var triggerHiding = false
            notificationBackup.showBig(headlineText, detailText)

            // set this flag when the current project gets merged or replaced with a backup
            if ( Number(tempProjectIndex) === Number(activeProjectID_unixtime) ) {
                updateEvenWhenCanceled = true
            }
        } else {
            //show notification somehow on top
            headlineText = qsTr("Validity check failed.")
            detailText = qsTr("This backup file does not seem to be created by Expenditure:") + " " + backupFilePath
            triggerHiding = false
            notificationBackup.showBig(headlineText, detailText)
        }
    }
}
