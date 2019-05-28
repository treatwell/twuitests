//  Copyright 2019 Hotspring Ventures Ltd.
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//  http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.

import TWUITests
import XCTest

final class LoginStep: UITestBase, Step {
    lazy var loginPage = LoginPage(app: app)
    
    func typeText(_ text: String, in textField: XCUIElement) -> LoginStep {
        textField.clearAndEnterText(text)
        return self
    }
    
    func tapButtonLogin() -> UITestApplication {
        loginPage.buttonLogin.tap()
        return app
    }
}

// MARK: - Combined Actions

extension LoginStep {
    func providesEmptyCredentials() -> UITestApplication {
        return providesUsername("", password: "")
    }
    
    func providesUsername(_ userName: String, password: String) -> UITestApplication {
        return typeText(userName, in: app.loginPage.textFieldUsername)
            .typeText(password, in: app.loginPage.textFieldPassword)
            .tapButtonLogin()
    }
}

// MARK: - Validation

extension LoginStep {
    func loginScreenIsVisible() {
        loginPage.mainView.existsAfterDelay()
    }

    func errorAlertIsVisible() {
        XCTAssertEqual(app.alerts.count, 1, "Error alert is not visible")
    }
}

// MARK: - Add to Application

extension UITestApplication {
    var loginStep: LoginStep {
        return LoginStep(app: self)
    }
}
