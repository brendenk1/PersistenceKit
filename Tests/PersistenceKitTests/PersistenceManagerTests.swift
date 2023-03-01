import PersistenceKit
import XCTest

final class PersistenceManagerTests: XCTestCase {

    let testModelName = "Model"
    let location = { Bundle.module.bundleURL }
    
    /// The purpose of this test is to ensure loading of a manager instance
    func testLoad() {
        _ = PersistenceManager(
            name: testModelName,
            modelLocation: location,
            inMemory: true
        )
    }
    
    /// The purpose of this test is to ensure the creation of a new object
    func testCreate() throws {
        // Given
        let manager = PersistenceManager(
            name: testModelName,
            modelLocation: location,
            inMemory: true
        )
        
        // Finally
        try manager.create(type: Test.self) { newObject in
            newObject.date = .now
        }
    }
    
    /// The purpose of this test is to ensure that deletion happens
    func testDelete() async throws {
        // Given
        let manager = PersistenceManager(
            name: testModelName,
            modelLocation: location,
            inMemory: true
        )
        
        let object = try manager.create(type: Test.self) { newObject in
            newObject.date = .now
        }
        
        // Finally
        try manager.delete(item: object)
        let objects = try await manager.read(itemType: Test.self, sort: SortDescriptor(\.date))
        
        XCTAssertEqual(objects.count, 0)
    }
    
    /// The purpose of this test is to ensure the reading of objects from persistence
    func testReading() async throws {
        // Given
        let manager = PersistenceManager(
            name: testModelName,
            modelLocation: location,
            inMemory: true
        )
        
        try manager.create(type: Test.self) { newObject in
            newObject.date = .now
        }
        
        // Finally
        let objects = try await manager.read(itemType: Test.self, sort: .init(\.date))
        XCTAssertEqual(objects.count, 1)
    }
    
    /// The purpose of this test is to ensure sorting rules are followed
    func testReadingSort() async throws {
        // Given
        let manager = PersistenceManager(
            name: testModelName,
            modelLocation: location,
            inMemory: true
        )
        
        let dateOne = Date.now
        let dateTwo = dateOne.addingTimeInterval(-5000)
        
        try manager.create(type: Test.self) { newObject in
            newObject.date = dateOne
        }
        
        try manager.create(type: Test.self) { newObject in
            newObject.date = dateTwo
        }
        
        // Finally
        let objectsAscending = try await manager.read(itemType: Test.self, sort: SortDescriptor(\.date))
        let objectsDescending = try await manager.read(itemType: Test.self, sort: SortDescriptor(\.date, order: .reverse))
        XCTAssertEqual(objectsAscending.map { $0.date }, [dateTwo, dateOne])
        XCTAssertEqual(objectsDescending.map { $0.date }, [dateOne, dateTwo])
    }
    
    /// The purpose of this test is to ensure limit rules are followed
    func testReadingLimit() async throws {
        // Given
        let manager = PersistenceManager(
            name: testModelName,
            modelLocation: location,
            inMemory: true
        )
        
        let dateOne = Date.now
        let dateTwo = dateOne.addingTimeInterval(-5000)
        
        try manager.create(type: Test.self) { newObject in
            newObject.date = dateOne
        }
        
        try manager.create(type: Test.self) { newObject in
            newObject.date = dateTwo
        }
        
        // Finally
        let objects = try await manager.read(
            itemType: Test.self,
            sort: SortDescriptor(\.date),
            limit: 1
        )
        XCTAssertEqual(objects.count, 1)
    }
    
    /// The purpose of this test is to ensure predicate rules are followed
    func testPredicates() async throws {
        // Given
        let manager = PersistenceManager(
            name: testModelName,
            modelLocation: location,
            inMemory: true
        )
        
        let dateOne = Date.now
        let dateTwo = dateOne.addingTimeInterval(-5000)
        
        try manager.create(type: Test.self) { newObject in
            newObject.date = dateOne
        }
        
        try manager.create(type: Test.self) { newObject in
            newObject.date = dateTwo
        }
        
        let predicate = NSPredicate(format: "date == %@", dateOne as CVarArg)
        
        // Finally
        let objects = try await manager.read(
            itemType: Test.self,
            sort: SortDescriptor(\.date),
            predicate: predicate
        )
        
        XCTAssertEqual(objects.count, 1)
        XCTAssertEqual(objects.map { $0.date }, [dateOne])
    }
    
    /// The purpose of this test is to ensure that the object is updated
    func testUpdate() async throws {
        // Given
        let manager = PersistenceManager(
            name: testModelName,
            modelLocation: location,
            inMemory: true
        )
        
        let dateOne = Date.now
        let dateTwo = dateOne.addingTimeInterval(5000)
        
        let object = try manager.create(type: Test.self) { newObject in
            newObject.date = dateOne
        }
        
        // Finally
        let updated = try await manager.update(object) { object in
            object.date = dateTwo
        }
        
        XCTAssertEqual(updated.date, dateTwo)
    }
}
