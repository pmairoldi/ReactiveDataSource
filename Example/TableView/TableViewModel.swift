import Foundation
import ReactiveCocoa
import ReactiveDataSource

class TableViewModel {
    
    let dataSource: TableViewDataSource
    let delegate: TableViewDelegate
    
    init(tableView: UITableView) {
        
        dataSource = TableViewDataSource(tableView: tableView, dataProducer: dataProducer)
        delegate = TableViewDelegate(dataProducer: dataProducer, headerProducer: headerProducer)
    }
    
    deinit {
        print("viewmodel deinit")
    }
}