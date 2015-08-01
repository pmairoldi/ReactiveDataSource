import UIKit
import ReactiveCocoa

public class TableViewDataSource: NSObject, UITableViewDataSource {
    
    public let pushbackSignal: Signal<Actionable, NoError>
    
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
