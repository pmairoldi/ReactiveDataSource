import Foundation
import ReactiveCocoa
import ReactiveDataSource

class CollectionViewModel {
    
    let dataSource: CollectionViewDataSource
    let delegate: CollectionViewDelegate

    init() {
        dataSource = CollectionViewDataSource(dataProducer: dataProducer)
        delegate = CollectionViewDelegate(dataProducer: dataProducer)
    }
    
    deinit {
        print("viewmodel deinit")
    }
}