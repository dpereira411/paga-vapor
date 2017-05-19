import Vapor

final class Routes: RouteCollection {
    func build(_ builder: RouteBuilder) throws {

        builder.get("me", handler: MeController().index)
        
        builder.get("*") { req in return req.description }
        
        try builder.resource("ious", IOUController.self)

    }
}

/// Since Routes doesn't depend on anything
/// to be initialized, we can conform it to EmptyInitializable
///
/// This will allow it to be passed by type.
extension Routes: EmptyInitializable { }
