import ReactiveCocoa

public protocol Actionable {
    // Imagine all the possiblities
}

public protocol Bindable {
    typealias ViewModelType
    
    func bind(viewModel: ViewModelType, pushback: Action<Actionable, Actionable, NoError>?)
    func unbind()
}

public protocol Reusable {
    var reuseIdentifier: String { get }
}

public protocol Adjustable {
    var height: CGFloat { get }
    var estimatedHeight: CGFloat { get }
}

public protocol Supplementable: Reusable {
    var supplementaryElementKind: String { get }
    var supplementaryReuseIdentifier: String { get }
}

public protocol Selectable {
    func select(indexPath: NSIndexPath, action: Action<Actionable, Actionable, NoError>?)
}
