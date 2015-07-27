import Foundation
import ReactiveCocoa

public protocol Actionable {
    // Imagine all the possiblities
}

public protocol Bindable {
    func bind<T>(viewModel: T, pushback: Action<Actionable, Actionable, NoError>)
}