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
        
        model = TableViewModel(tableView: tableView)
        
        tableView.dataSource = model?.dataSource
        tableView.delegate = self
        
        model?.dataSource.pushbackSignal.observe(next: { [weak self] value in
            switch value {
            case let CellActions.Button1(x):
                self?.displayMessage("Action", message: x)
            case let CellActions.Button2(x):
                self?.displayMessage("Action", message: x)
            default:
                print("noop")
            }
        })
    }
    
    deinit {
        print("controller deinit")
    }
}

extension TableViewController {
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
}