import XCTest

class PiggyPanicUITests: XCTestCase {

    func testGoalAppearsAfterSaving() {
        let app = XCUIApplication()
        app.launch()

        // Assuming you start on HomeView → navigate to GoalSettingView
        app.buttons["Create New Goal"].tap()

        // Fill out goal form
        let goalNameField = app.textFields["Goal Name"]
        goalNameField.tap()
        goalNameField.typeText("Bali Trip")

        let targetAmountField = app.textFields["Target Amount ($)"]
        targetAmountField.tap()
        targetAmountField.typeText("500")

        let savingPerFrequencyField = app.textFields["Saving Per Weekly"]
        savingPerFrequencyField.tap()
        savingPerFrequencyField.typeText("50")

        app.buttons["Save Goal"].tap()

        // Confirm navigation to MyGoalsView and goal is listed
        let goalCell = app.staticTexts["Bali Trip"]
        XCTAssertTrue(goalCell.exists, "Goal should be listed in My Goals 🐷 page")
    }
}
