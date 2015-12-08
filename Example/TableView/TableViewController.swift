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
        
        tableView.registerNib(UINib(nibName: "TableViewCell", bundle: nil), forCellReuseIdentifier: "Cell")

        model = TableViewModel()
        
        tableView.registerClass(TableViewHeader.self, forHeaderFooterViewReuseIdentifier: "Header")
        
        tableView.dataSource = model?.dataSource
        tableView.delegate = model?.delegate
        
        model?.delegate.pushback.values.observeNext(pushbackAction())
        model?.delegate.selection.values.observeNext(selectionAction())
    }
    
    deinit {
        print("controller deinit")
    }
}
