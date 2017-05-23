import Vapor
import FluentProvider
import HTTP

final class IOU: Model {
    let storage = Storage()
    
    var emailPayor: String
    var emailPayee: String
    var amountCents: Int
    var iouDescription: String
    var payedAt: Date?
    
    init(emailPayor: String, emailPayee: String, amountCents: Int, iouDescription: String) {
        self.emailPayor = emailPayor
        self.emailPayee = emailPayee
        self.amountCents = amountCents
        self.iouDescription = iouDescription
        self.createdAt = Date()
    }
    
    init(row: Row) throws {
        emailPayor = try row.get("emailPayor")
        emailPayee = try row.get("emailPayee")
        amountCents = try row.get("amountCents")
        iouDescription = try row.get("iouDescription")
        payedAt = try row.get("payedAt")
    }
    
    func makeRow() throws -> Row {
        var row = Row()
        try row.set("emailPayor", emailPayor)
        try row.set("emailPayee", emailPayee)
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
            builder.string("emailPayor")
            builder.string("emailPayee")
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
            emailPayor: json.get("emailPayor"),
            emailPayee: json.get("emailPayee"),
            amountCents: json.get("amountCents"),
            iouDescription: json.get("iouDescription")
        )
    }
    
    func makeJSON() throws -> JSON {
        var json = JSON()
        try json.set("id", id)
        try json.set("emailPayor", emailPayor)
        try json.set("emailPayee", emailPayee)
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
            t[iou.emailPayee] = (t[iou.emailPayee] ?? 0) + iou.amountCents
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



