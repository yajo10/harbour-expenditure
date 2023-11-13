import QtQuick 2.6
import Sailfish.Silica 1.0
import Sailfish.Share 1.0 // ToDo: instead of copy to clipboard, send to app

Page {
    id: page
    allowedOrientations: Orientation.All


    // project specific global variables, loaded when activating a new project
    property double activeProjectID_unixtime : Number(storageItem.getSettings("activeProjectID_unixtime", 0))
    property int activeProjectID_listIndex
    property string activeProjectName
    property string activeProjectCurrency : "EUR"


    // program specific global variables
    property int sortOrderExpenses : Number(storageItem.getSettings("sortOrderExpensesIndex", 0)) // 0=descending, 1=ascending
    property int exchangeRateMode : Number(storageItem.getSettings("exchangeRateModeIndex", 0)) // 0=collective, 1=individual
    property int interativeScrollbarMode : Number(storageItem.getSettings("interativeScrollbarMode", 0)) // 0=standard, 1=interactive
    property string recentlyUsedCurrency : storageItem.getSettings("recentlyUsedCurrency", activeProjectCurrency)

    // navigation specific blocking
    property bool updateEvenWhenCanceled : false
    property bool delegateMenuOpen : false


    // autostart
    Component.onCompleted: {
        generateAllProjectsList_FromDB()
        loadActiveProjectInfos_FromDB(activeProjectID_unixtime)
    }



    // other items, components and pages
    ListModel {
        id: listModel_allProjects
    }
    ListModel {
        id: listModel_activeProjectMembers
    }
    ListModel {
        id: listModel_activeProjectExpenses
        property string sortColumnName: "date_time" //"id_unixtime_created"
        function swap(a,b) {
            if (a<b) {
                move(a,b,1);
                move (b-1,a,1);
            }
            else if (a>b) {
                move(b,a,1);
                move (a-1,b,1);
            }
        }
        function partition(begin, end, pivot) {
            var piv=get(pivot)[sortColumnName];
            swap(pivot, end-1);
            var store=begin;
            var ix;
            for(ix=begin; ix<end-1; ++ix) {
                if (sortOrderExpenses === 1){
                    if(get(ix)[sortColumnName] < piv) {
                        swap(store,ix);
                        ++store;
                    }
                } else { // (sortOrderExpenses === 0)
                    if(get(ix)[sortColumnName] > piv) {
                        swap(store,ix);
                        ++store;
                    }
                }
            }
            swap(end-1, store);
            return store;
        }
        function qsort(begin, end) {
            if(end-1>begin) {
                var pivot=begin+Math.floor(Math.random()*(end-begin));

                pivot=partition( begin, end, pivot);

                qsort(begin, pivot);
                qsort(pivot+1, end);
            }
        }
        function quick_sort() {
            qsort(0,count)
        }

        onCountChanged: {
            quick_sort()
        }
    }
    ListModel {
        id: listModel_exchangeRates
    }
    ListModel {
        id: listModel_activeProjectResults
        property string sortColumnName : "expense_sum"
        property string sortOrderResults : "desc" //"asc"
        function swap(a,b) {
            if (a<b) {
                move(a,b,1);
                move (b-1,a,1);
            }
            else if (a>b) {
                move(b,a,1);
                move (a-1,b,1);
            }
        }
        function partition(begin, end, pivot) {
            var piv=get(pivot)[sortColumnName];
            swap(pivot, end-1);
            var store=begin;
            var ix;
            for(ix=begin; ix<end-1; ++ix) {
                if (sortOrderResults === "asc"){
                    if(get(ix)[sortColumnName] < piv) {
                        swap(store,ix);
                        ++store;
                    }
                } else { // (sortOrderResults === "desc")
                    if(get(ix)[sortColumnName] > piv) {
                        swap(store,ix);
                        ++store;
                    }
                }
            }
            swap(end-1, store);
            return store;
        }
        function qsort(begin, end) {
            if(end-1>begin) {
                var pivot=begin+Math.floor(Math.random()*(end-begin));

                pivot=partition( begin, end, pivot);

                qsort(begin, pivot);
                qsort(pivot+1, end);
            }
        }
        function quick_sort(orderDirection) {
            sortOrderResults = orderDirection
            qsort(0,count)
        }
    }
    SettingsPage {
        id: settingsPage
    }
    CalcPage {
        id: calcPage
    }
    BannerAddExpense {
        id: bannerAddExpense
    }
    Component {
        id: datePickerComponent
        DatePickerDialog {}
    }
    Component {
        id: timePickerComponent
        TimePickerDialog {}
    }
    ShareAction {
        id: shareActionText
    }



    // main page, current project
    SilicaListView {
        id: idSilicaListView
        anchors.fill: parent
        header: Row {
            width: (interativeScrollbarMode === 0) ? (parent.width) : ((isPortrait) ? (parent.width) : (parent.width - Theme.paddingLarge*2))
            visible: activeProjectID_unixtime !== 0
            topPadding: Theme.paddingLarge
            bottomPadding: Theme.paddingLarge


            Item {
                id: idLeftSpacer
                width: Theme.paddingSmall +  Theme.paddingMedium
                height: 1
            }
            Column {
                id: idHeaderInfoColumn
                width: parent.width - idLeftSpacer.width
                bottomPadding: Theme.paddingSmall

                Label {
                    x: Theme.paddingMedium
                    width: parent.width - 2*x
                    horizontalAlignment: Text.AlignRight
                    font.pixelSize: Theme.fontSizeLarge
                    color: Theme.highlightColor
                    wrapMode: Text.WordWrap
                    text: qsTr("Expenses")
                }
                Label {
                    x: Theme.paddingMedium
                    width: parent.width - 2*x
                    horizontalAlignment: Text.AlignRight
                    font.pixelSize: Theme.fontSizeSmall
                    color: Theme.highlightColor
                    wrapMode: Text.WordWrap
                    //text: "ID_" + activeProjectID_unixtime + " [" + activeProjectCurrency + "]"
                    text: activeProjectName + " [" + activeProjectCurrency + "]"
                }
            }
        }
        footer: Item {
            width: parent.width
            height: Theme.itemSizeSmall
        }
        spacing: Theme.paddingMedium
        quickScroll: (interativeScrollbarMode === 0) ? (true) : (false)

        VerticalScrollDecorator {
            enabled: (interativeScrollbarMode === 0) ? (true) : (false)
            visible: enabled
        }
        ScrollBar {
            id: idScrollBarDate
            enabled: (interativeScrollbarMode === 0) ? false : true
            labelVisible: true
            topPadding: (isPortrait) ? (Theme.itemSizeLarge + Theme.paddingLarge) : (0)
            bottomPadding: (isPortrait) ? Theme.itemSizeSmall : 0
            labelModelTag: "date_time"
            visible: (interativeScrollbarMode === 0) ? (false) : (idPulldownMenu.active === false) && (delegateMenuOpen === false)
        }
        PullDownMenu {
            id: idPulldownMenu
            quickSelect: true

            MenuItem {
                text: qsTr("Settings")
                onClicked: pageStack.push(settingsPage)
            }
            MenuItem {
                text: qsTr("Calculate")
                enabled: activeProjectID_unixtime !== 0
                onClicked: pageStack.animatorPush(calcPage)
            }
            MenuItem {
                text: qsTr("Add")
                enabled: activeProjectID_unixtime !== 0
                onClicked: bannerAddExpense.notify( Theme.rgba(Theme.highlightDimmerColor, 1), Theme.itemSizeLarge, "new", activeProjectID_unixtime, 0 )
            }
        }
        ViewPlaceholder {
            enabled: activeProjectID_unixtime === 0 // listModel_allProjects.count === 0
            text: qsTr("Create new project.")
            hintText: qsTr("Nothing loaded yet.")
        }

        model: listModel_activeProjectExpenses
        delegate: ListItem {
            id: idListItem
            contentHeight: idListLabelsQML.height
            contentWidth: (interativeScrollbarMode === 0) ? (parent.width) : (parent.width - idScrollBarDate.width)
            //contentWidth: (idSilicaListView.visibleArea.heightRatio < 1.0 && idPulldownMenu.active === false) ? (parent.width - idScrollBarDate.width) : (parent.width)
            menu: ContextMenu {
                id: idContextMenu

                MenuItem {
                    text: qsTr("Edit")
                    onClicked: {
                        bannerAddExpense.notify( Theme.rgba(Theme.highlightDimmerColor, 1), Theme.itemSizeLarge, "edit", activeProjectID_unixtime, id_unixtime_created )
                    }
                }
                MenuItem {
                    text: qsTr("Remove")
                    onClicked: {
                        idRemorseDelete.execute(idListItem, qsTr("Remove entry?"), function() {
                            storageItem.deleteExpense(activeProjectID_unixtime, id_unixtime_created )
                            listModel_activeProjectExpenses.remove(index)
                        } )
                    }
                }
            }
            onMenuOpenChanged: {
                // set variable to disable scrollBar visibility
                if (menuOpen === true) {
                    delegateMenuOpen = true
                } else {
                    delegateMenuOpen = false
                }
            }

            RemorseItem {
                id: idRemorseDelete
            }
            Row {
                width: parent.width

                Rectangle {
                    width: Theme.paddingSmall
                    height: idListLabelsQML.height
                    color: Theme.rgba(Theme.highlightBackgroundColor, 0.4)
                }
                Item {
                    width: Theme.paddingMedium
                    height: 1
                }
                Column {
                    id: idListLabelsQML
                    width: parent.width - Theme.paddingSmall - 2*Theme.paddingMedium

                    Row {
                        width: parent.width

                        Label {
                            width: parent.width/3*2- Theme.paddingLarge/2
                            wrapMode: Text.WordWrap
                            font.pixelSize: Theme.fontSizeSmall
                            text: new Date(Number(date_time)).toLocaleString(Qt.locale(), "ddd dd.MM.yyyy - hh:mm")
                        }
                        Item {
                            width: Theme.paddingLarge
                            height: 1
                        }
                        Label {
                            width: parent.width/3 - Theme.paddingLarge/2
                            wrapMode: Text.WordWrap
                            font.pixelSize: Theme.fontSizeSmall
                            horizontalAlignment: Text.AlignRight
                            text: expense_payer
                        }
                    }
                    Row {
                        width: parent.width

                        Label {
                            width: parent.width/3*2 - Theme.paddingLarge/2
                            wrapMode: Text.WordWrap
                            font.pixelSize: Theme.fontSizeSmall
                            text: expense_name
                        }
                        Item {
                            width: Theme.paddingLarge
                            height: 1
                        }
                        Label {
                            width: parent.width/3 - Theme.paddingLarge/2
                            wrapMode: Text.WordWrap
                            horizontalAlignment: Text.AlignRight
                            font.pixelSize: Theme.fontSizeSmall
                            text: Number(expense_sum).toFixed(2) + " " + expense_currency.toString()
                        }
                    }
                    Label {
                        id: idLabelExpenseInfo
                        visible: idLabelExpenseInfo.text.length > 0
                        width: parent.width
                        wrapMode: Text.WordWrap
                        font.pixelSize: Theme.fontSizeTiny
                        color: Theme.secondaryColor
                        text: expense_info
                    }
                    Label {
                        id: idLabelBeneficiaries
                        width: parent.width
                        wrapMode: Text.WordWrap
                        font.pixelSize: Theme.fontSizeTiny
                        color: Theme.secondaryColor
                        text: qsTr("group:")  + " " + expense_members.split(" ||| ").join(", ")
                    }
                    Item {
                        width: parent.width
                        height: Theme.paddingSmall
                    }
                }
            }
        }
    } // end SilicaListView




    function generateAllProjectsList_FromDB() {
        listModel_allProjects.clear()
        var allProjectsOverview = storageItem.getAllProjects("none")
        //console.log(allProjectsOverview)
        if (allProjectsOverview !== "none") {
            for (var i = 0; i < allProjectsOverview.length ; i++) {

                listModel_allProjects.append({
                    project_id_timestamp : Number(allProjectsOverview[i][0]),
                    project_name : allProjectsOverview[i][1],
                    project_members : allProjectsOverview[i][2],
                    project_recent_payer_boolarray : allProjectsOverview[i][3],
                    project_recent_beneficiaries_boolarray : allProjectsOverview[i][4],
                    project_base_currency : allProjectsOverview[i][5],
                })
            }
        }
    }
    function loadActiveProjectInfos_FromDB(activeProjectID_unixtime) {
        //console.log( "loading project: " + Number(activeProjectID_unixtime) )
        listModel_activeProjectMembers.clear()
        listModel_activeProjectExpenses.clear()
        for (var j = 0; j < listModel_allProjects.count ; j++) {
            //console.log("in listmodel: " + Number(listModel_allProjects.get(j).project_id_timestamp) )
            // only use active project infos
            if ( Number(listModel_allProjects.get(j).project_id_timestamp) === Number(activeProjectID_unixtime) ) {
                // find active project name and currency
                activeProjectName = listModel_allProjects.get(j).project_name
                activeProjectID_listIndex = j
                activeProjectCurrency = listModel_allProjects.get(j).project_base_currency

                // generate active project members list
                var activeProjectMembersArray = (listModel_allProjects.get(j).project_members).split(" ||| ")
                var activeProjectRecentPayerBoolArray = (listModel_allProjects.get(j).project_recent_payer_boolarray).split(" ||| ")
                var activeProjectRecentBeneficiariesBoolArray = (listModel_allProjects.get(j).project_recent_beneficiaries_boolarray).split(" ||| ")
                for (var i = 0; i < activeProjectMembersArray.length ; i++) {
                    listModel_activeProjectMembers.append({
                        member_name : activeProjectMembersArray[i],
                        member_isBeneficiary : activeProjectRecentBeneficiariesBoolArray[i],
                        member_isPayer : activeProjectRecentPayerBoolArray[i],
                    })
                }

                // generate active project expenses list
                var currentProjectEntries = storageItem.getAllExpenses( activeProjectID_unixtime, "none")
                if (currentProjectEntries !== "none") {
                    for (i = 0; i < currentProjectEntries.length ; i++) {
                        listModel_activeProjectExpenses.append({
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
                }
            }
        }
    }

}
