import XCTest
@testable import ReactiveDataSource

class AssociationTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testAssociatedObject() {
        
        class Object: NSObject {
            private static var key: UInt8 = 0
        }
        
        let object = Object()
        
        associatedObject(object, key: &Object.key, initial: { "initial" })
        
        XCTAssertEqualOptional(objc_getAssociatedObject(object, &Object.key) as? String, "initial")
    }
}
