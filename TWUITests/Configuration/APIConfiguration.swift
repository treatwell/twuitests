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

public struct APIConfiguration {
    public enum PortType {
        case fixed(UInt16)
        case range(ClosedRange<UInt16>)
    }
    public let appID: String
    public var port: PortType
    public var apiStubs: [APIStubInfo]

    public init(
        port: UInt16,
        apiStubs: [APIStubInfo],
        appID: String = ""
    ) {
        self.appID = appID
        self.port = .fixed(port)
        self.apiStubs = apiStubs
    }

    public init(
        portRange: ClosedRange<UInt16>,
        apiStubs: [APIStubInfo],
        appID: String = ""
    ) {
        self.appID = appID
        self.port = .range(portRange)
        self.apiStubs = apiStubs
    }
}
