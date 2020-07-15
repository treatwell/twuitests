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
    @available(*, deprecated, message: "Use throwable `start(with:initiationClosure:)` instead")
    func start(using configuration: Configuration, initiationClosure: ((UITestApplication) -> Void)?)
    func start(with configuration: Configuration, initiationClosure: ((UITestApplication) -> Void)?) throws
}

extension XCUIApplicationStarter {
    @available(*, deprecated, message: "Use throwable `start(with:)` instead")
    func start(using configuration: Configuration) {
        start(using: configuration, initiationClosure: nil)
    }
    func start(with configuration: Configuration) throws {
        try start(with: configuration, initiationClosure: nil)
    }
}

public final class UITestApplication: XCUIApplication {
    private var server: HTTPDynamicStubing?
    private var replacementQueue: [ReplacementJob] = []

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

    public func replaceValues(withOldToNewMap oldToNewMap: [String: String], in stub: APIStubInfo) {
        replaceOrQueue(
            job: ReplacementJob(
                modification: .replaceValues(oldToNewMap),
                stub: stub
            )
        )
    }

    public func replaceValues(of items: [String: String], in stub: APIStubInfo) {
        replaceOrQueue(
            job: ReplacementJob(
                modification: .replaceKeyValues(items),
                stub: stub
            )
        )
    }

    fileprivate func replaceOrQueue(job: ReplacementJob) {
        guard let server = server else {
            replacementQueue.append(job)
            return
        }
        server.replace(with: job)
    }
}

extension UITestApplication: XCUIApplicationStarter {
    @available(*, deprecated, message: "Use throwable `start(with:initiationClosure:)` instead")
    public func start(using configuration: Configuration, initiationClosure: ((UITestApplication) -> Void)?) {
        guard let port = try? serverStart(with: configuration.apiConfiguration, initiationClosure: initiationClosure) else {
            preconditionFailure("Failed to start server")
        }
        configuration.update(port: port)
        set(configuration: configuration).launch()
    }

    // UI tests must launch the application that they test.
    public func start(with configuration: Configuration, initiationClosure: ((UITestApplication) -> Void)?) throws {
        let port = try serverStart(with: configuration.apiConfiguration, initiationClosure: initiationClosure)
        configuration.update(port: port)
        set(configuration: configuration).launch()
    }

    private func serverStart(
        with apiConfiguration: APIConfiguration,
        initiationClosure: ((UITestApplication) -> Void)? = nil
    ) throws -> UInt16 {
        let server = try HTTPDynamicStubs(appID: apiConfiguration.appID, port: apiConfiguration.port)
        let port = try server.startServer()
        try apiConfiguration.apiStubs.forEach {
            try server.update(using: $0)
        }

        replacementQueue.forEach(replaceOrQueue)
        self.server = server

        // Call initiation closure if it's not nil
        if let initiation = initiationClosure {
            initiation(self)
        }

        return port
    }

    private func set(configuration: Configuration) -> XCUIApplication {
        launchEnvironment.merge((configuration.dictionary), uniquingKeysWith: { (_, new) in new })
        return self
    }
}
