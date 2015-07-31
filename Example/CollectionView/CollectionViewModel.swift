import Foundation
import ReactiveCocoa
import ReactiveDataSource

class CollectionViewModel {
    
    let dataSource: CollectionViewDataSource
    
    init(collectionView: UICollectionView) {
        
        dataSource = CollectionViewDataSource(collectionView: collectionView, dataProducer: dataProducer)
    }
    
    deinit {
        print("viewmodel deinit")
    }
}