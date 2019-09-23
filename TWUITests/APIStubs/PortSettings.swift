struct PortSettings {
    let portRange: ClosedRange<UInt16>?
    let maxRetriesCount: Int
    var port: UInt16
    private var retriesCount: Int = 0

    init(portRange: ClosedRange<UInt16>?, port: UInt16, maxRetriesCount: Int) {
        self.portRange = portRange
        self.port = port
        self.maxRetriesCount = maxRetriesCount
    }

    var canRetry: Bool {
        return retriesCount < maxRetriesCount
    }

    mutating func retried() {
        retriesCount += 1
    }
}
