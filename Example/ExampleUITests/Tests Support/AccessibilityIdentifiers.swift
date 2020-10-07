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

import Foundation

struct Accessibility {
    struct Login {
        static let mainView = "login_screen.main_view"

        struct TextField {
            static let userName = "login_screen.textfield.username"
            static let password = "login_screen.textfield.password"
        }

        struct Button {
            static let login = "login_screen.button.login"
        }

        struct Label {
            static let authStatus = "login_screen.label.auth_status"
        }
    }

    struct Home {
        static let mainView = "home_screen.main_view"

        struct Button {
            static let fetch = "home_screen.button.fetch"
        }
    }
}
