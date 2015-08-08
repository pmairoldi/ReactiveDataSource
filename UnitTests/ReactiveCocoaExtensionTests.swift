import XCTest
@testable import ReactiveDataSource
import ReactiveCocoa

class ReactiveCocoaExtensionTests: XCTestCase {
    
    class MockCell: ReactiveReuse {
        var reuseSignal: RACSignal {
            return RACSignal.error(NSError(domain: "", code: 0, userInfo: nil))
        }
    }
    
    class MockViewModel: Reusable {
        var reuseIdentifier: String {
            return "reuseId"
        }
    }
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testTableViewCellPrepareForReuse() {
        
        defer {
            waitForExpectationsWithTimeout(0.1, handler: nil)
        }
        
        let expectation = expectationWithDescription("prepareForReuse")
        
        let view = UITableViewCell()
        let reuseSignal = view.reuseSignal.toSignalProducer()
        
        reuseSignal.start(next: { _ in
            
            XCTAssert(true)
            expectation.fulfill()
        })
        
        view.prepareForReuse()
    }
    
    func testUITableViewHeaderFooterViewPrepareForReuse() {
        
        defer {
            waitForExpectationsWithTimeout(0.1, handler: nil)
        }
        
        let expectation = expectationWithDescription("prepareForReuse")
        
        let view = UITableViewHeaderFooterView()
        let reuseSignal = view.reuseSignal.toSignalProducer()
        
        reuseSignal.start(next: { _ in
            
            XCTAssert(true)
            expectation.fulfill()
        })
        
        view.prepareForReuse()
    }
    
    func testCollectionReusableViewPrepareForReuse() {
        
        defer {
            waitForExpectationsWithTimeout(0.1, handler: nil)
        }
        
        let expectation = expectationWithDescription("prepareForReuse")
        
        let view = UICollectionReusableView()
        let reuseSignal = view.reuseSignal.toSignalProducer()
        
        reuseSignal.start(next: { _ in
            
            XCTAssert(true)
            expectation.fulfill()
        })
        
        view.prepareForReuse()
    }
    
    func testRACPrepareForReuseSuccess() {
       
        defer {
            waitForExpectationsWithTimeout(0.1, handler: nil)
        }
        
        let expectation = expectationWithDescription("prepareForReuse")
        
        let view = UITableViewCell()
        let reuseSignal = view.rac_prepareForReuse
        
        reuseSignal.start(next: { _ in
            
            XCTAssert(true)
            expectation.fulfill()
        })
        
        view.prepareForReuse()
    }
    
    func testRACPrepareForReuseMapError() {
    
        defer {
            waitForExpectationsWithTimeout(0.1, handler: nil)
        }
        
        let expectation = expectationWithDescription("prepareForReuse")
        
        let view = MockCell()
        let reuseSignal = view.rac_prepareForReuse
        
        reuseSignal.start(completed: {
            
            XCTAssert(true)
            expectation.fulfill()
        })
    }
    
    func testRACTableViewDelegateNotSet() {
        
        let tableView = UITableView()
        let delegate = tableView.rac_delegate
        
        XCTAssertEqualOptional(delegate, nil)
    }
    
    func testRACTableViewDelegateSet() {
        
        let delegate = TableViewDelegate(dataProducer: SignalProducer(value: [MockViewModel()]))
        
        let tableView = UITableView()
        tableView.rac_delegate = delegate
        
        XCTAssertEqualOptional(tableView.rac_delegate, delegate)
    }
    
    func testRACTableViewDataSourceNotSet() {
        
        let tableView = UITableView()
        let dataSource = tableView.rac_dataSource
        
        XCTAssertEqualOptional(dataSource, nil)
    }
    
    func testRACTableViewDataSourceSet() {
        
        let dataSource = TableViewDataSource(dataProducer: SignalProducer(value: [MockViewModel()]))
        
        let tableView = UITableView()
        tableView.rac_dataSource = dataSource
        
        XCTAssertEqualOptional(tableView.rac_dataSource, dataSource)
    }
    
    func testRACCollectionViewDelegateNotSet() {
        
        let collectionView = UICollectionView(frame: CGRectZero, collectionViewLayout: UICollectionViewFlowLayout())
        let delegate = collectionView.rac_delegate
        
        XCTAssertEqualOptional(delegate, nil)
    }
    
    func testRACCollectionViewDelegateSet() {
        
        let delegate = CollectionViewDelegate(dataProducer: SignalProducer(value: [MockViewModel()]))
        
        let collectionView = UICollectionView(frame: CGRectZero, collectionViewLayout: UICollectionViewFlowLayout())
        collectionView.rac_delegate = delegate
        
        XCTAssertEqualOptional(collectionView.rac_delegate, delegate)
    }
    
    func testRACCollectionViewDataSourceNotSet() {
        
        let collectionView = UICollectionView(frame: CGRectZero, collectionViewLayout: UICollectionViewFlowLayout())
        let dataSource = collectionView.rac_dataSource
        
        XCTAssertEqualOptional(dataSource, nil)
    }
    
    func testRACCollectionViewDataSourceSet() {
        
        let dataSource = CollectionViewDataSource(dataProducer: SignalProducer(value: [MockViewModel()]))
        
        let collectionView = UICollectionView(frame: CGRectZero, collectionViewLayout: UICollectionViewFlowLayout())
        collectionView.rac_dataSource = dataSource
        
        XCTAssertEqualOptional(collectionView.rac_dataSource, dataSource)
    }}
