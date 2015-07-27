import UIKit
import ReactiveCocoa
import ReactiveDataSource

class CollectionViewCell: UICollectionViewCell, Bindable {
    
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
            viewModel.buttonOneAction.values.takeUntil(signal).observe(next: { pushback.apply(CellActions.Button1("Tapped Button 1 in Cell \(viewModel.text.value)")).start() })
            viewModel.buttonTwoAction.values.takeUntil(signal).observe(next: { pushback.apply(CellActions.Button2("Tapped Button 2 in Cell \(viewModel.text.value)")).start() })
        }
    }
    
    override func prepareForReuse() {

        super.prepareForReuse()

        buttonOne?.removeTarget(nil, action: nil, forControlEvents: UIControlEvents.TouchUpInside)
        buttonTwo?.removeTarget(nil, action: nil, forControlEvents: UIControlEvents.TouchUpInside)
    }
}