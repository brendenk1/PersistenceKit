import CoreData
import Foundation

/// A object that is responsible to manage operations with persisted objects
public final class PersistenceManager {
    public init(
        name: String,
        modelLocation: @escaping () -> URL,
        inMemory: Bool = false
    )
    {
        self.controller = PersistentController.loadModel(
            named: name,
            atLocation: modelLocation,
            inMemory: { inMemory }
        )
    }
    
    // MARK: - Private Properties
    private let controller: PersistentController
}

// MARK: - API
extension PersistenceManager {
    /// A method to create a new object to be managed by the persistence layer
    /// - Parameters:
    ///   - type: The type of object to create
    ///   - configure: A configuration method for the new object
    @discardableResult
    public func create<T: NSManagedObject>(
        type: T.Type,
        _ configure: (T) -> Void
    ) throws -> T
    {
        let item = T(context: controller.mainContext)
        configure(item)
        try controller.mainContext.save()
        return item
    }
    
    /// A method to remove an object from persistence
    /// - Parameter item: The item to remove
    public func delete<T: NSManagedObject>(
        item: T
    ) throws
    {
        controller.mainContext.delete(item)
        try controller.mainContext.save()
    }
    
    /// A method to get a collection of objects of a particular type
    /// - Parameters:
    ///   - type: The type of objects to load
    ///   - sort: A method to sort the objects retrieved
    ///   - limit: A optional limit to the number of items returned
    ///   - predicate: A optional predicate to use to filter items returned
    /// - Returns: A sorted collection of objects
    public func read<T: NSManagedObject>(
        itemType type: T.Type,
        sort: SortDescriptor<T>,
        limit: Int? = nil,
        predicate: NSPredicate? = nil
    ) async throws -> [T]
    {
        try await withCheckedThrowingContinuation { continuation in
            let request = type.fetchRequest()
            request.sortDescriptors = [NSSortDescriptor(sort)]
            if let limit { request.fetchLimit = limit }
            request.predicate = predicate
            let asyncRequest = NSAsynchronousFetchRequest(fetchRequest: request) { result in
                let typedResults = result.finalResult as? [T]
                continuation.resume(with: .success(typedResults ?? []))
            }
            do {
                try controller.mainContext.execute(asyncRequest)
            } catch {
                continuation.resume(with: .failure(error))
            }
        }
    }
    
    /// A method to update a particular object of a particular type
    /// - Parameters:
    ///   - object: The object that is desired to be updated
    ///   - update: A method to update the object
    public func update<T: NSManagedObject>(
        _ object: T,
        _ update: (T) -> Void
    ) async throws -> T
    {
        switch controller.mainContext.object(with: object.objectID) as? T {
        case .none:
            return object
        case .some(let object):
            update(object)
            try controller.mainContext.save()
            return object
        }
    }
}
