import XCTest
@testable import ReactiveDataSource

class ArrayExtensionTests: XCTestCase {

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testIndexInRange() {
        
        let array = [0,1,2]
        let item = array.atIndex(1)
        
        XCTAssertEqualOptional(item, 1)
    }

    func testIndexOutOfBounds() {

        let array = [0,1,2]
        let item = array.atIndex(3)
        
        XCTAssertEqualOptional(item, nil)
    }
}
