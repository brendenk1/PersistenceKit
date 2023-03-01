@testable import PersistenceKit
import XCTest

final class PersistentControllerTests: XCTestCase {
    
    let testModelName = "Model"
    let location = { Bundle.module.bundleURL }
    let inMemory = { true }

    /// The purpose of this test is to ensure that the controller loads successfully
    func testLoad() {
        _ = PersistentController.loadModel(
            named: testModelName,
            atLocation: location,
            inMemory: inMemory
        )
    }
}
