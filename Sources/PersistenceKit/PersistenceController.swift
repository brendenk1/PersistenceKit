import CoreData
import Foundation
import OSLog

final class PersistentController {
    // MARK: - Static
    private static let log = Logger(subsystem: "com.cavachon", category: "Persistent Controller")
    
    static func loadModel(
        named: String,
        atLocation location: @escaping () -> URL,
        inMemory: @escaping () -> Bool
    ) -> PersistentController
    {
        PersistentController(container: PersistentController.loadContainer(name: named)(location)(inMemory))
    }
    
    private static func loadContainer(
        name: String
    ) -> (@escaping () -> URL) -> (@escaping () -> Bool) -> NSPersistentContainer
    {
        { modelLocation in
            { inMemory in
                guard let model = NSManagedObjectModel(contentsOf: modelLocation())
                else
                {
                    log.error("Model was not able to be located at \(modelLocation())")
                    fatalError()
                }
                
                let container = NSPersistentContainer(name: name, managedObjectModel: model)
                
                if inMemory() {
                    container.persistentStoreDescriptions.first?.url = URL(fileURLWithPath: "/dev/null")
                }
                
                container.loadPersistentStores { description, error in
                    switch error {
                    case .none:
                        log.debug("store \(description) loaded successfully.")
                    case .some(let error):
                        log.error("store \(description) failed to load. \(error)")
                        fatalError()
                    }
                }
                
                return container
            }
        }
    }
    
    init(
        container: NSPersistentContainer
    )
    {
        self.container = container
    }
    
    // MARK: - Private Properties
    private let container: NSPersistentContainer
}

// MARK: - API
extension PersistentController {
    var mainContext: NSManagedObjectContext {
        container.viewContext
    }
    
    func backgroundContext() -> NSManagedObjectContext {
        container.newBackgroundContext()
    }
}
