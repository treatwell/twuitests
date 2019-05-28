import XCTest
import TWUITests

final class ___VARIABLE_sceneName___Step: UITestBase, Step {
    private lazy var ___VARIABLE_propertyName___Page = ___VARIABLE_sceneName___Page(app: app)

    // Examples (steps)
    func tapSomeButton() -> Self {
        ___VARIABLE_propertyName___Page.someButton.tap()
        return self
    }

    func twoFingerTapSomeButtonToGoToNextScreen() -> UITestApplication {
        ___VARIABLE_propertyName___Page.someButton.twoFingerTap()
        return app
    }
}

// MARK: - Combine actions

extension ___VARIABLE_sceneName___Step {
    // Example (combined action)
    func someAction() -> UITestApplication {
        return tapSomeButton()
            .twoFingerTapSomeButtonToGoToNextScreen()
    }
}

// MARK: - Validation

extension ___VARIABLE_sceneName___Step {
    // Example
    func ___VARIABLE_propertyName___PageIsVisible() {
        ___VARIABLE_propertyName___Page.someView.existsAfterDelay()
        ___VARIABLE_propertyName___Page.someButton.existsAfterDelay()
    }
}

// MARK: - Add to Application

extension UITestApplication {
    var ___VARIABLE_propertyName___Step: ___VARIABLE_sceneName___Step {
        return ___VARIABLE_sceneName___Step(app: self)
    }
}
