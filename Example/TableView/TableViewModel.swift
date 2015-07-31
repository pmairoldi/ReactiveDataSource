import Foundation
import ReactiveCocoa
import ReactiveDataSource

class TableViewModel {
    
    let dataSource: TableViewDataSource
    let delegate: TableViewDelegate
    
    init(tableView: UITableView) {
        
        dataSource = TableViewDataSource(tableView: tableView, dataProducer: dataProducer)
        
        let action = Action<NSIndexPath, Actionable, NoError> { input in
            
            return SignalProducer<Actionable, NoError> { sink, disposable in
                
                if input.row % 2 == 0 {
                    sendNext(sink, SelectionActions.Push)
                } else {
                    sendNext(sink, SelectionActions.Pop)
                }
                
                sendCompleted(sink)
            }
        }
        
        delegate = TableViewDelegate(tableView: tableView, rowProducer: dataProducer, headerProducer: headerProducer, selectionAction: action)
    }
    
    deinit {
        print("viewmodel deinit")
    }
}