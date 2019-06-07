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

protocol XCUIApplicationStarter {
    func start(using configuration: Configuration)
}

public final class UITestApplication: XCUIApplication {
    private var server: HTTPDynamicStubing?

    func setUp() {}

    func tearDown() {
        server?.stop()
    }

    public func serverUpdate(with stubInfo: APIStubInfo) {
        server?.update(with: stubInfo)
    }

    public func replaceValue(of key: String, with value: String, in stub: APIStubInfo) {
        replaceValues(of: [key: value], in: stub)
    }

    public func replaceValues(of items: [String: String], in stub: APIStubInfo) {
        server?.replaceValues(of: items, in: stub)
    }
}

extension UITestApplication: XCUIApplicationStarter {
    // UI tests must launch the application that they test.
    func start(using configuration: Configuration) {
        serverStart(with: configuration.apiConfiguration)
        set(configuration: configuration).launch()
    }

    private func serverStart(with apiConfiguration: APIConfiguration) {
        server = HTTPDynamicStubs(appID: apiConfiguration.appID, port: apiConfiguration.port)
        server?.start()
        apiConfiguration.apiStubs.forEach {
            server?.update(with: $0)
        }
    }

    private func set(configuration: Configuration) -> XCUIApplication {
        launchEnvironment.merge((configuration.dictionary), uniquingKeysWith: { (_, new) in new })
        return self
    }
}
