import Vapor
import HTTP

final class MeController {
    
    func index(request: Request) throws -> ResponseRepresentable {
        let ious = try IOU.all()
        
        let mail = request.headers["mail"]

        var response = JSON()
        try response.set("toPay", ious.filter { $0.emailDestination == mail }.makeJSON())
        try response.set("toReceive", ious.filter { $0.emailSource == mail }.makeJSON())

        return response
    }
}
