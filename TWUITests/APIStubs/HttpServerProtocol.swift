import Swifter

protocol HttpServerProtocol: AnyObject {
    var DELETE: Swifter.HttpServer.MethodRoute { get set }
    var POST: Swifter.HttpServer.MethodRoute { get set }
    var GET: Swifter.HttpServer.MethodRoute { get set }
    var PUT: Swifter.HttpServer.MethodRoute { get set }
    func start(_ port: in_port_t, forceIPv4: Bool, priority: DispatchQoS.QoSClass) throws
    func stop()
}

extension HttpServerProtocol {
    func start(_ port: in_port_t = 8080, forceIPv4: Bool = false, priority: DispatchQoS.QoSClass = DispatchQoS.QoSClass.background) throws {
        try start(port, forceIPv4: forceIPv4, priority: priority)
    }
}

extension HttpServer: HttpServerProtocol {}
