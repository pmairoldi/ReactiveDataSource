import Foundation
import ReactiveCocoa
import ReactiveDataSource

class TableViewModel {
    
    let dataSource: TableViewDataSource
    let delegate: TableViewDelegate
    
    init() {
        
        dataSource = TableViewDataSource(dataProducer: dataProducer)
        delegate = TableViewDelegate(dataProducer: dataProducer, headerProducer: headerProducer)
    }
    
    deinit {
        print("viewmodel deinit")
    }
}