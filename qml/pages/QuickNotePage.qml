import QtQuick 2.0
import Sailfish.Silica 1.0
import io.thp.pyotherside 1.3
import "../components"
import "../components/pullMenus/rows"

Page {
    id: editorPage

    //property string filePath: "~/Documents/harbour-editor-quickNote.txt"
    property string filePath: "/home/nemo/Documents/harbour-editor-quickNote.txt"
    property bool saveFlag: false
    property bool searched: false
    property bool searchRowVisible: false

    Rectangle {
        id:background
        color: bgColor
        anchors.fill: parent
        visible: true

        SilicaFlickable {
            id: view
            anchors.fill: parent

            PullDownMenu {
                MenuLabel {
                    text: qsTr("Quick note")
                }
                MenuLabel {
                    text: qsTr("Text auto-saved in:")
                }
                MenuLabel {
                    text: qsTr("`~/Documents/harbour-editor-quickNote.txt`")
                }
            }

            PageHeader {
                id: header
                height: hotActionsMenu.height
                //visible: headerVisible || searchRowVisible //header visible if EditRow active or SearchRow active

//                EditRow {
//                    id: hotActionsMenu
//                    width: parent.width
//                    height: childrenRect.height
//                    myMenuButtonWidth: sizeBackgroundItem
//                    visible: !searchRowVisible
//                }
                Row {
                    id: hotActionsMenu
                    width: parent.width
                    height: childrenRect.height

                    MenuButton {
                        width: parent.width / 3
                        mySource: "image://theme/icon-m-rotate-left";
                        myText: qsTr("Undo")
                        enabled: myTextArea._editor.canUndo
                        onClicked: {
                            myTextArea._editor.undo()
                        }
                    }

                    MenuButton {
                        width: parent.width / 3
                        mySource: "image://theme/icon-m-rotate-right";
                        myText: qsTr("Redo")
                        enabled: myTextArea._editor.canRedo
                        onClicked: {
                            myTextArea._editor.redo()
                        }
                    }

                    MenuButton {
                        width: parent.width / 3
                        mySource: "../img/tab.svg";
                        myText: qsTr("Tab")
                        onClicked: {
                            var previousCursorPosition = myTextArea.cursorPosition;
                            myTextArea.text = myTextArea.text.slice(0, myTextArea.cursorPosition) + tabType + myTextArea.text.slice(myTextArea.cursorPosition, myTextArea.text.length);
                            myTextArea.cursorPosition = previousCursorPosition + 1;
                        }
                    }
                }

//                // my own component (To Do need some cleaning and optimisation)
//                SearchRow {
//                    width: parent.width
//                    height: childrenRect.height
//                    visible: searchRowVisible
//                }

            }

            SilicaFlickable {
                id: editorView
                anchors.fill: parent
                anchors.topMargin: header.visible ? header.height : 0 // для сдвига при отключении quick actions menu
                contentHeight: myTextArea.height
                clip: true

                TextArea {
                    id: myTextArea
                    width: parent.width
                    font.family: fontType
                    font.pixelSize: fontSize
                    background: null
                    selectionMode: TextEdit.SelectCharacters
                    focus: true

                    onTextChanged: {
                        console.log("filePath = " + filePath, fontSize, font.family);
                        saveFlag = true; //?

                        //Autosave
                        if (filePath!=="" && myTextArea.text !== "") {
                            //py.call('editFile.autosave', [filePath, myTextArea.text], function(result) {});
                            py.call('editFile.savings', [filePath,myTextArea.text], function() {});
                        }
                    }

                }
                VerticalScrollDecorator { flickable: editorView }
            }


        }
    }

    onStatusChanged: {
        if (status !== PageStatus.Active) {
            return
        } else {
            console.log(filePath)
            if (filePath!=="") {
                py.call('editFile.openings', [filePath], function(result) {
                    myTextArea.text = result;
                });
            }
        }
    }

    Python {
        id: py

        Component.onCompleted: {
            addImportPath(Qt.resolvedUrl('../.'));
            importModule('editFile', function () {});
        }
        onError: {
            // when an exception is raised, this error handler will be called
            console.log('python error: ' + traceback);
        }
        onReceived: console.log('Unhandled event: ' + data)
    }
}