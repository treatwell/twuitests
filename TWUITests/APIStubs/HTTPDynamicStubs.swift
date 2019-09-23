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
    func start()
    func stop()
    func replace(with: ReplacementJob)
}

final class HTTPDynamicStubs: HTTPDynamicStubing {
    private let fileManager: FileManager
    private let server: HttpServerProtocol
    private let appID: String
    private let regexModifier: RegexJSONModifier
    private var portSettings: PortSettings

    init(
        fileManager: FileManager = .default,
        server: HttpServerProtocol = HttpServer(),
        initialStubs: [APIStubInfo] = HTTPDynamicStubsList().initialStubs,
        regexModifier: RegexJSONModifier = RegexJSONModifier(),
        appID: String,
        port: UInt16,
        portRange: ClosedRange<UInt16>?,
        maxPortRetries: Int = 5
    ) {
        self.fileManager = fileManager
        self.server = server
        self.appID = appID
        self.regexModifier = regexModifier
        self.portSettings = PortSettings(portRange: portRange, port: port, maxRetriesCount: maxPortRetries)
        setup(initialStubs: initialStubs)
    }

    func start() {
        do {
            try server.start(portSettings.port)
        } catch let error as SocketError {
            guard
                case .bindFailed = error,
                portSettings.canRetry,
                let newPort = portSettings.randomPort
            else {
                showError("Failed to start local server after \(portSettings.maxRetriesCount) retries. \(error.localizedDescription)")
            }
            portSettings.retried()
            portSettings.port = newPort
            start()
        } catch {
            showError("Failed to start local server \(error.localizedDescription)")
        }
    }

    func stop() {
        server.stop()
    }

    func update(with stubInfo: APIStubInfo) {
        setupStub(stubInfo)
    }

    func replace(with job: ReplacementJob) {
        transform({
                try self.regexModifier.apply(modification: job.modification, in: $0)
            },
            in: job.stub
        )
    }

    private func transform(_ modifyFn: (Data) throws -> Data, in stub: APIStubInfo) {
        do {
            let dataObject = getDataObject(from: stub)
            guard let json = dataToJSON(data: dataObject) else { return }
            let data = try JSONSerialization.data(withJSONObject: json, options: JSONSerialization.WritingOptions.prettyPrinted)
            stubJSON(object: try modifyFn(data), for: stub)
        } catch let error {
            print(error)
        }
    }

    private var stubsDirectory: URL {
        guard let simulatorSharedDir = ProcessInfo().environment["SIMULATOR_SHARED_RESOURCES_DIRECTORY"] else {
            showError("Cannot get Caches directory")
        }
        let simulatorHomeDirURL = URL(fileURLWithPath: simulatorSharedDir)
        let cachesDirURL = simulatorHomeDirURL.appendingPathComponent("Library/Caches")
        let sharedAPIStubsDirURL = cachesDirURL.appendingPathComponent("ApiStubs", isDirectory: true)
        let finalSharedAPIStubsDirURL: URL = appID.isEmpty
            ? sharedAPIStubsDirURL
            : sharedAPIStubsDirURL.appendingPathComponent("\(appID)", isDirectory: true)
        do {
            try fileManager.createDirectory(at: finalSharedAPIStubsDirURL, withIntermediateDirectories: true, attributes: nil)
        } catch {
            showError("Failed to create shared folder \(finalSharedAPIStubsDirURL.lastPathComponent) in simulator Caches directory at \(cachesDirURL)")
        }

        return finalSharedAPIStubsDirURL
    }

    private func setup(initialStubs: [APIStubInfo]) {
        for stub in initialStubs {
            setupStub(stub)
        }
    }

    private func getDataObject(from stub: APIStubInfo) -> Data {
        var directory = stubsDirectory
        directory.appendPathComponent(stub.jsonFilename + ".json")
        let filePath = directory.path

        guard fileManager.fileExists(atPath: filePath) else {
            showError("File does not exist: \(filePath)")
        }

        guard let data = fileManager.contents(atPath: filePath) else {
            showError("Data does not exist: \(filePath)")
        }

        return data
    }

    private func setupStub(_ stub: APIStubInfo) {
        let data = getDataObject(from: stub)
        stubJSON(object: data, for: stub)
    }

    private func stubJSON(object data: Data, for stub: APIStubInfo) {
        let response = createResponse(object: data, for: stub)
        switch stub.method {
        case .GET :
            server.GET[stub.url] = response
        case .POST:
            server.POST[stub.url] = response
        case .PUT:
            server.PUT[stub.url] = response
        case .DELETE:
            server.DELETE[stub.url] = response
        }
    }

    private func createResponse(object data: Data?, for stub: APIStubInfo) -> ((HttpRequest) -> HttpResponse) {
        var json: AnyObject?
        if let jsonData = data {
            json = dataToJSON(data: jsonData) as AnyObject
        }
        // Swifter makes it very easy to create stubbed responses
        let response: ((HttpRequest) -> HttpResponse) = { _ in
            switch stub.statusCode {
            case 200:
                return .okResponse(json: json)
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

    private func dataToJSON(data: Data) -> Any? {
        do {
            return try JSONSerialization.jsonObject(with: data, options: .mutableContainers)
        } catch let myJSONError {
            print(myJSONError)
        }
        return nil
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
