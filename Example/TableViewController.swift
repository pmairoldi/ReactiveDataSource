import UIKit
import ReactiveDataSource
import ReactiveCocoa

class TableViewController: UITableViewController {
    
    //    lazy var refreshAction: CocoaAction = CocoaAction(self.viewModel.refresh, input: ())
    
    var dataSource: SectionedDataSource<CellViewModel, NoError>?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let viewModels = [1,2,3,4,5,6].map { CellViewModel(value: $0) }
        
        let configuration = TableConfiguration(cellReuseIdentifier: "ReuseIdentifier")
        
        let dataProducer = SignalProducer<[[CellViewModel]], NoError> { sink, disposable in
            sendNext(sink, [viewModels])
        }
        
        dataSource = SectionedDataSource(tableView: tableView, dataProducer: dataProducer, configuration: configuration)
        
        tableView.dataSource = dataSource
        tableView.delegate = self
        
        dataSource?.pushbackSignal.observe(next: { value in
            switch value {
            case let Actions.Button1(x):
                print(x)
            case let Actions.Button2(x):
                print(x)
            default:
                print("noop")
            }
        })
        
        guard let refreshControl = refreshControl else {
            return
        }
        
        let refreshAction = Action<UIRefreshControl, UIRefreshControl, NoError> { input in SignalProducer(value: input) }
        
        defer {
            refreshAction.apply(refreshControl).start()
        }
        
        refreshAction.values.observeOn(UIScheduler()).observe(next: { print($0); $0.endRefreshing() })

        refreshControl.addTarget(refreshAction.unsafeCocoaAction, action: CocoaAction.selector, forControlEvents: UIControlEvents.ValueChanged)
        
    }
    
    deinit {
        print("table deinit")
    }
}

struct CellViewModel {
    let text: MutableProperty<String>
    let buttonOneAction: Action<UIButton, Void, NoError>
    let buttonTwoAction: Action<UIButton, Void, NoError>
    
    init(value: Int) {
        self.text = MutableProperty("\(value)")
        self.buttonOneAction = Action<UIButton, Void, NoError> { _ in SignalProducer(value: ()) }
        self.buttonTwoAction = Action<UIButton, Void, NoError> { _ in SignalProducer(value: ()) }
    }
}

enum Actions: Actionable {
    case Button1(String)
    case Button2(String)
}

class Cell: UITableViewCell, Bindable {
    
    @IBOutlet weak var titleLabel: UILabel?
    @IBOutlet weak var buttonOne: UIButton?
    @IBOutlet weak var buttonTwo: UIButton?
    
    func bind<T>(viewModel: T, pushback: Action<Actionable, Actionable, NoError>) {
        
        guard let viewModel = viewModel as? CellViewModel else {
            return
        }
        
        guard
            let titleLabel = titleLabel,
            let buttonOne = buttonOne,
            let buttonTwo = buttonTwo
            else {
                return
        }
        
        titleLabel.rac_text <~ viewModel.text
        
        buttonOne.addTarget(viewModel.buttonOneAction.unsafeCocoaAction, action: CocoaAction.selector, forControlEvents: UIControlEvents.TouchUpInside)
        buttonTwo.addTarget(viewModel.buttonTwoAction.unsafeCocoaAction, action: CocoaAction.selector, forControlEvents: UIControlEvents.TouchUpInside)
        
        rac_prepareForReuse.startWithSignal { signal, disposable in
            viewModel.buttonOneAction.values.takeUntil(signal).observe(next: { pushback.apply(Actions.Button1(viewModel.text.value + " one")).start() })
            viewModel.buttonTwoAction.values.takeUntil(signal).observe(next: { pushback.apply(Actions.Button2(viewModel.text.value + " two")).start() })
        }
    }
    
    deinit {
        print("cell deinit")
    }
}

extension TableViewController {
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
}