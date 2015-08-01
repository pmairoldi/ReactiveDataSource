import Foundation
import ReactiveCocoa
import ReactiveDataSource

struct CellViewModel: Reusable, Selectable {
    let text: MutableProperty<String>
    let buttonOneAction: Action<AnyObject, Void, NoError>
    let buttonTwoAction: Action<AnyObject, Void, NoError>
    
    init(value: Int) {
        self.text = MutableProperty("\(value)")
        self.buttonOneAction = Action<AnyObject, Void, NoError> { _ in SignalProducer(value: ()) }
        self.buttonTwoAction = Action<AnyObject, Void, NoError> { _ in SignalProducer(value: ()) }
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
    
    init(value: Int) {
        self.text = MutableProperty("\(value)")
    }
    
    var reuseIdentifier: String {
        return "Header"
    }
    
    var height: CGFloat {
        return 100.0
    }
    
    var estimatedHeight: CGFloat {
        return 100.0
    }
}

enum CellActions: Actionable {
    case Button1(String)
    case Button2(String)
}

enum SelectionActions: Actionable {
    case Push
    case Pop
}

let cellModels: [Reusable] = [1,2,3,4,5,6,7,8,9,10,11,12].map { CellViewModel(value: $0) }
let headerModels: [Reusable] = [1].map { HeaderViewModel(value: $0) }

let dataProducer = SignalProducer<[[Reusable]], NoError> { sink, disposable in
    sendNext(sink, [cellModels])
}

let headerProducer = SignalProducer<[Reusable], NoError> { sink, disposable in
    sendNext(sink, headerModels)
}