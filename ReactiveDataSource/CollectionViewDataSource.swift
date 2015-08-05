import UIKit
import ReactiveCocoa

public class CollectionViewDataSource: NSObject, UICollectionViewDataSource {
    
    public let pushbackSignal: Signal<Actionable, NoError>
    
    internal let data = RowData<Reusable>()

    private let pushbackAction: Action<Actionable, Actionable, NoError>
    private let NoCell = UICollectionViewCell()
    private let NoSupplementaryElement = UICollectionReusableView()

    public init(dataProducer: SignalProducer<[[Reusable]], NoError>) {
        
        pushbackAction = Action<Actionable, Actionable, NoError> { SignalProducer<Actionable, NoError>(value: $0) }
        pushbackSignal = pushbackAction.values
    
        data.property <~ dataProducer

        super.init()
    }
    
    public func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return data.numberOfRows(inSection: section)
    }
    
    public func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {

        guard let item = data.item(atIndexPath: indexPath) else {
            return NoCell
        }
        
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(item.reuseIdentifier, forIndexPath: indexPath)
        
        if let bindableCell = cell as? Bindable {
            
            let completedClosure: () -> () = { [weak cell] in
                (cell as? Bindable)?.unbind()
            }
            
            cell.rac_prepareForReuse.startWithSignal { signal, disposable in
                bindableCell.bind(item, pushback: pushbackAction, reuse: signal)
                signal.takeUntil(signal).observe(completed: completedClosure)
            }
        }
        
        return cell
    }
    
    public func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return data.numberOfSections()
    }
    
    public func collectionView(collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, atIndexPath indexPath: NSIndexPath) -> UICollectionReusableView {
        
        guard let item = data.item(atIndexPath: indexPath) as? Supplementable else {
            return NoSupplementaryElement
        }
        
        let cell = collectionView.dequeueReusableSupplementaryViewOfKind(item.supplementaryElementKind, withReuseIdentifier: item.supplementaryReuseIdentifier, forIndexPath: indexPath)
        
        if let bindableCell = cell as? Bindable {
            
            let completedClosure: () -> () = { [weak cell] in
                (cell as? Bindable)?.unbind()
            }
            
            cell.rac_prepareForReuse.startWithSignal { signal, disposable in
                bindableCell.bind(item, pushback: pushbackAction, reuse: signal)
                signal.takeUntil(signal).observe(completed: completedClosure)
            }
        }
        
        return cell
    }
}

extension CollectionViewDataSource {

    convenience public init(dataProducer: SignalProducer<[Reusable], NoError>) {
        self.init(dataProducer: dataProducer.map { [$0] })
    }
    
    convenience public init(dataProducer: SignalProducer<Reusable, NoError>) {
        self.init(dataProducer: dataProducer.map { [[$0]] })
    }
}
