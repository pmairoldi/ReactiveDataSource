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
        
        model?.dataSource.pushbackSignal.observe(next: { [weak self] value in
            switch value as! CellActions {
            case let .Button1(x):
                self?.displayMessage("Action", message: x)
            case let .Button2(x):
                self?.displayMessage("Action", message: x)
            }
        })
        
        model?.delegate.selectionSignal.observe(next: { [weak self] value in
            
            let navController = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("ReactiveTableView") as! UINavigationController
            
            switch value as! SelectionActions  {
            case .Push:
                self?.navigationController?.pushViewController(navController.viewControllers[0], animated: true)
            case .Pop:
                self?.navigationController?.presentViewController(navController, animated: true, completion: nil)
            }
        })
    }
    
    deinit {
        print("controller deinit")
    }
}
