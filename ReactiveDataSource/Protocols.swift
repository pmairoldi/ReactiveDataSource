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
