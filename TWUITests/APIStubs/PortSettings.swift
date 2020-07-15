struct PortSettings {
    enum Error: Swift.Error {
        case failedToGeneratePort
    }
    let maxRetriesCount: Int
    private(set) var port: UInt16
    private let portType: APIConfiguration.PortType
    private var retriesCount: Int = 0

    init(port: APIConfiguration.PortType, maxRetriesCount: Int) {
        self.portType = port
        self.maxRetriesCount = maxRetriesCount
        switch portType {
        case .fixed(let port):
           self.port = port
        case .range(let portRange):
            self.port = portRange.first!
        }
    }

    var canRetry: Bool {
        return retriesCount < maxRetriesCount
    }

    mutating func retry() throws {
        retriesCount += 1
        port = try generatedPort()
    }

    private func generatedPort() throws -> UInt16 {
        switch portType {
        case .range(let portRange):
            guard let port = portRange.randomElement() else {
                throw Error.failedToGeneratePort
            }
            return port
        case .fixed(let port):
            return port
        }
    }
}
