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
import Swifter
@testable import TWUITests

final class HTTPDynamicStubsTests: XCTestCase {
    func testStartServer_startAndStop() throws {
        // GIVEN: server is initialised with empty stubs list
        let (fileManager, server) = makeTestObjects()
        let sut = try makeSUT(
            fileManager: fileManager,
            server: server
        )

        // WHEN: server is started
        XCTAssertNoThrow(try sut.startServer())
        XCTAssertTrue(server.startCalled)
        XCTAssertNil(fileManager.contentsData)

        // AND: server is stopped
        sut.stop()

        // THEN: server should be stopped
        XCTAssertTrue(server.stopCalled)
    }

    func testStartServer_startWithStub() throws {
        // GIVEN: server is initialised with 1 stub (DELETE method) in stubs list
        let (fileManager, server) = makeTestObjects()
        fileManager.contentsData = String(#"{"status": "ok"}"#).data(using: .utf8)
        let sut = try makeSUT(
            fileManager: fileManager,
            server: server,
            stubs: [APIStubInfo(statusCode: 200, url: "", jsonFilename: "", method: .DELETE)]
        )

        // WHEN: server is started
        XCTAssertNoThrow(try sut.startServer())
        XCTAssertTrue(server.startCalled)

        // THEN: stub should be successfully registered to server
        XCTAssertTrue(fileManager.fileExistsCalled)
        XCTAssertTrue(fileManager.contentsCalled)
        XCTAssertTrue(server.methodDELETECalled)
    }

    func testStartServer_starAndUpdateStub() throws {
        // GIVEN: server is started with empty stubs list
        let (fileManager, server) = makeTestObjects()
        let sut = try makeSUT(fileManager: fileManager, server: server)
        XCTAssertNoThrow(try sut.startServer())
        XCTAssertFalse(fileManager.fileExistsCalled)
        XCTAssertFalse(fileManager.contentsCalled)
        XCTAssertTrue(server.startCalled)
        XCTAssertFalse(server.methodGETCalled)

        // WHEN: GET stub is updated
        fileManager.contentsData = String(#"{"status": "ok"}"#).data(using: .utf8)
        XCTAssertNoThrow(try sut.update(using: APIStubInfo(statusCode: 10, url: "", jsonFilename: "", method: .GET)))

        // THEN: stub should be successfully registered to server
        XCTAssertTrue(fileManager.fileExistsCalled)
        XCTAssertTrue(fileManager.contentsCalled)
        XCTAssertTrue(server.methodGETCalled)
    }

    private func makeTestObjects() -> (FileManagerSpy, HttpServerSpy) {
        let fileManager = FileManagerSpy()
        let server = HttpServerSpy()
        return (fileManager, server)
    }

    private func makeSUT(
        fileManager: FileManagerSpy,
        server: HttpServerSpy,
        stubs: [APIStubInfo] = [],
        appID: String = "12345",
        port: APIConfiguration.PortType = .fixed(15),
        maxPortRetries: Int = 1
    ) throws -> HTTPDynamicStubs {
        try HTTPDynamicStubs(
            fileManager: fileManager,
            server: server,
            initialStubs: stubs,
            regexModifier: RegexJSONModifier(),
            appID: appID,
            port: port,
            maxPortRetries: maxPortRetries
        )
    }
}

private final class FileManagerSpy: FileManaging {
    enum Error: Swift.Error {
        case failedToCreateDir
    }

    var failToCreateDirectory = false
    func createDirectory(at url: URL, withIntermediateDirectories createIntermediates: Bool, attributes: [FileAttributeKey: Any]?) throws {
        if failToCreateDirectory {
            throw Error.failedToCreateDir
        }
    }

    var fileExistsCalled = false
    var filesDoesExist = true
    func fileExists(atPath path: String) -> Bool {
        fileExistsCalled = true
        return filesDoesExist
    }

    var contentsCalled = false
    var contentsData: Data?
    func contents(atPath path: String) -> Data? {
        contentsCalled = true
        return contentsData
    }
}

private final class HttpServerSpy: HttpServerProtocol {
    var methodDELETECalled = false
    func methodDELETE(path: String, response: ((HttpRequest) -> HttpResponse)?) {
        methodDELETECalled = true
    }

    func methodPOST(path: String, response: ((HttpRequest) -> HttpResponse)?) {

    }

    var methodGETCalled = false
    func methodGET(path: String, response: ((HttpRequest) -> HttpResponse)?) {
        methodGETCalled = true
    }

    func methodPUT(path: String, response: ((HttpRequest) -> HttpResponse)?) {

    }

    var startCalled = false
    func start(_ port: in_port_t, forceIPv4: Bool, priority: DispatchQoS.QoSClass) throws {
        startCalled = true
    }

    var stopCalled = false
    func stop() {
        stopCalled = true
    }
}
