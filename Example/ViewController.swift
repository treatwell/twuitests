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

import UIKit

class ViewController: UIViewController {
    @IBOutlet weak var statusLabel: UILabel! {
        didSet {
            statusLabel.text = ""
        }
    }
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var loginButton: UIButton!

    @IBAction func loginButtonTapped(_ sender: UIButton) {
        if usernameTextField.text == "hello@domain.com" && passwordTextField.text == "password" {
            performSegue(withIdentifier: "showHomeScreen", sender: self)
        } else {
            let alert = UIAlertController(title: "Ooooop", message: "Wrong username or password", preferredStyle: .alert)

            alert.addAction(UIAlertAction(title: "Try again", style: .default, handler: nil))
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))

            self.present(alert, animated: true)
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        view.accessibilityIdentifier = Accessibility.Login.mainView
        statusLabel.accessibilityIdentifier = Accessibility.Login.Label.authStatus
        usernameTextField.accessibilityIdentifier = Accessibility.Login.TextField.userName
        passwordTextField.accessibilityIdentifier = Accessibility.Login.TextField.password
        loginButton.accessibilityIdentifier = Accessibility.Login.Button.login

        guard ProcessInfo.processInfo.environment[ConfigurationKeys.isUITest] == "true" else {
            return
        }

        // Simple example how to pass login info from UI tests to app
        // If UI Tests are arunning and login info is passed - prefill login fields and tap login button
        if let user = ProcessInfo.processInfo.environment[ConfigurationKeys.isUser], user.components(separatedBy: "::").count == 2 {
            let userComponents = user.components(separatedBy: "::")
            usernameTextField.text = userComponents[0]
            passwordTextField.text = userComponents[1]
            loginButtonTapped(loginButton)
        }

        APIProvider.fetchAuthenticationStatus { [weak self] data in
            guard
                let json = try? JSONSerialization.jsonObject(with: data!, options: []) as? [String: Any],
                let result = json["result"] as? String
            else {
                return
            }

            self?.statusLabel.text = result
        }
    }
}
