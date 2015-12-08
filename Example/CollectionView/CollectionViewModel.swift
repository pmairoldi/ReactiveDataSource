import Foundation
import ReactiveCocoa
import ReactiveDataSource

class CollectionProvider: CollectionViewProvider {
    
    typealias ItemType = Int
    typealias HeaderType = Int
    typealias FooterType = Int

    static func reuseIdentifier(item: ItemType) -> String {
        return "Cell"
    }
    
    static func supplementaryReuseIdentifier(item: Section<ItemType, HeaderType, FooterType>, kind: SupplementaryElementKind) -> String? {
        return nil
    }
    
    static func sizingCell(item: ItemType) -> SizableCollectionViewCell? {
        return UINib(nibName: "CollectionViewCell", bundle: nil).instantiateWithOwner(nil, options: nil).first as? CollectionViewCell
    }
    
    static func sizingSupplementaryView(item: Section<ItemType, HeaderType, FooterType>, kind: SupplementaryElementKind) -> SizableCollectionViewCell? {
        return nil
    }
    
    static func select(item: ItemType, indexPath: NSIndexPath, selection: Action<Actionable, Actionable, NoError>) {
        selection.apply(SelectionActions.Push).start()
    }
    
    static func bind(cell cell: UICollectionViewCell, to item: ItemType, pushback: Action<Actionable, Actionable, NoError>) {
        if let cell = cell as? CollectionViewCell {
            cell.bind(CellViewModel(value: item), pushback: pushback)
        }
    }
    
    static func unbind(cell cell: UICollectionViewCell, from item: ItemType) {
        if let cell = cell as? CollectionViewCell {
            cell.unbind()
        }
    }
    
    static func bind(supplementaryView supplementaryView: UICollectionReusableView, to item: Section<ItemType, HeaderType, FooterType>, ofKind kind: SupplementaryElementKind, pushback: Action<Actionable, Actionable, NoError>) {
        
    }
    
    static func unbind(supplementaryView supplementaryView: UICollectionReusableView, from item: Section<ItemType, HeaderType, FooterType>, ofKind kind: SupplementaryElementKind) {
        
    }
}

class CollectionViewModel {
    
    let dataSource: CollectionViewDataSource<CollectionProvider>
    let delegate: CollectionViewDelegate<CollectionProvider>

    init() {
        let sections: SignalProducer<[[Int]], NoError> = SignalProducer(value: [[1,2,3], [1,2,3]])
        
        dataSource = CollectionViewDataSource(sections)
        delegate = CollectionViewDelegate(sections)
    }
    
    deinit {
        print("viewmodel deinit")
    }
}
