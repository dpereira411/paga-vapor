import Vapor
import FluentProvider
import HTTP

final class IOU: Model {
    let storage = Storage()
    
    var emailSource: String
    var emailDestination: String
    var amountCents: Int
    var iouDescription: String
    var payedAt: Date?
    
    init(emailSource: String, emailDestination: String, amountCents: Int, iouDescription: String) {
        self.emailSource = emailSource
        self.emailDestination = emailDestination
        self.amountCents = amountCents
        self.iouDescription = iouDescription
        self.createdAt = Date()
    }
    
    init(row: Row) throws {
        emailSource = try row.get("emailSource")
        emailDestination = try row.get("emailDestination")
        amountCents = try row.get("amountCents")
        iouDescription = try row.get("iouDescription")
        payedAt = try row.get("payedAt")
    }
    
    func makeRow() throws -> Row {
        var row = Row()
        try row.set("emailSource", emailSource)
        try row.set("emailDestination", emailDestination)
        try row.set("amountCents", amountCents)
        try row.set("iouDescription", iouDescription)
        try row.set("payedAt", payedAt)
        return row
    }
}

extension IOU: Preparation {
    
    static func prepare(_ database: Database) throws {
        try database.create(self) { builder in
            builder.id()
            builder.string("emailSource")
            builder.string("emailDestination")
            builder.int("amountCents")
            builder.string("iouDescription")
            builder.date("payedAt", optional: true)
        }
    }
    
    static func revert(_ database: Database) throws {
        try database.delete(self)
    }
}

extension IOU: JSONConvertible {
    convenience init(json: JSON) throws {
        try self.init(
            emailSource: json.get("emailSource"),
            emailDestination: json.get("emailDestination"),
            amountCents: json.get("amountCents"),
            iouDescription: json.get("iouDescription")
        )
    }
    
    func makeJSON() throws -> JSON {
        var json = JSON()
        try json.set("id", id)
        try json.set("emailSource", emailSource)
        try json.set("emailDestination", emailDestination)
        try json.set("amountCents", amountCents)
        try json.set("iouDescription", iouDescription)
        try json.set("payedAt", payedAt)
        return json
    }
}

extension IOU: Timestampable, ResponseRepresentable { }

//extension IOU: ResponseRepresentable { }

extension Array where Element:IOU {
    
    func reduceTotal() -> [String: Int] {
        return self.reduce([String: Int]()) { r, iou in
            var t = r
            t[iou.emailDestination] = (t[iou.emailDestination] ?? 0) + iou.amountCents
            return t
        }
    }
}

extension Dictionary  {
    
    func toJSONArray() throws -> [JSON] {
        return try self.map { iou in
            var response = JSON()
            
            try response.set("email", iou.key)
            try response.set("totalAmountCents", iou.value)
            
            return response
        }
    }
    
}



