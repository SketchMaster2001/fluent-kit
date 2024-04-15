import NIOCore

public protocol AnyModelResponder {
    func handle(
        _ event: ModelEvent,
        _ model: any AnyModel,
        on db: any Database
    ) -> EventLoopFuture<Void>
}

extension AnyModelResponder {
    public func create(_ model: any AnyModel, on db: any Database) -> EventLoopFuture<Void> {
        return handle(.create, model, on: db)
    }
    
    public func update(_ model: any AnyModel, on db: any Database) -> EventLoopFuture<Void> {
        return handle(.update, model, on: db)
    }
    
    public func restore(_ model: any AnyModel, on db: any Database) -> EventLoopFuture<Void> {
        return handle(.restore, model, on: db)
    }
    
    public func softDelete(_ model: any AnyModel, on db: any Database) -> EventLoopFuture<Void> {
        return handle(.softDelete, model, on: db)
    }
    
    public func delete(_ model: any AnyModel, force: Bool, on db: any Database) -> EventLoopFuture<Void> {
        return handle(.delete(force), model, on: db)
    }
}

internal struct BasicModelResponder<Model>: AnyModelResponder where Model: FluentKit.Model {
    private let _handle: (ModelEvent, Model, any Database) throws -> EventLoopFuture<Void>
    
    internal func handle(_ event: ModelEvent, _ model: any AnyModel, on db: any Database) -> EventLoopFuture<Void> {
        guard let modelType = model as? Model else {
            fatalError("Could not convert type AnyModel to \(Model.self)")
        }
        
        do {
            return try _handle(event, modelType, db)
        } catch {
            return db.eventLoop.makeFailedFuture(error)
        }
    }
    
    init(handle: @escaping (ModelEvent, Model, any Database) throws -> EventLoopFuture<Void>) {
        self._handle = handle
    }
}

