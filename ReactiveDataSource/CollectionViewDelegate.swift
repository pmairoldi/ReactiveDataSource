import UIKit
import ReactiveCocoa

public class CollectionViewDelegate: NSObject, UICollectionViewDelegate {
    
    public let selectionSignal: Signal<Actionable, NoError>
    
    private let selectionAction: Action<Actionable, Actionable, NoError>
    private let data = RowData<Reusable>()

    public init(dataProducer: SignalProducer<[[Reusable]], NoError>) {
        
        self.selectionAction = Action<Actionable, Actionable, NoError> { SignalProducer<Actionable, NoError>(value: $0) }
        
        self.selectionSignal = self.selectionAction.values
        
        self.data.property <~ dataProducer

        super.init()
    }
    
    convenience public init(dataProducer: SignalProducer<[Reusable], NoError>) {
        self.init(dataProducer: dataProducer.map { [$0] })
    }
    
    public func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        
        guard let item = data.item(atIndexPath: indexPath) as? Selectable else {
            return
        }
        
        item.select(indexPath, action: selectionAction)
    }
}