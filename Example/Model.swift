import Foundation
import ReactiveCocoa
import ReactiveDataSource

struct CellViewModel: Reusable, Selectable {
    
    let text: MutableProperty<String>
    let buttonOneAction: Action<AnyObject, Void, NoError>
    let buttonTwoAction: Action<AnyObject, Void, NoError>
    
    init(value: Int) {
        text = MutableProperty("\(value)")
        buttonOneAction = Action<AnyObject, Void, NoError> { _ in SignalProducer(value: ()) }
        buttonTwoAction = Action<AnyObject, Void, NoError> { _ in SignalProducer(value: ()) }
    }
    
    var reuseIdentifier: String {
        return "Cell"
    }
    
    func select(indexPath: NSIndexPath, action: Action<Actionable, Actionable, NoError>?) {
        
        if indexPath.row % 2 == 0 {
            action?.apply(SelectionActions.Push).start()
        } else {
            action?.apply(SelectionActions.Pop).start()
        }
    }
}

struct HeaderViewModel: Reusable, Adjustable {
    
    let text: MutableProperty<String>
    
    init(value: String) {
        text = MutableProperty(value)
    }
    
    var reuseIdentifier: String {
        return "Header"
    }
    
    var height: CGFloat {
        return 44.0
    }
    
    var estimatedHeight: CGFloat {
        return 44.0
    }
}

let cellModels: [Reusable] = [1,2,3,4,5,6,7,8,9,10,11,12].map { CellViewModel(value: $0) }

let dataProducer = SignalProducer<[Reusable], NoError> { sink, disposable in
    sendNext(sink, cellModels)
}

let headerProducer = SignalProducer<Reusable, NoError> { sink, disposable in
    sendNext(sink, HeaderViewModel(value: "Header"))
}