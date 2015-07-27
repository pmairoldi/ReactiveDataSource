import UIKit
import ReactiveCocoa

public struct CollectionViewConfiguration {
    
    private let reuseIdentifier: String
    
    public init(reuseIdentifier: String) {
        self.reuseIdentifier = reuseIdentifier
    }
}

public class CollectionViewDataSource<T>: NSObject, UICollectionViewDataSource {
    
    public let pushbackSignal: Signal<Actionable, NoError>
    
    private let configuration: CollectionViewConfiguration
    private let pushbackAction: Action<Actionable, Actionable, NoError>
    private let data = Data<T>()
    
    public init(collectionView: UICollectionView, dataProducer: SignalProducer<[[T]], NoError>, configuration: CollectionViewConfiguration) {
        self.configuration = configuration
        self.pushbackAction = Action<Actionable, Actionable, NoError> { SignalProducer<Actionable, NoError>(value: $0) }
        self.pushbackSignal = self.pushbackAction.values
        
        super.init()
        
        self.data.property <~ dataProducer.on(next: { _ in collectionView.reloadData() })
    }
    
    convenience public init(collectionView: UICollectionView, dataProducer: SignalProducer<[T], NoError>, configuration: CollectionViewConfiguration) {
        self.init(collectionView: collectionView, dataProducer: dataProducer.map { value in [value] }, configuration: configuration)
    }
    
    public func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return data.numberOfRows(inSection: section)
    }
    
    public func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(configuration.reuseIdentifier, forIndexPath: indexPath)
        
        if let item = data.item(atIndexPath: indexPath), let bindableCell = cell as? Bindable {
            bindableCell.bind(item, pushback: pushbackAction)
        }
        
        return cell
    }
    
    public func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return data.numberOfSections()
    }
}

/*
extension CollectionViewDataSource {
    
    public func collectionView(collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, atIndexPath indexPath: NSIndexPath) -> UICollectionReusableView {
        return UICollectionReusableView()
    }
    
    @available(iOS 9.0, *)
    public func collectionView(collectionView: UICollectionView, canMoveItemAtIndexPath indexPath: NSIndexPath) -> Bool {
        return false
    }
    
    @available(iOS 9.0, *)
    public func collectionView(collectionView: UICollectionView, moveItemAtIndexPath sourceIndexPath: NSIndexPath, toIndexPath destinationIndexPath: NSIndexPath) {
        
    }
}
*/