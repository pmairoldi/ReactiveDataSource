import Foundation
import ReactiveCocoa
import ReactiveDataSource

class CollectionViewModel {
    
    let dataSource: CollectionViewDataSource<CellViewModel>
    
    init(collectionView: UICollectionView) {
        
        let configuration = CollectionViewConfiguration(reuseIdentifier: "CollectionViewCell")
        
        dataSource = CollectionViewDataSource(collectionView: collectionView, dataProducer: dataProducer, configuration: configuration)
    }
}