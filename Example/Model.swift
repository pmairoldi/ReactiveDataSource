import Foundation
import ReactiveCocoa
import ReactiveDataSource

struct CellViewModel {
    let text: MutableProperty<String>
    let buttonOneAction: Action<AnyObject, Void, NoError>
    let buttonTwoAction: Action<AnyObject, Void, NoError>
    
    init(value: Int) {
        self.text = MutableProperty("\(value)")
        self.buttonOneAction = Action<AnyObject, Void, NoError> { _ in SignalProducer(value: ()) }
        self.buttonTwoAction = Action<AnyObject, Void, NoError> { _ in SignalProducer(value: ()) }
    }
}

enum CellActions: Actionable {
    case Button1(String)
    case Button2(String)
}

let viewModels = [1,2,3,4,5,6,7,8,9,10,11,12].map { CellViewModel(value: $0) }

let dataProducer = SignalProducer<[[CellViewModel]], NoError> { sink, disposable in
    sendNext(sink, [viewModels])
}