#import "SnapshotHelper.js"

var target = UIATarget.localTarget();
var app = target.frontMostApp();
var window = app.mainWindow();

UIATarget.onAlert = function onAlert(alert) {
    var title = alert.name();
    UIALogger.logWarning("Alert with title '" + title + "' encountered.");
    // return false to use the default handler
    return true;
}

target.delay(3)

var inputField = window.textFields()[0];
inputField.setValue("100");
target.delay(1)
captureLocalizedScreenshot("01Main-View");

var settingsButton = window.navigationBar().buttons()[2];
settingsButton.tap()
target.delay(1)
captureLocalizedScreenshot("03Settings");

window.buttons()[1].tap()
target.delay(1)
captureLocalizedScreenshot("04Country-Picker");

window.navigationBar().buttons()[1].tap();
target.delay(1)
window.buttons()[0].tap()
