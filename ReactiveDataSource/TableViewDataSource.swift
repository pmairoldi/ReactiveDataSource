import UIKit
import ReactiveCocoa

public struct TableViewConfiguration {
    
    private let headerTitle: (Int -> String?)?
    private let footerTitle: (Int -> String?)?
    
    public init(headerTitle: (Int -> String?)? = nil, footerTitle: (Int -> String?)? = nil) {
        self.headerTitle = headerTitle
        self.footerTitle = footerTitle
    }
}

public class TableViewDataSource: NSObject, UITableViewDataSource {
    
    public let pushbackSignal: Signal<Actionable, NoError>
    
    private let configuration: TableViewConfiguration?
    private let pushbackAction: Action<Actionable, Actionable, NoError>
    private let data = Data<Reusable>()
    
    public init(tableView: UITableView, dataProducer: SignalProducer<[[Reusable]], NoError>, configuration: TableViewConfiguration? = nil) {
        self.configuration = configuration
        self.pushbackAction = Action<Actionable, Actionable, NoError> { SignalProducer<Actionable, NoError>(value: $0) }
        self.pushbackSignal = self.pushbackAction.values
        
        super.init()
        
        self.data.property <~ dataProducer
        self.data.property.producer.start(next: { _ in
            tableView.reloadData()
        })
    }
    
    convenience public init(tableView: UITableView, dataProducer: SignalProducer<[Reusable], NoError>, configuration: TableViewConfiguration? = nil) {
        self.init(tableView: tableView, dataProducer: dataProducer.map { value in [value] }, configuration: configuration)
    }
    
    private func headerTitle(section: Int) -> String? {
        
        guard let headerTitle = configuration?.headerTitle else {
            return nil
        }
        
        return headerTitle(section)
    }
    
    private func footerTitle(section: Int) -> String? {
        
        guard let footerTitle = configuration?.footerTitle else {
            return nil
        }
        
        return footerTitle(section)
    }
    
    public func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.numberOfRows(inSection: section)
    }
    
    public func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        guard let item = data.item(atIndexPath: indexPath) else {
            print("no data at indexPath")
            return UITableViewCell()
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
    
    public func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return headerTitle(section)
    }
    
    public func tableView(tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        return footerTitle(section)
    }
}

/*
extension TableViewDataSource {

// Editing
public func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
return false
}

// Moving/reordering
public func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
return false
}

// Index
public func sectionIndexTitlesForTableView(tableView: UITableView) -> [String]? {
return nil
}

public func tableView(tableView: UITableView, sectionForSectionIndexTitle title: String, atIndex index: Int) -> Int {
return index
}

// Data manipulation - insert and delete support

public func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {

}

// Data manipulation - reorder / moving support
public func tableView(tableView: UITableView, moveRowAtIndexPath sourceIndexPath: NSIndexPath, toIndexPath destinationIndexPath: NSIndexPath) {

}
}
*/