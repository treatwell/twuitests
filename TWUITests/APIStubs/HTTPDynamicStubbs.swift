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
    func replaceValues(of items: [String: String], in stub: APIStubInfo)
}

final class HTTPDynamicStubs: HTTPDynamicStubing {
    private let fileManager: FileManager
    private let server: HttpServer
    private let appID: String
    private let port: UInt16
    
    init(
        fileManager: FileManager = .default,
        server: HttpServer = HttpServer(),
        initialStubs: [APIStubInfo] = HTTPDynamicStubsList().initialStubs,
        appID: String,
        port: UInt16
    ) {
        self.fileManager = fileManager
        self.server = server
        self.appID = appID
        self.port = port
        setup(initialStubs: initialStubs)
    }
    
    func start() {
        do {
            try server.start(port)
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
    
    func replaceValues(of items: [String: String], in stub: APIStubInfo) {
        do {
            guard let json = getJSONObject(from: stub) else  { return }
            let data = try JSONSerialization.data(withJSONObject: json, options: JSONSerialization.WritingOptions.prettyPrinted)
            guard var string = String(data: data, encoding: .utf8) else { return }
            
            for (key, value) in items {
                string = string.replacingOccurrences(
                    of: "\"\(key)\"\\s?:\\s?\".*\"",
                    with: "\"\(key)\" : \"\(value)\"",
                    options: .regularExpression)
            }
            
            if let data = string.data(using: .utf8) {
                stubJSON(object: dataToJSON(data: data), for: stub)
            }
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
    
    private func getJSONObject(from stub: APIStubInfo) -> Any? {
        var directory = stubsDirectory
        directory.appendPathComponent(stub.jsonFilename + ".json")
        let filePath = directory.path
        
        guard fileManager.fileExists(atPath: filePath) else {
            showError("File does not exist: \(filePath)")
        }
        
        guard let data = fileManager.contents(atPath: filePath) else {
            showError("Data does not exist: \(filePath)")
        }
        
        return dataToJSON(data: data)
    }
    
    private func setupStub(_ stub: APIStubInfo) {
        stubJSON(object: getJSONObject(from: stub), for: stub)
    }
    
    private func stubJSON(object json: Any?, for stub: APIStubInfo) {
        // Swifter makes it very easy to create stubbed responses
        let response: ((HttpRequest) -> HttpResponse) = { _ in
            let response = HttpResponse.ok(.json(json as AnyObject))
            return response
        }
        
        switch stub.method {
        case .GET : server.GET[stub.url] = response
        case .POST: server.POST[stub.url] = response
        case .PUT: server.PUT[stub.url] = response
        case .DELETE: server.DELETE[stub.url] = response
        }
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
