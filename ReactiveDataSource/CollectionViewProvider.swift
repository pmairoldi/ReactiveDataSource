import UIKit
import ReactiveCocoa

public protocol SizableCollectionViewCell {
    func sizeForCollectionView(collectionView: UICollectionView, flowLayout: UICollectionViewFlowLayout) -> CGSize
}

public protocol CollectionViewProvider {
    
    typealias ItemType
    typealias HeaderType
    typealias FooterType
        
    static func reuseIdentifier(item: ItemType) -> String
    static func supplementaryReuseIdentifier(item: Section<ItemType, HeaderType, FooterType>, kind: SupplementaryElementKind) -> String?
    
    static func sizingCell(item: ItemType) -> SizableCollectionViewCell?
    static func sizingSupplementaryView(item: Section<ItemType, HeaderType, FooterType>, kind: SupplementaryElementKind) -> SizableCollectionViewCell?
    
    static func select(item: ItemType, indexPath: NSIndexPath, selection: Action<Actionable, Actionable, NoError>)
    
    static func bind(cell cell: UICollectionViewCell, to item: ItemType, pushback: Action<Actionable, Actionable, NoError>)
    static func unbind(cell cell: UICollectionViewCell, from item: ItemType)
    
    static func bind(supplementaryView supplementaryView: UICollectionReusableView, to item: Section<ItemType, HeaderType, FooterType>, ofKind kind: SupplementaryElementKind, pushback: Action<Actionable, Actionable, NoError>)
    static func unbind(supplementaryView supplementaryView: UICollectionReusableView, from item: Section<ItemType, HeaderType, FooterType>, ofKind kind: SupplementaryElementKind)
}
