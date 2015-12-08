import UIKit
import ReactiveCocoa

public final class TableViewDelegate<Provider: TableViewProvider>: NSObject, UITableViewDelegate {
    
    private let sections = MutableProperty<[Section<Provider.ItemType, Provider.HeaderType, Provider.FooterType>]>([])
    
    public let selection = Action<Actionable, Actionable, NoError> { SignalProducer(value: $0) }
    public let pushback = Action<Actionable, Actionable, NoError> { SignalProducer(value: $0) }
    
    public init(_ sections: SignalProducer<[[Provider.ItemType]], NoError>, headers: SignalProducer<[Provider.HeaderType], NoError>? = nil, footers: SignalProducer<[Provider.FooterType], NoError>? = nil) {
        
        self.sections <~ mapSections(sections, headers: headers, footers: footers)
        
        super.init()
    }
    
    public convenience init(_ items: SignalProducer<[Provider.ItemType], NoError>, headers: SignalProducer<[Provider.HeaderType], NoError>? = nil, footers: SignalProducer<[Provider.FooterType], NoError>? = nil) {
        self.init(items.map { [$0] }, headers: headers, footers: footers)
    }
    
    public func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
    
        guard let item = sections.value.atIndex(section) else {
            return UITableViewHeaderFooterView()
        }
        
        guard let reuseIdentifier = Provider.supplementaryReuseIdentifier(item, kind: .Header) else {
            return UITableViewHeaderFooterView()
        }
        
        return tableView.dequeueReusableHeaderFooterViewWithIdentifier(reuseIdentifier) ?? UITableViewHeaderFooterView()
    }
    
    public func tableView(tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        
        guard let item = sections.value.atIndex(section) else {
            return UITableViewHeaderFooterView()
        }
        
        guard let reuseIdentifier = Provider.supplementaryReuseIdentifier(item, kind: .Footer) else {
            return UITableViewHeaderFooterView()
        }
        
        return tableView.dequeueReusableHeaderFooterViewWithIdentifier(reuseIdentifier) ?? UITableViewHeaderFooterView()
    }
    
    public func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        
        guard let item = sections.value.atIndex(indexPath.section)?.atIndex(indexPath.row) else {
            return
        }
        
        Provider.bind(cell: cell, to: item, pushback: pushback)
    }
    
    public func tableView(tableView: UITableView, didEndDisplayingCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        
        guard let item = sections.value.atIndex(indexPath.section)?.atIndex(indexPath.row) else {
            return
        }
        
        Provider.unbind(cell: cell, from: item)
    }
    
    public func tableView(tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
                
        guard let item = sections.value.atIndex(section) else {
            return
        }
        
        Provider.bind(supplementaryView: view, to: item, ofKind: .Header, pushback: pushback)
    }
    
    public func tableView(tableView: UITableView, didEndDisplayingHeaderView view: UIView, forSection section: Int) {
        
        guard let item = sections.value.atIndex(section) else {
            return
        }
        
        Provider.unbind(supplementaryView: view, from: item, ofKind: .Header)
    }
    
    public func tableView(tableView: UITableView, willDisplayFooterView view: UIView, forSection section: Int) {
        
        guard let item = sections.value.atIndex(section) else {
            return
        }
        
        Provider.bind(supplementaryView: view, to: item, ofKind: .Footer, pushback: pushback)
    }
    
    public func tableView(tableView: UITableView, didEndDisplayingFooterView view: UIView, forSection section: Int) {
        
        guard let item = sections.value.atIndex(section) else {
            return
        }
        
        Provider.unbind(supplementaryView: view, from: item, ofKind: .Footer)
    }

    
    public func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {

        guard let item = sections.value.atIndex(indexPath.section)?.atIndex(indexPath.row) else {
            return
        }
        
        Provider.select(item, indexPath: indexPath, selection: selection)
    }
    
    public func tableView(tableView: UITableView, estimatedHeightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
       
        guard let item = sections.value.atIndex(indexPath.section)?.atIndex(indexPath.row) else {
            return 0.0
        }
        
        return Provider.estimatedHeightForCell(item)
    }
    
    public func tableView(tableView: UITableView, estimatedHeightForHeaderAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        
        guard let item = sections.value.atIndex(indexPath.section) else {
            return 0.0
        }
        
        return Provider.estimatedHeightForSupplementaryView(item, kind: .Header)
    }
    
    public func tableView(tableView: UITableView, estimatedHeightForFooterAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        
        guard let item = sections.value.atIndex(indexPath.section) else {
            return 0.0
        }
        
        return Provider.estimatedHeightForSupplementaryView(item, kind: .Footer)
    }
    
    public func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        
        guard let item = sections.value.atIndex(indexPath.section)?.atIndex(indexPath.row) else {
            return 0.0
        }
        
        let cell = Provider.sizingCell(item)
        
        if let binableCell = cell as? UITableViewCell {
            Provider.bind(cell: binableCell, to: item, pushback: pushback)
        }
        
        return cell?.heightForTableView(tableView) ?? 0.0
    }
    
    public func tableView(tableView: UITableView, heightForHeaderAtIndexPath indexPath: NSIndexPath) -> CGFloat {
       
        guard let item = sections.value.atIndex(indexPath.section) else {
            return 0.0
        }
        
        let cell = Provider.sizingSupplementaryView(item, kind: .Header)
        
        if let bindableView = cell as? UIView {
            Provider.bind(supplementaryView: bindableView, to: item, ofKind: .Header, pushback: pushback)
        }
        
        return cell?.heightForTableView(tableView) ?? 0.0
    }
    
    public func tableView(tableView: UITableView, heightForFooterAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        
        guard let item = sections.value.atIndex(indexPath.section) else {
            return 0.0
        }
        
        let cell = Provider.sizingSupplementaryView(item, kind: .Footer)
        
        if let bindableView = cell as? UIView {
            Provider.bind(supplementaryView: bindableView, to: item, ofKind: .Footer, pushback: pushback)
        }
        
        return cell?.heightForTableView(tableView) ?? 0.0
    }
}
