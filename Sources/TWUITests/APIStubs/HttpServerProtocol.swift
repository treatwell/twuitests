import Foundation
import Swifter

protocol HttpServerProtocol: AnyObject {
    func methodDELETE(path: String, response: ((HttpRequest) -> HttpResponse)?)
    func methodPOST(path: String, response: ((HttpRequest) -> HttpResponse)?)
    func methodGET(path: String, response: ((HttpRequest) -> HttpResponse)?)
    func methodPUT(path: String, response: ((HttpRequest) -> HttpResponse)?)
    func start(_ port: in_port_t, forceIPv4: Bool, priority: DispatchQoS.QoSClass) throws
    func stop()
}

extension HttpServerProtocol {
    func start(_ port: in_port_t = 8080, forceIPv4: Bool = false, priority: DispatchQoS.QoSClass = DispatchQoS.QoSClass.background) throws {
        try start(port, forceIPv4: forceIPv4, priority: priority)
    }
}

extension HttpServer: HttpServerProtocol {
    func methodDELETE(path: String, response: ((HttpRequest) -> HttpResponse)?) {
        DELETE[path] = response
    }

    func methodPOST(path: String, response: ((HttpRequest) -> HttpResponse)?) {
        POST[path] = response
    }

    func methodGET(path: String, response: ((HttpRequest) -> HttpResponse)?) {
        GET[path] = response
    }

    func methodPUT(path: String, response: ((HttpRequest) -> HttpResponse)?) {
        PUT[path] = response
    }
}
