import Vapor
import HTTP

final class MeController {
    
    func index(request: Request) throws -> ResponseRepresentable {
        let ious = try IOU.all()
        
        // "authenticated" user email comes in the header
        let mail = request.headers["mail"]

        var response = JSON()
        
        let payTotal = ious.filter { $0.emailDestination == mail }.reduceTotal()
        let receiveTotal = ious.filter { $0.emailSource == mail }.reduceTotal()
        
        let payArray = try payTotal.toJSONArray()
        let receiveArray = try receiveTotal.toJSONArray()

        try response.set("toPay", payArray)
        try response.set("toReceive", receiveArray)

        return response
    }
}
