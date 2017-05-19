import Vapor
import FluentProvider
import HTTP

final class IOU: Model {
    let storage = Storage()
    
    var emailSource: String
    var emailDestination: String
    var amountCents: Int
    var createdAt: Date
    var payedAt: Date?

    init(emailSource: String, emailDestination: String, amountCents: Int) {
        self.emailSource = emailSource
        self.emailDestination = emailDestination
        self.amountCents = amountCents
        self.createdAt = Date()
    }

    init(row: Row) throws {
        emailSource = try row.get("emailSource")
        emailDestination = try row.get("emailDestination")
        amountCents = try row.get("amountCents")
        createdAt = try row.get("createdAt")
        payedAt = try row.get("payedAt")
    }

    func makeRow() throws -> Row {
        var row = Row()
        try row.set("emailSource", emailSource)
        try row.set("emailDestination", emailDestination)
        try row.set("amountCents", amountCents)
        try row.set("createdAt", createdAt)
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
            builder.date("createdAt")
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
            amountCents: json.get("amountCents")
        )
    }
    
    func makeJSON() throws -> JSON {
        var json = JSON()
        try json.set("id", id)
        try json.set("emailSource", emailSource)
        try json.set("emailDestination", emailDestination)
        try json.set("amountCents", amountCents)
        try json.set("createdAt", createdAt)
        try json.set("payedAt", payedAt)
        return json
    }
}

extension IOU: ResponseRepresentable { }
