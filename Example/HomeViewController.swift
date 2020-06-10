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

class HomeViewController: UIViewController {
    @IBOutlet weak var fetchButton: UIButton!
    @IBAction func fetchAction(_ sender: Any) {
        APIProvider.fetchAuthenticationStatus { data in
            if
                let json = try? JSONSerialization.jsonObject(with: data!, options: []) as? [String: Any],
                let result = json["result"] as? String {

                let alert = UIAlertController(title: "Result", message: result, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Close", style: .cancel, handler: nil))
                self.present(alert, animated: true)
            }
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        view.accessibilityIdentifier = Accessibility.Home.mainView
        fetchButton.accessibilityIdentifier = Accessibility.Home.Button.fetch
    }
}
