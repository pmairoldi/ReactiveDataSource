import UIKit
import ReactiveCocoa

public protocol Actionable {
    // Imagine all the possiblities
}

public protocol Bindable {
    func bind<T>(viewModel: T, pushback: Action<Actionable, Actionable, NoError>)
}

public class TableConfiguration {
    
    private let cellReuseIdentifier: String
    private let headerTitle: (Int -> String?)?
    private let footerTitle: (Int -> String?)?
    private let pushbackAction: Action<Actionable, Actionable, NoError>

    public init(cellReuseIdentifier: String, headerTitle: (Int -> String?)? = nil, footerTitle: (Int -> String?)? = nil) {
        self.cellReuseIdentifier = cellReuseIdentifier
        self.headerTitle = headerTitle
        self.footerTitle = footerTitle
        self.pushbackAction = Action<Actionable, Actionable, NoError> { input in
            return SignalProducer<Actionable, NoError>(value: input)
        }
    }
    
    deinit {
        print("configuration deinit")
    }
}

public class DataSource: NSObject, UITableViewDataSource {
    
    public let pushbackSignal: Signal<Actionable, NoError>

    private let configuration: TableConfiguration
    private let tableView: UITableView
    
    public init(tableView: UITableView, configuration: TableConfiguration) {
        self.configuration = configuration
        self.tableView = tableView
        self.pushbackSignal = self.configuration.pushbackAction.values
    }
    
    public func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        
        guard let headerTitle = configuration.headerTitle else {
            return nil
        }
        
        return headerTitle(section)
    }
    
    public func tableView(tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        
        guard let footerTitle = configuration.footerTitle else {
            return nil
        }
        
        return footerTitle(section)
    }
    
    public func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 0
    }
    
    public func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        return tableView.dequeueReusableCellWithIdentifier(configuration.cellReuseIdentifier, forIndexPath: indexPath)
    }
    
    deinit {
        print("datasource deinit")
    }
}

public class SimpleDataSource<T, E: ErrorType>: DataSource {
    
    private let data = MutableProperty([T]())
    private let dataProducer: SignalProducer<[T], E>
    
    public init(tableView: UITableView, dataProducer: SignalProducer<[T], E>, configuration: TableConfiguration) {
        
        self.dataProducer = dataProducer
        
        super.init(tableView: tableView, configuration: configuration)
        
        dataProducer.start(next: { [weak self] value in
            self?.data.value = value
            self?.tableView.reloadData()
        })
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override public func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.value.count
    }
    
    override public func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier(configuration.cellReuseIdentifier, forIndexPath: indexPath)
        
        if let item = data.value.atIndex(indexPath.row), let reactiveView = cell as? Bindable {
            reactiveView.bind(item, pushback: configuration.pushbackAction)
        }
        
        return cell
    }
    
    deinit {
        print("simple datasource deinit")
    }
}

public class SectionedDataSource<T, E: ErrorType>: DataSource {
    
    private let data = MutableProperty([[T]]())
    private let dataProducer: SignalProducer<[[T]], E>
    
    public init(tableView: UITableView, dataProducer: SignalProducer<[[T]], E>, configuration: TableConfiguration) {
        
        self.dataProducer = dataProducer
        
        super.init(tableView: tableView, configuration: configuration)
        
        dataProducer.start(next: { [weak self] value in
            self?.data.value = value
            self?.tableView.reloadData()
            })
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return data.value.count
    }
    
    override public func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        guard let array = data.value.atIndex(section) else {
            return 0
        }
        
        return array.count
    }
    
    override public func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier(configuration.cellReuseIdentifier, forIndexPath: indexPath)
        
        if let item = data.value.atIndex(indexPath.section)?.atIndex(indexPath.row), let reactiveView = cell as? Bindable {
            reactiveView.bind(item, pushback: configuration.pushbackAction)
        }
        
        return cell
    }
    
    deinit {
        print("sectioned datasource deinit")
    }
}
