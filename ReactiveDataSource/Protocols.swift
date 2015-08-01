import Foundation
import ReactiveCocoa

public protocol Actionable {
    // Imagine all the possiblities
}

public protocol Bindable {
    func bind(viewModel: Reusable, pushback: Action<Actionable, Actionable, NoError>?, reuse: Signal<Void, NoError>?)
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