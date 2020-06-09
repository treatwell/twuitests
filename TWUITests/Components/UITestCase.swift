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

import XCTest

public protocol ApplicationStarter {
    func start(using configuration: Configuration) -> UITestApplication
    func start(using configuration: Configuration, stub: APIStubInfo?)
    func start(using configuration: Configuration, initiationClosure: ((UITestApplication) -> Void)?) -> UITestApplication
}

open class UITestCase: XCTestCase {
    public var app: UITestApplication!

    override open func setUp() {
        super.setUp()
        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false
        app = UITestApplication()
        app.setUp()
    }

    override open func tearDown() {
        app.tearDown()
        super.tearDown()
    }
}

extension UITestCase: ApplicationStarter {
    @discardableResult
    public func start(using configuration: Configuration) -> UITestApplication {
        app.start(using: configuration)
        return app
    }

    @available(*, deprecated, message: "Use start(using:initiationClosure:) instead")
    public func start(using configuration: Configuration, stub: APIStubInfo? = nil) {
        start(using: configuration) { app in
            if let stub = stub {
                app.serverUpdate(with: stub)
            }
            self.app = app
        }
    }

    /// Start app using specified configuration
    /// - Parameters:
    ///   - configuration: Configuration object
    ///   - initiationClosure: Initiation closure. It is called right after setting up mock server, before app launch.
    ///   Use this param if you need to inject custom mocked API responses on app launch
    /// - Returns: UITestApplication
    @discardableResult
    public func start(using configuration: Configuration, initiationClosure: ((UITestApplication) -> Void)? = nil) -> UITestApplication {
        app.start(using: configuration, initiationClosure: initiationClosure)
        return app
    }
}
