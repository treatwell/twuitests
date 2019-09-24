struct PortSettings {
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

    mutating func retry() {
        port = generatedPort
        retriesCount += 1
    }

    private var generatedPort: UInt16 {
        switch portType {
        case .range(let portRange):
            return portRange.randomElement()!
        case .fixed(let port):
            return port
        }
    }
}
