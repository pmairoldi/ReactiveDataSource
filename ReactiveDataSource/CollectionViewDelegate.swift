import UIKit
import ReactiveCocoa

public class CollectionViewDelegate: NSObject, UICollectionViewDelegate {
    
    public let selectionSignal: Signal<Actionable, NoError>
    
    private let selectionAction: Action<Actionable, Actionable, NoError>
    private let data = RowData<Reusable>()

    public init(dataProducer: SignalProducer<[[Reusable]], NoError>) {
        
        selectionAction = Action<Actionable, Actionable, NoError> { SignalProducer<Actionable, NoError>(value: $0) }
        selectionSignal = selectionAction.values
        
        data.property <~ dataProducer

        super.init()
    }
    
    public func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        
        guard let item = data.item(atIndexPath: indexPath) as? Selectable else {
            return
        }
        
        item.select(indexPath, action: selectionAction)
    }
}

extension CollectionViewDelegate {
    
    convenience public init(dataProducer: SignalProducer<[Reusable], NoError>) {
        self.init(dataProducer: dataProducer.map { [$0] })
    }
    
    convenience public init(dataProducer: SignalProducer<Reusable, NoError>) {
        self.init(dataProducer: dataProducer.map { [[$0]] })
    }
}
