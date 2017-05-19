import Vapor
import HTTP

final class IOUController: ResourceRepresentable {
    /// When users call 'GET' on '/posts'
    /// it should return an index of all available posts
    func index(request: Request) throws -> ResponseRepresentable {
        let ious = try IOU.all()
        
        let a = ious.reduce([String: Int]()) { r, iou in
            var t = r
            t[iou.emailDestination] = (t[iou.emailDestination] ?? 0) + iou.amountCents
            return t
        }
        
        var response = JSON()
        for iou in a {
            try response.set(dotKey: iou.key, iou.value)
        }

        return response
    }

    /// When consumers call 'POST' on '/posts' with valid JSON
    /// create and save the post
    func create(request: Request) throws -> ResponseRepresentable {
        let iou = try request.iou()
        try iou.save()
        return iou
    }

    /// When the consumer calls 'GET' on a specific resource, ie:
    /// '/posts/13rd88' we should show that specific post
    func show(request: Request, iou: IOU) throws -> ResponseRepresentable {
        return iou
    }

    /// When the consumer calls 'DELETE' on a specific resource, ie:
    /// 'posts/l2jd9' we should remove that resource from the database
    func delete(request: Request, iou: IOU) throws -> ResponseRepresentable {
        try iou.delete()
        return Response(status: .ok)
    }

    /// When the consumer calls 'DELETE' on the entire table, ie:
    /// '/posts' we should remove the entire table
    func clear(request: Request) throws -> ResponseRepresentable {
        try IOU.makeQuery().delete()
        return Response(status: .ok)
    }

    /// When the user calls 'PATCH' on a specific resource, we should
    /// update that resource to the new values
    func update(request: Request, iou: IOU) throws -> ResponseRepresentable {
        let new = try request.iou()
        iou.emailSource = new.emailSource
        try iou.save()
        return iou
    }

    /// When a user calls 'PUT' on a specific resource, we should
    /// delete the current value and completely replace it with the
    /// new parameters
    func replace(request: Request, iou: IOU) throws -> ResponseRepresentable {
        try iou.delete()
        return try create(request: request)
    }

    /// When making a controller, it is pretty flexible in that it
    /// only expects closures, this is useful for advanced scenarios, but
    /// most of the time, it should look almost identical to this 
    /// implementation
    func makeResource() -> Resource<IOU> {
        return Resource(
            index: index,
            store: create,
            show: show,
            update: update,
            replace: replace,
            destroy: delete,
            clear: clear
        )
    }
}

extension Request {
    func iou() throws -> IOU {
        guard let json = json else { throw Abort.badRequest }
        return try IOU(json: json)
    }
}

/// Since IOUController doesn't require anything to 
/// be initialized we can conform it to EmptyInitializable.
///
/// This will allow it to be passed by type.
extension IOUController: EmptyInitializable { }

extension StructuredDataWrapper {
    
    mutating func set(dotKey: String, _ value: NodeRepresentable) throws {
        self[DotKey(dotKey)] = Self(try value.makeNode(in: context))
    }
}

