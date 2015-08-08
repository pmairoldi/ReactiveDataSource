import XCTest
@testable import ReactiveDataSource

class DataTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testRowDataEmpty() {
        
        let rowData = RowData<String>()
        let sectionCount = rowData.numberOfSections()
        let numberOfRows = rowData.numberOfRows(inSection: 0)
        let itemAtIndex = rowData.item(atIndexPath: NSIndexPath(forRow: 0, inSection: 0))
        
        XCTAssertEqual(sectionCount, 0)
        XCTAssertEqual(numberOfRows, 0)
        XCTAssertEqual(itemAtIndex, nil)
    }
    
    func testRowDataNotEmpty() {
        
        let rowData = RowData<String>()
        rowData.property.value = [["test"]]
        let sectionCount = rowData.numberOfSections()
        let numberOfRows = rowData.numberOfRows(inSection: 0)
        let itemAtIndex = rowData.item(atIndexPath: NSIndexPath(forRow: 0, inSection: 0))
        
        XCTAssertEqual(sectionCount, 1)
        XCTAssertEqual(numberOfRows, 1)
        XCTAssertEqual(itemAtIndex, "test")
    }
    
    func testSectionDataEmpty() {
        
        let sectionData = SectionData<String>()
        let item = sectionData.item(inSection: 0)
        
        XCTAssertEqual(item, nil)
    }
    
    func testSectionDataNotEmpty() {
        
        let sectionData = SectionData<String>()
        sectionData.property.value = ["test"]
        let item = sectionData.item(inSection: 0)
        
        XCTAssertEqual(item, "test")
    }
}
