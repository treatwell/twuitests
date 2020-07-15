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
import Swifter

protocol HTTPDynamicStubing {
    func update(with stubInfo: APIStubInfo)
    @available(*, deprecated, message: "Use throwable `startServer()` instead")
    func start() -> UInt16
    func startServer() throws -> UInt16
    func stop()
    func replace(with: ReplacementJob)
}

final class HTTPDynamicStubs: HTTPDynamicStubing {
    enum Error: Swift.Error {
        case fileDoesNotExist(String)
        case dataDoesNotExist(String)
        case jsonDecode(String)
        case cantGetSimulatorSharedDir
    }
    private let fileManager: FileManaging
    private let server: HttpServerProtocol
    private let appID: String
    private let regexModifier: RegexJSONModifier
    private var portSettings: PortSettings

    init(
        fileManager: FileManaging = FileManager.default,
        server: HttpServerProtocol = HttpServer(),
        initialStubs: [APIStubInfo] = HTTPDynamicStubsList().initialStubs,
        regexModifier: RegexJSONModifier = RegexJSONModifier(),
        appID: String,
        port: APIConfiguration.PortType,
        maxPortRetries: Int = 5
    ) throws {
        self.fileManager = fileManager
        self.server = server
        self.appID = appID
        self.regexModifier = regexModifier
        self.portSettings = PortSettings(port: port, maxRetriesCount: maxPortRetries)
        try setup(initialStubs: initialStubs)
    }

    @available(*, deprecated, message: "Use throwable `startServer()` instead")
    func start() -> UInt16 {
        do {
            try server.start(portSettings.port)
            return portSettings.port
        } catch let error as SocketError {
            guard
                case .bindFailed = error,
                portSettings.canRetry
            else {
                showError("Failed to start local server after \(portSettings.maxRetriesCount) retries. \(error.localizedDescription)")
            }
            try? portSettings.retry()
            return start()
        } catch {
            showError("Failed to start local server \(error.localizedDescription)")
        }
    }

    func startServer() throws -> UInt16 {
        do {
            try server.start(portSettings.port)
            return portSettings.port
        } catch let error as SocketError {
            guard
                case .bindFailed = error,
                portSettings.canRetry
            else {
                print("Failed to start local server after \(portSettings.maxRetriesCount) retries. \(error.localizedDescription)")
                throw error
            }
            try portSettings.retry()
            return try startServer()
        } catch let error {
            print("Failed to start local server \(error.localizedDescription)")
            throw error
        }
    }

    func stop() {
        server.stop()
    }

    @available(*, deprecated, message: "Use throwable `update(using:)` instead")
    func update(with stubInfo: APIStubInfo) {
        try? setupStub(stubInfo)
    }

    func update(using stubInfo: APIStubInfo) throws {
        try setupStub(stubInfo)
    }

    @available(*, deprecated, message: "Use throwable `replace(using:)` instead")
    func replace(with job: ReplacementJob) {
        try? transform({
                try self.regexModifier.apply(modification: job.modification, in: $0)
            },
            in: job.stub
        )
    }

    func replace(using job: ReplacementJob) throws {
        try transform({
                try self.regexModifier.apply(modification: job.modification, in: $0)
            },
            in: job.stub
        )
    }

    private func transform(_ modifyFn: (Data) throws -> Data, in stub: APIStubInfo) throws {
        do {
            let dataObject = try getDataObject(from: stub)
            guard let json = try dataToJSON(data: dataObject) else { return }
            let data = try JSONSerialization.data(withJSONObject: json, options: JSONSerialization.WritingOptions.prettyPrinted)
            try stubJSON(object: try modifyFn(data), for: stub)
        } catch let error {
            print("Transform error: \(error)")
            throw error
        }
    }

    private func stubsDirectory() throws -> URL {
        guard let simulatorSharedDir = ProcessInfo().environment["SIMULATOR_SHARED_RESOURCES_DIRECTORY"] else {
            print("Cannot get Caches directory")
            throw Error.cantGetSimulatorSharedDir
        }
        let cacheDirPath = "Library/Caches"
        let sharedAPIStubsDir = "ApiStubs"

        let cachesDirURL = URL(fileURLWithPath: simulatorSharedDir).appendingPathComponent(cacheDirPath)
        let sharedAPIStubsDirURL = cachesDirURL.appendingPathComponent(sharedAPIStubsDir, isDirectory: true)
        let appSharedAPIStubsDirURL: URL = appID.isEmpty
            ? sharedAPIStubsDirURL
            : sharedAPIStubsDirURL.appendingPathComponent("\(appID)", isDirectory: true)
        do {
            try fileManager.createDirectory(at: appSharedAPIStubsDirURL, withIntermediateDirectories: true, attributes: nil)
        } catch let error {
            print("Failed to create shared folder \(appSharedAPIStubsDirURL.lastPathComponent) in simulator Caches directory at \(cachesDirURL)")
            throw error
        }

        return appSharedAPIStubsDirURL
    }

    private func setup(initialStubs: [APIStubInfo]) throws {
        for stub in initialStubs {
            try setupStub(stub)
        }
    }

    private func getDataObject(from stub: APIStubInfo) throws -> Data {
        var directory = try stubsDirectory()
        directory.appendPathComponent(stub.jsonFilename + ".json")
        let filePath = directory.path

        guard fileManager.fileExists(atPath: filePath) else {
            print("File does not exist: \(filePath)")
            throw Error.fileDoesNotExist(filePath)
        }

        guard let data = fileManager.contents(atPath: filePath) else {
            print("Data does not exist: \(filePath)")
            throw Error.dataDoesNotExist(filePath)
        }

        return data
    }

    private func setupStub(_ stub: APIStubInfo) throws {
        let data = try getDataObject(from: stub)
        try stubJSON(object: data, for: stub)
    }

    private func stubJSON(object data: Data, for stub: APIStubInfo) throws {
        let response = try createResponse(object: data, for: stub)
        switch stub.method {
        case .GET :
            server.methodGET(path: stub.url, response: response)
        case .POST:
            server.methodPOST(path: stub.url, response: response)
        case .PUT:
            server.methodPUT(path: stub.url, response: response)
        case .DELETE:
            server.methodDELETE(path: stub.url, response: response)
        }
    }

    private func createResponse(object data: Data?, for stub: APIStubInfo) throws -> ((HttpRequest) -> HttpResponse) {
        var json: AnyObject?
        if let jsonData = data {
            json = try dataToJSON(data: jsonData) as AnyObject
        }
        // Swifter makes it very easy to create stubbed responses
        let response: ((HttpRequest) -> HttpResponse) = { _ in
            switch stub.statusCode {
            case 200:
                return .okResponse(json: json)
            case 201:
                return .createdResponse(data: data)
            case 400:
                return .badRequest(nil)
            case 401:
                return .unauthorizedResponse(data: data)
            case 403:
                return .forbidden
            case 404:
                return .notFound
            case 406:
                return .notAcceptableResponse(data: data)
            case 500:
                return .internalServerError
            default:
                return .okResponse(json: json)
            }
        }
        return response
    }

    private func dataToJSON(data: Data) throws -> Any? {
        do {
            return try JSONSerialization.jsonObject(with: data, options: .mutableContainers)
        } catch let myJSONError {
            print("JSON serialization error: \(myJSONError)")
            throw myJSONError
        }
    }

    private func showError(_ message: String) -> Never {
        preconditionFailure(message)
    }
}

private extension HttpResponse {
    static var responseHeader: [String: String] {
        return ["Content-Type": "application/json"]
    }

    static func okResponse(json: AnyObject?) -> HttpResponse {
        if let jsonData = json {
            return .ok(.json(jsonData))
        } else {
            return .ok(.text(""))
        }
    }

    static func createdResponse(data: Data?) -> HttpResponse {
        if let jsonData = data {
            return .raw(201, "CREATED", nil, { writer in
                try? writer.write(Data(jsonData))
            })
        } else {
            return .created
        }
    }

    static func unauthorizedResponse(data: Data?) -> HttpResponse {
        if let jsonData = data {
            return .raw(401, "UNAUTHORIZED", responseHeader, { writer in
                try? writer.write(Data(jsonData))
            })
        } else {
            return .unauthorized
        }
    }

    static func notAcceptableResponse(data: Data?) -> HttpResponse {
        if let jsonData = data {
            return .raw(406, "NOT_ACCEPTABLE", responseHeader, { writer in
                try? writer.write(Data(jsonData))
            })
        } else {
            return .raw(406, "NOT_ACCEPTABLE", [:], { _ in })
        }
    }
}
