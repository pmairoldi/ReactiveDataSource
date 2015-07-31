import UIKit
import ReactiveCocoa

public class TableViewDelegate: NSObject, UITableViewDelegate {
    
    public let selectionSignal: Signal<Actionable, NoError>?
    public let pushbackSignal: Signal<Actionable, NoError>

    private let selectionAction: Action<NSIndexPath, Actionable, NoError>?
    private let pushbackAction: Action<Actionable, Actionable, NoError>
    private let rowData = RowData<Reusable>()
    private let headerData = SectionData<Reusable>()
    private let footerData = SectionData<Reusable>()

    private let NoView = UIView()
    
    public init(tableView: UITableView, rowProducer: SignalProducer<[[Reusable]], NoError>? = nil, headerProducer: SignalProducer<[Reusable], NoError>? = nil, footerProducer: SignalProducer<[Reusable], NoError>? = nil, selectionAction: Action<NSIndexPath, Actionable, NoError>? = nil) {
        
        self.selectionAction = selectionAction
        self.pushbackAction = Action<Actionable, Actionable, NoError> { SignalProducer<Actionable, NoError>(value: $0) }

        self.selectionSignal = self.selectionAction?.values ?? nil
        self.pushbackSignal = self.pushbackAction.values

        if let rowProducer = rowProducer {
            self.rowData.property <~ rowProducer
        }
        
        if let headerProducer = headerProducer {
            self.headerData.property <~ headerProducer
        }
        
        if let footerProducer = footerProducer {
            self.footerData.property <~ footerProducer
        }

        super.init()
    }
    
    convenience public init(tableView: UITableView, rowProducer: SignalProducer<[Reusable], NoError>? = nil, headerProducer: SignalProducer<[Reusable], NoError>? = nil, footerProducer: SignalProducer<[Reusable], NoError>? = nil, selectionAction: Action<NSIndexPath, Actionable, NoError>? = nil) {
        self.init(tableView: tableView, rowProducer: rowProducer?.map { [$0] }, headerProducer: headerProducer, footerProducer: footerProducer, selectionAction: selectionAction)
    }
    
    private func tableView(tableView: UITableView, headerFooterViewForItem item: Reusable) -> UIView? {
        
        let view = tableView.dequeueReusableHeaderFooterViewWithIdentifier(item.reuseIdentifier)
        
        if let bindableView = view as? Bindable {
            view?.rac_prepareForReuse.startWithSignal { signal, disposable in
                bindableView.bind(item, pushback: pushbackAction, reuse: signal)
                signal.takeUntil(signal).observe(completed: { [weak view] in let bindedView = view as? Bindable; bindedView?.unbind() })
            }
        }

        return view
    }
    
    public func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        self.selectionAction?.apply(indexPath).start()
    }
    
    public func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {

        guard let item = headerData.item(inSection: section) else {
            return NoView
        }
        
        return self.tableView(tableView, headerFooterViewForItem: item)
    }
    
    public func tableView(tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        
        guard let item = footerData.item(inSection: section) else {
            return NoView
        }
        
        return self.tableView(tableView, headerFooterViewForItem: item)
    }
    
    public func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        
        guard let item = rowData.item(atIndexPath: indexPath) as? ReusableCell else {
            return tableView.rowHeight
        }
        
        return item.height
    }
    
    public func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        
        guard let item = headerData.item(inSection: section) as? ReusableHeader else {
            return tableView.sectionHeaderHeight
        }
        
        return item.height
    }
    
    public func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
       
        guard let item = footerData.item(inSection: section) as? ReusableFooter else {
            return tableView.sectionFooterHeight
        }
        
        return item.height
    }
    
    public func tableView(tableView: UITableView, estimatedHeightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        
        guard let item = rowData.item(atIndexPath: indexPath) as? ReusableCell else {
            return tableView.estimatedRowHeight
        }
        
        return item.estimatedHeight
    }
    
    public func tableView(tableView: UITableView, estimatedHeightForHeaderInSection section: Int) -> CGFloat {
        
        guard let item = headerData.item(inSection: section) as? ReusableHeader else {
            return tableView.estimatedSectionHeaderHeight
        }
        
        return item.estimatedHeight
    }
    
    public func tableView(tableView: UITableView, estimatedHeightForFooterInSection section: Int) -> CGFloat {
        
        guard let item = footerData.item(inSection: section) as? ReusableFooter else {
            return tableView.estimatedSectionFooterHeight
        }
        
        return item.estimatedHeight
    }
}

/*
extension TableViewDelegate {

public func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath)
public func tableView(tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int)
public func tableView(tableView: UITableView, willDisplayFooterView view: UIView, forSection section: Int)
public func tableView(tableView: UITableView, didEndDisplayingCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath)
public func tableView(tableView: UITableView, didEndDisplayingHeaderView view: UIView, forSection section: Int)
public func tableView(tableView: UITableView, didEndDisplayingFooterView view: UIView, forSection section: Int)

// Variable height support

// Use the estimatedHeight methods to quickly calcuate guessed values which will allow for fast load times of the table.
// If these methods are implemented, the above -tableView:heightForXXX calls will be deferred until views are ready to be displayed, so more expensive logic can be placed there.


// Accessories (disclosures).

public func tableView(tableView: UITableView, accessoryButtonTappedForRowWithIndexPath indexPath: NSIndexPath)

// Selection

// -tableView:shouldHighlightRowAtIndexPath: is called when a touch comes down on a row.
// Returning NO to that message halts the selection process and does not cause the currently selected row to lose its selected look while the touch is down.
public func tableView(tableView: UITableView, shouldHighlightRowAtIndexPath indexPath: NSIndexPath) -> Bool
public func tableView(tableView: UITableView, didHighlightRowAtIndexPath indexPath: NSIndexPath)
public func tableView(tableView: UITableView, didUnhighlightRowAtIndexPath indexPath: NSIndexPath)

// Called before the user changes the selection. Return a new indexPath, or nil, to change the proposed selection.
public func tableView(tableView: UITableView, willSelectRowAtIndexPath indexPath: NSIndexPath) -> NSIndexPath?
public func tableView(tableView: UITableView, willDeselectRowAtIndexPath indexPath: NSIndexPath) -> NSIndexPath?
// Called after the user changes the selection.
public func tableView(tableView: UITableView, didDeselectRowAtIndexPath indexPath: NSIndexPath)

// Editing

// Allows customization of the editingStyle for a particular cell located at 'indexPath'. If not implemented, all editable cells will have UITableViewCellEditingStyleDelete set for them when the table has editing property set to YES.
public func tableView(tableView: UITableView, editingStyleForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCellEditingStyle
public func tableView(tableView: UITableView, titleForDeleteConfirmationButtonForRowAtIndexPath indexPath: NSIndexPath) -> String?
public func tableView(tableView: UITableView, editActionsForRowAtIndexPath indexPath: NSIndexPath) -> [UITableViewRowAction]? // supercedes -tableView:titleForDeleteConfirmationButtonForRowAtIndexPath: if return value is non-nil

// Controls whether the background is indented while editing.  If not implemented, the default is YES.  This is unrelated to the indentation level below.  This method only applies to grouped style table views.
public func tableView(tableView: UITableView, shouldIndentWhileEditingRowAtIndexPath indexPath: NSIndexPath) -> Bool

// The willBegin/didEnd methods are called whenever the 'editing' property is automatically changed by the table (allowing insert/delete/move). This is done by a swipe activating a single row
public func tableView(tableView: UITableView, willBeginEditingRowAtIndexPath indexPath: NSIndexPath)
public func tableView(tableView: UITableView, didEndEditingRowAtIndexPath indexPath: NSIndexPath)

// Moving/reordering

// Allows customization of the target row for a particular row as it is being moved/reordered
public func tableView(tableView: UITableView, targetIndexPathForMoveFromRowAtIndexPath sourceIndexPath: NSIndexPath, toProposedIndexPath proposedDestinationIndexPath: NSIndexPath) -> NSIndexPath

// Indentation

public func tableView(tableView: UITableView, indentationLevelForRowAtIndexPath indexPath: NSIndexPath) -> Int // return 'depth' of row for hierarchies

// Copy/Paste.  All three methods must be implemented by the delegate.

public func tableView(tableView: UITableView, shouldShowMenuForRowAtIndexPath indexPath: NSIndexPath) -> Bool
public func tableView(tableView: UITableView, canPerformAction action: Selector, forRowAtIndexPath indexPath: NSIndexPath, withSender sender: AnyObject?) -> Bool
public func tableView(tableView: UITableView, performAction action: Selector, forRowAtIndexPath indexPath: NSIndexPath, withSender sender: AnyObject?)
}
*/