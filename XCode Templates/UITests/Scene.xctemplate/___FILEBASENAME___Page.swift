import XCTest
import TWUITests

final class ___VARIABLE_sceneName___Page: UITestBase, Page {
    // Examples
    var someView: XCUIElement {
        return app.otherElements["some_view_id"] // ___VARIABLE_sceneName___AccessibilityIndetifiers.View.some
    }
    var someButton: XCUIElement {
        return app.buttons["some_button_id"] // ___VARIABLE_sceneName___AccessibilityIndetifiers.Button.some
    }
}

// MARK: - Add to Application

extension UITestApplication {
    var ___VARIABLE_propertyName___Page: ___VARIABLE_sceneName___Page {
        return ___VARIABLE_sceneName___Page(app: self)
    }
}
