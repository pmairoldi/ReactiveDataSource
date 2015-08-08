import UIKit
import ReactiveDataSource
import ReactiveCocoa

class TableViewController: UITableViewController {
    
    /// Make sure that the dataSource is a strong reference
    /// UITableView's dataSource property is marked weak
    /// so it will be deallocated if not retained properly
    var model: TableViewModel?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard let tableView = tableView else {
            return
        }
        
        model = TableViewModel()
        
        tableView.registerClass(TableViewHeader.self, forHeaderFooterViewReuseIdentifier: "Header")
        
        tableView.rac_dataSource = model?.dataSource
        tableView.rac_delegate = model?.delegate
        
        model?.dataSource.pushbackSignal.observe(next: pushbackAction())
        model?.delegate.selectionSignal.observe(next: selectionAction())
    }
    
    deinit {
        print("controller deinit")
    }
}
