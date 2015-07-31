import UIKit
import ReactiveCocoa

public class CollectionViewDataSource: NSObject, UICollectionViewDataSource {
    
    public let pushbackSignal: Signal<Actionable, NoError>
    
    private let pushbackAction: Action<Actionable, Actionable, NoError>
    private let data = Data<Reusable>()
    
    public init(collectionView: UICollectionView, dataProducer: SignalProducer<[[Reusable]], NoError>) {
        self.pushbackAction = Action<Actionable, Actionable, NoError> { SignalProducer<Actionable, NoError>(value: $0) }
        self.pushbackSignal = self.pushbackAction.values
        
        super.init()
        
        self.data.property <~ dataProducer
        self.data.property.producer.start(next: { _ in
            collectionView.reloadData()
        })
    }
    
    convenience public init(collectionView: UICollectionView, dataProducer: SignalProducer<[Reusable], NoError>) {
        self.init(collectionView: collectionView, dataProducer: dataProducer.map { value in [value] })
    }
    
    public func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return data.numberOfRows(inSection: section)
    }
    
    public func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {

        guard let item = data.item(atIndexPath: indexPath) else {
            print("no data at indexPath")
            return UICollectionViewCell()
        }
        
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(item.reuseIdentifier, forIndexPath: indexPath)
        
        if let bindableCell = cell as? Bindable {
            cell.rac_prepareForReuse.startWithSignal { signal, disposable in
                bindableCell.bind(item, pushback: pushbackAction, reuse: signal)
                signal.takeUntil(signal).observe(completed: { [weak cell] in let bindedCell = cell as? Bindable; bindedCell?.unbind() })
            }
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