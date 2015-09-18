import UIKit
import ReactiveCocoa
import ReactiveDataSource

class CollectionViewCell: UICollectionViewCell, Bindable {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var buttonOne: UIButton!
    @IBOutlet weak var buttonTwo: UIButton!
    
    func bind<T>(viewModel: T, pushback: Action<Actionable, Actionable, NoError>?, reuse: Signal<Void, NoError>?) {
        
        guard let viewModel = viewModel as? CellViewModel else {
            return
        }
        
        titleLabel.rac_text <~ viewModel.text
        
        buttonOne.addTarget(viewModel.buttonOneAction.unsafeCocoaAction, action: CocoaAction.selector, forControlEvents: UIControlEvents.TouchUpInside)
        buttonTwo.addTarget(viewModel.buttonTwoAction.unsafeCocoaAction, action: CocoaAction.selector, forControlEvents: UIControlEvents.TouchUpInside)
        
        guard let reuse = reuse else {
            return
        }
        
        viewModel.buttonOneAction.values.takeUntil(reuse).observeNext { pushback?.apply(CellActions.Button1("Tapped Button 1 in Cell \(viewModel.text.value)")).start() }
        viewModel.buttonTwoAction.values.takeUntil(reuse).observeNext { pushback?.apply(CellActions.Button2("Tapped Button 2 in Cell \(viewModel.text.value)")).start() }
    }
    
    func unbind() {
        buttonOne?.removeTarget(nil, action: nil, forControlEvents: UIControlEvents.TouchUpInside)
        buttonTwo?.removeTarget(nil, action: nil, forControlEvents: UIControlEvents.TouchUpInside)
    }
    
    deinit {
        print("cell deinit")
    }
}