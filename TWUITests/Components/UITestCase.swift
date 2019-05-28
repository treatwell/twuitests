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
    
    public func start(using configuration: Configuration, stub: APIStubInfo? = nil) {
        let app = start(using: configuration)
        if let stub = stub {
            app.serverUpdate(with: stub)
        }
        self.app = app
    }
}
