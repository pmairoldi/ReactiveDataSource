import Foundation
import ReactiveCocoa
import ReactiveDataSource

class TableProvider: TableViewProvider {
    
    typealias ItemType = Int
    typealias HeaderType = Int
    typealias FooterType = Int
    
    static func reuseIdentifier(item: ItemType) -> String {
        return "Cell"
    }
    
    static func supplementaryReuseIdentifier(item: Section<ItemType, HeaderType, FooterType>, kind: SupplementaryElementKind) -> String? {
        return nil
    }
    
    static func estimatedHeightForCell(item: ItemType) -> CGFloat {
       return 44.0
    }
    
    static func estimatedHeightForSupplementaryView(item: Section<ItemType, HeaderType, FooterType>, kind: SupplementaryElementKind) -> CGFloat {
        return 35.0
    }

    static func sizingCell(item: ItemType) -> SizableTableViewCell? {
        return UINib(nibName: "TableViewCell", bundle: nil).instantiateWithOwner(nil, options: nil).first as? TableViewCell
    }
    
    static func sizingSupplementaryView(item: Section<ItemType, HeaderType, FooterType>, kind: SupplementaryElementKind) -> SizableTableViewCell? {
        return UINib(nibName: "TableViewHeader", bundle: nil).instantiateWithOwner(nil, options: nil).first as? TableViewHeader
    }
    
    static func select(item: ItemType, indexPath: NSIndexPath, selection: Action<Actionable, Actionable, NoError>) {
        selection.apply(SelectionActions.Push).start()
    }
    
    static func bind(cell cell: UITableViewCell, to item: ItemType, pushback: Action<Actionable, Actionable, NoError>) {
        if let cell = cell as? TableViewCell {
            cell.bind(CellViewModel(value: item), pushback: pushback)
        }
    }
    
    static func unbind(cell cell: UITableViewCell, from item: ItemType) {
        if let cell = cell as? TableViewCell {
            cell.unbind()
        }
    }
    
    static func bind(supplementaryView supplementaryView: UIView, to item: Section<ItemType, HeaderType, FooterType>, ofKind kind: SupplementaryElementKind, pushback: Action<Actionable, Actionable, NoError>) {
        
    }
    
    static func unbind(supplementaryView supplementaryView: UIView, from item: Section<ItemType, HeaderType, FooterType>, ofKind kind: SupplementaryElementKind) {
        
    }
}

class TableViewModel {
    
    let dataSource: TableViewDataSource<TableProvider>
    let delegate: TableViewDelegate<TableProvider>

    init() {
        let sections: SignalProducer<[[Int]], NoError> = SignalProducer(value: [[1,2,3], [1,2,3]])

        dataSource = TableViewDataSource(sections)
        delegate = TableViewDelegate(sections)
    }
    
    deinit {
        print("viewmodel deinit")
    }
}
