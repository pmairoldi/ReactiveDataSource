import UIKit
import ReactiveCocoa

public class TableViewDelegate: NSObject, UITableViewDelegate {
    
    public let selectionSignal: Signal<Actionable, NoError>
    public let pushbackSignal: Signal<Actionable, NoError>

    private let selectionAction: Action<Actionable, Actionable, NoError>
    private let pushbackAction: Action<Actionable, Actionable, NoError>
    private let data = RowData<Reusable>()
    private let headerData = SectionData<Reusable>()
    private let footerData = SectionData<Reusable>()
    
    public init(dataProducer: SignalProducer<[[Reusable]], NoError>, headerProducer: SignalProducer<[Reusable], NoError>? = nil, footerProducer: SignalProducer<[Reusable], NoError>? = nil) {
        
        selectionAction = Action<Actionable, Actionable, NoError> { SignalProducer<Actionable, NoError>(value: $0) }
        pushbackAction = Action<Actionable, Actionable, NoError> { SignalProducer<Actionable, NoError>(value: $0) }

        selectionSignal = selectionAction.values
        pushbackSignal = pushbackAction.values

        data.property <~ dataProducer
        
        if let headerProducer = headerProducer {
            headerData.property <~ headerProducer
        }
        
        if let footerProducer = footerProducer {
            footerData.property <~ footerProducer
        }

        super.init()
    }

    private func tableView(tableView: UITableView, headerFooterViewForItem item: Reusable) -> UIView? {
        
        let view = tableView.dequeueReusableHeaderFooterViewWithIdentifier(item.reuseIdentifier)
        
        if let bindableView = view as? Bindable {
        
            let completedClosure: () -> () = { [weak view] in
                (view as? Bindable)?.unbind()
            }
            
            view?.rac_prepareForReuse.startWithSignal { signal, disposable in
                bindableView.bind(item, pushback: pushbackAction, reuse: signal)
                signal.takeUntil(signal).observeCompleted(completedClosure)
            }
        }

        return view
    }
    
    public func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        guard let item = data.item(atIndexPath: indexPath) as? Selectable else {
            return
        }
        
        item.select(indexPath, action: selectionAction)
    }
    
    public func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {

        guard let item = headerData.item(inSection: section) else {
            return nil
        }
        
        return self.tableView(tableView, headerFooterViewForItem: item)
    }
    
    public func tableView(tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        
        guard let item = footerData.item(inSection: section) else {
            return nil
        }
        
        return self.tableView(tableView, headerFooterViewForItem: item)
    }
    
    public func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        
        guard let item = data.item(atIndexPath: indexPath) as? Adjustable else {
            return tableView.rowHeight
        }
        
        return item.height
    }
    
    public func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        
        guard let item = headerData.item(inSection: section) as? Adjustable else {
            return tableView.sectionHeaderHeight
        }
        
        return item.height
    }
    
    public func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
       
        guard let item = footerData.item(inSection: section) as? Adjustable else {
            return tableView.sectionFooterHeight
        }
        
        return item.height
    }
    
    public func tableView(tableView: UITableView, estimatedHeightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        
        guard let item = data.item(atIndexPath: indexPath) as? Adjustable else {
            return tableView.estimatedRowHeight
        }
        
        return item.estimatedHeight
    }
    
    public func tableView(tableView: UITableView, estimatedHeightForHeaderInSection section: Int) -> CGFloat {
        
        guard let item = headerData.item(inSection: section) as? Adjustable else {
            return tableView.estimatedSectionHeaderHeight
        }
        
        return item.estimatedHeight
    }
    
    public func tableView(tableView: UITableView, estimatedHeightForFooterInSection section: Int) -> CGFloat {
        
        guard let item = footerData.item(inSection: section) as? Adjustable else {
            return tableView.estimatedSectionFooterHeight
        }
        
        return item.estimatedHeight
    }
}

extension TableViewDelegate {
    
    convenience public init(dataProducer: SignalProducer<[Reusable], NoError>) {
        self.init(dataProducer: dataProducer.map { [$0] }, headerProducer: nil, footerProducer: nil)
    }
    
    convenience public init(dataProducer: SignalProducer<[Reusable], NoError>, headerProducer: SignalProducer<[Reusable], NoError>?, footerProducer: SignalProducer<[Reusable], NoError>?) {
        self.init(dataProducer: dataProducer.map { [$0] }, headerProducer: headerProducer, footerProducer: footerProducer)
    }
    
    convenience public init(dataProducer: SignalProducer<[Reusable], NoError>, headerProducer: SignalProducer<[Reusable], NoError>?) {
        self.init(dataProducer: dataProducer.map { [$0] }, headerProducer: headerProducer, footerProducer: nil)
    }
    
    convenience public init(dataProducer: SignalProducer<[Reusable], NoError>, footerProducer: SignalProducer<[Reusable], NoError>?) {
        self.init(dataProducer: dataProducer.map { [$0] }, headerProducer: nil, footerProducer: footerProducer)
    }
    
    convenience public init(dataProducer: SignalProducer<[Reusable], NoError>, headerProducer: SignalProducer<Reusable, NoError>?, footerProducer: SignalProducer<Reusable, NoError>?) {
        self.init(dataProducer: dataProducer.map { [$0] }, headerProducer: headerProducer?.map { [$0] }, footerProducer: footerProducer?.map { [$0] })
    }
    
    convenience public init(dataProducer: SignalProducer<[Reusable], NoError>, headerProducer: SignalProducer<Reusable, NoError>?) {
        self.init(dataProducer: dataProducer.map { [$0] }, headerProducer: headerProducer?.map { [$0] }, footerProducer: nil)
    }
    
    convenience public init(dataProducer: SignalProducer<[Reusable], NoError>, footerProducer: SignalProducer<Reusable, NoError>?) {
        self.init(dataProducer: dataProducer.map { [$0] }, headerProducer: nil, footerProducer: footerProducer?.map { [$0] })
    }
    
    convenience public init(dataProducer: SignalProducer<Reusable, NoError>) {
        self.init(dataProducer: dataProducer.map { [[$0]] }, headerProducer: nil, footerProducer: nil)
    }

    convenience public init(dataProducer: SignalProducer<Reusable, NoError>, headerProducer: SignalProducer<[Reusable], NoError>?, footerProducer: SignalProducer<[Reusable], NoError>?) {
        self.init(dataProducer: dataProducer.map { [[$0]] }, headerProducer: headerProducer, footerProducer: footerProducer)
    }
    
    convenience public init(dataProducer: SignalProducer<Reusable, NoError>, headerProducer: SignalProducer<[Reusable], NoError>?) {
        self.init(dataProducer: dataProducer.map { [[$0]] }, headerProducer: headerProducer, footerProducer: nil)
    }
    
    convenience public init(dataProducer: SignalProducer<Reusable, NoError>, footerProducer: SignalProducer<[Reusable], NoError>?) {
        self.init(dataProducer: dataProducer.map { [[$0]] }, headerProducer: nil, footerProducer: footerProducer)
    }
    
    convenience public init(dataProducer: SignalProducer<Reusable, NoError>, headerProducer: SignalProducer<Reusable, NoError>?, footerProducer: SignalProducer<Reusable, NoError>?) {
        self.init(dataProducer: dataProducer.map { [[$0]] }, headerProducer: headerProducer?.map { [$0] }, footerProducer: footerProducer?.map { [$0] })
    }
    
    convenience public init(dataProducer: SignalProducer<Reusable, NoError>, headerProducer: SignalProducer<Reusable, NoError>?) {
        self.init(dataProducer: dataProducer.map { [[$0]] }, headerProducer: headerProducer?.map { [$0] }, footerProducer: nil)
    }
    
    convenience public init(dataProducer: SignalProducer<Reusable, NoError>, footerProducer: SignalProducer<Reusable, NoError>?) {
        self.init(dataProducer: dataProducer.map { [[$0]] }, headerProducer: nil, footerProducer: footerProducer?.map { [$0] })
    }
}
