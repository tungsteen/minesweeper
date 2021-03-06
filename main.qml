import QtQuick 2.5
import QtQuick.Window 2.2
import QtQuick.Controls 1.4 as Cntrls
import QtQuick.Layouts 1.1

import "minesweeper.js" as Minesweeper
import "."

Cntrls.ApplicationWindow {
    id: mainWindow
    visible: true
    width: 680
    height: 500
    title: qsTr("Minesweeper")

    property int minesFound: GlobalData.minesFound
    property int flagsSet: GlobalData.flagsSet
    property bool isGameOver: GlobalData.isGameOver
    property string flagsSetText: qsTr("Flags Set: ")
    property string minesExistText: qsTr("Mines Exist: ")

    function openCells(position) {
//        console.log(Minesweeper.mines)
        var cascadeOpenCells = Minesweeper.getCellsToOpen(position)
        for(var i = 0; i < cascadeOpenCells.length; i++) {
            openCell(cascadeOpenCells[i])
        }
    }

    signal openCell(int position)

    function restartGame() {
        if (customDialog.visible) {
            customDialog.state = "default"
            customDialog.visible = false
        }

        // reset minefield
        minesFound = 0
        flagsSet = 0
        Minesweeper.setMines()

        table.columns = Minesweeper.dimension
        table.rows = table.columns
        mineField.model = 0
        mineField.model = Minesweeper.dimension * Minesweeper.dimension

        GlobalData.isGameOver = false
        gameTimer.timestamp = 0
        minesExistLabel.text = minesExistText + Minesweeper.getNumberOfMines()
    }

    onFlagsSetChanged: {
        flagsSetLabel.text = flagsSetText + flagsSet
    }

    onMinesFoundChanged: {
        if(minesFound === Minesweeper.mines.length) {
            gameTimer.stop()
            customDialog.state = "win"
            customDialog.visible = true
        }
    }

    onIsGameOverChanged: {
        if(isGameOver) {
            gameTimer.stop()
            customDialog.state = "gameover"
            customDialog.visible = true
        }
    }

    menuBar: Cntrls.MenuBar {
        Cntrls.Menu {
            title: "Controls"
            Cntrls.MenuItem {
                text: "Restart"
                onTriggered: restartGame()
            }

            Cntrls.MenuItem {
                text: "Pause"
                shortcut: "Space"
                onTriggered: {
                    if((customDialog.state !== "default") &&
                            (customDialog.state !== "pause")) {
                        return
                    }

                    customDialog.state = "pause"
                    customDialog.visible = !customDialog.visible
                    if(customDialog.visible) {
                        gameTimer.stop()
                    } else {
                        gameTimer.start()
                    }

                }
            }

            Cntrls.MenuItem {
                text: "Quit"
                shortcut: "Ctrl+Q"
                onTriggered: { Qt.quit() }
            }
        }

        Cntrls.Menu {
            title: "Tools"

            Cntrls.MenuItem {
                text: "Settings"
                shortcut: "Ctrl+S"
                onTriggered: {
                    settingsDialog.visible = true
                }
            }
        }

    }

    Image {
        id: background
        anchors.fill: parent
        asynchronous: true
        smooth: true
        source: "qrc:/bg.png"
    }

    Grid {
        id: table
        columns: Minesweeper.dimension
        rows: columns
        anchors.centerIn: parent

        Repeater {
            id: mineField
            model: table.rows *  table.columns

            Button {
                id: mineCell
                width: Math.max(16, (Math.min(mainWindow.width, mainWindow.height) / table.columns) - 8)
                height: width
                position: modelData

                onCascadeOpenCells: openCells(position)

                Connections {
                    target: mainWindow
                    onOpenCell: openCell(position)
                }
            }
        }
    }

    statusBar: Cntrls.StatusBar {
        RowLayout {
            anchors.fill: parent
            Timer {
                id: gameTimer
                property int timestamp: 0
                interval: 1000
                running: true
                repeat: true
                triggeredOnStart: true
                onTriggered: {
                    timestamp += 1
                    time.text = qsTr("Time: ") + timestamp + qsTr(" sec.")
                }
            }

            Text {id: time}
            Cntrls.Label {
                id: minesExistLabel
                text: minesExistText + Minesweeper.getNumberOfMines()
            }
            Cntrls.Label {
                id: flagsSetLabel
                text: flagsSetText + "0"
            }
        }
    }

    CustomDialog {
        id: customDialog
        visible: false
        anchors.fill: parent
    }

    SettingsDialog {
        id: settingsDialog
        visible: false
        anchors.fill: parent
    }
}
