import UIKit
import ReactiveCocoa

public protocol SizableTableViewCell {
    func heightForTableView(tableView: UITableView) -> CGFloat
}

public protocol TableViewProvider {
    
    typealias ItemType
    typealias HeaderType
    typealias FooterType
    
    static func reuseIdentifier(item: ItemType) -> String
    static func supplementaryReuseIdentifier(item: Section<ItemType, HeaderType, FooterType>, kind: SupplementaryElementKind) -> String?
    
    static func estimatedHeightForCell(item: ItemType) -> CGFloat
    static func estimatedHeightForSupplementaryView(item: Section<ItemType, HeaderType, FooterType>, kind: SupplementaryElementKind) -> CGFloat

    static func sizingCell(item: ItemType) -> SizableTableViewCell?
    static func sizingSupplementaryView(item: Section<ItemType, HeaderType, FooterType>, kind: SupplementaryElementKind) -> SizableTableViewCell?
    
    static func select(item: ItemType, indexPath: NSIndexPath, selection: Action<Actionable, Actionable, NoError>)
    
    static func bind(cell cell: UITableViewCell, to item: ItemType, pushback: Action<Actionable, Actionable, NoError>)
    static func unbind(cell cell: UITableViewCell, from item: ItemType)
    
    static func bind(supplementaryView supplementaryView: UIView, to item: Section<ItemType, HeaderType, FooterType>, ofKind kind: SupplementaryElementKind, pushback: Action<Actionable, Actionable, NoError>)
    static func unbind(supplementaryView supplementaryView: UIView, from item: Section<ItemType, HeaderType, FooterType>, ofKind kind: SupplementaryElementKind)
}
