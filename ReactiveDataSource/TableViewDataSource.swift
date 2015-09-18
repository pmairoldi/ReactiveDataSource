import UIKit
import ReactiveCocoa

public class TableViewDataSource: NSObject, UITableViewDataSource {
    
    public let pushbackSignal: Signal<Actionable, NoError>

    internal let data = RowData<Reusable>()

    private let pushbackAction: Action<Actionable, Actionable, NoError>
    private let NoCell = UITableViewCell()
    
    public init(dataProducer: SignalProducer<[[Reusable]], NoError>) {
       
        pushbackAction = Action<Actionable, Actionable, NoError> { SignalProducer<Actionable, NoError>(value: $0) }
        pushbackSignal = pushbackAction.values
        
        data.property <~ dataProducer
    
        super.init()
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
            
            let completedClosure: () -> () = { [weak cell] in
                (cell as? Bindable)?.unbind()
            }
            
            cell.rac_prepareForReuse.startWithSignal { signal, disposable in
                bindableCell.bind(item, pushback: pushbackAction, reuse: signal)
                signal.takeUntil(signal).observeCompleted(completedClosure)
            }
        }
        
        return cell
    }
    
    public func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return data.numberOfSections()
    }
}

extension TableViewDataSource {
    
    convenience public init(dataProducer: SignalProducer<[Reusable], NoError>) {
        self.init(dataProducer: dataProducer.map { [$0] })
    }
    
    convenience public init(dataProducer: SignalProducer<Reusable, NoError>) {
        self.init(dataProducer: dataProducer.map { [[$0]] })
    }
}
