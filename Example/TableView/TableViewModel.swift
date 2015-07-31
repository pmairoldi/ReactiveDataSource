import Foundation
import ReactiveCocoa
import ReactiveDataSource

class TableViewModel {
    
    let dataSource: TableViewDataSource
    
    init(tableView: UITableView) {
        
        dataSource = TableViewDataSource(tableView: tableView, dataProducer: dataProducer)
    }
    
    deinit {
        print("viewmodel deinit")
    }
}