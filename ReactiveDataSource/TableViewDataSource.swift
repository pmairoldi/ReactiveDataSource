import UIKit
import ReactiveCocoa

public class TableViewDataSource: NSObject, UITableViewDataSource {
    
    public let pushbackSignal: Signal<Actionable, NoError>
    public var proxy: UITableViewDataSourceProxy?
    
    private let pushbackAction: Action<Actionable, Actionable, NoError>
    private let data = RowData<Reusable>()
    private let NoCell = UITableViewCell()
    
    public init(tableView: UITableView, dataProducer: SignalProducer<[[Reusable]], NoError>) {
        self.pushbackAction = Action<Actionable, Actionable, NoError> { SignalProducer<Actionable, NoError>(value: $0) }
        self.pushbackSignal = self.pushbackAction.values
        
        super.init()
        
        self.data.property <~ dataProducer
        self.data.property.producer.start(next: { _ in
            tableView.reloadData()
        })
    }
    
    convenience public init(tableView: UITableView, dataProducer: SignalProducer<[Reusable], NoError>) {
        self.init(tableView: tableView, dataProducer: dataProducer.map { [$0] })
    }
    
    public func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.numberOfRows(inSection: section)
    }
    
    public func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        guard let item = data.item(atIndexPath: indexPath) else {
            print("no data at indexPath")
            return NoCell
        }
        
        let cell = tableView.dequeueReusableCellWithIdentifier(item.reuseIdentifier, forIndexPath: indexPath)
        
        if let bindableCell = cell as? Bindable {
            cell.rac_prepareForReuse.startWithSignal { signal, disposable in
                bindableCell.bind(item, pushback: pushbackAction, reuse: signal)
                signal.takeUntil(signal).observe(completed: { [weak cell] in let bindedCell = cell as? Bindable; bindedCell?.unbind() })
            }
        }
        
        return cell
    }
    
    public func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return data.numberOfSections()
    }
}

extension TableViewDataSource {
    
    public func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return proxy?.tableViewProxy?(tableView, titleForHeaderInSection: section)
    }
    
    public func tableView(tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        return proxy?.tableViewProxy?(tableView, titleForFooterInSection: section)
    }
    
    // Editing
    
    public func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return proxy?.tableViewProxy?(tableView, canEditRowAtIndexPath: indexPath) ?? false
    }
    
    // Moving/reordering
    
    public func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return proxy?.tableViewProxy?(tableView, canMoveRowAtIndexPath: indexPath) ?? false
    }
    
    // Index
    
    public func sectionIndexTitlesForTableView(tableView: UITableView) -> [String]? {
        return proxy?.sectionIndexTitlesForTableViewProxy?(tableView)
    }
    
    public func tableView(tableView: UITableView, sectionForSectionIndexTitle title: String, atIndex index: Int) -> Int {
        return proxy?.tableViewProxy?(tableView, sectionForSectionIndexTitle: title, atIndex: index) ?? index
    }
    
    // Data manipulation - insert and delete support
    
    public func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        proxy?.tableViewProxy?(tableView, commitEditingStyle: editingStyle, forRowAtIndexPath: indexPath)
    }
    
    // Data manipulation - reorder / moving support
    
    public func tableView(tableView: UITableView, moveRowAtIndexPath sourceIndexPath: NSIndexPath, toIndexPath destinationIndexPath: NSIndexPath) {
        proxy?.tableViewProxy?(tableView, moveRowAtIndexPath: sourceIndexPath, toIndexPath: destinationIndexPath)
    }
}
