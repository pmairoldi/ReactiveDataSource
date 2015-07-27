import Foundation
import ReactiveCocoa
import ReactiveDataSource

class TableViewModel {
    
    let dataSource: TableViewDataSource<CellViewModel>
    
    init(tableView: UITableView) {
        
        let configuration = TableViewConfiguration(reuseIdentifier: "TableViewCell")
        
        dataSource = TableViewDataSource(tableView: tableView, dataProducer: dataProducer, configuration: configuration)
    }
}