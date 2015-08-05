import UIKit
import ReactiveDataSource
import ReactiveCocoa

class CollectionViewController: UICollectionViewController {
    
    /// Make sure that the dataSource is a strong reference
    /// UICollectionView's dataSource property is marked weak 
    /// so it will be deallocated if not retained properly
    var model: CollectionViewModel?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard let collectionView = collectionView else {
            return
        }
        
        let layout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        layout.minimumInteritemSpacing = 10
        layout.minimumLineSpacing = 10
        layout.itemSize = CGSizeMake(CGRectGetWidth(collectionView.frame)/2 - layout.sectionInset.left - layout.minimumInteritemSpacing/2, CGRectGetWidth(collectionView.frame)/2 - layout.sectionInset.top - layout.minimumLineSpacing/2)
        
        model = CollectionViewModel()
        
        collectionView.rac_dataSource = model?.dataSource
        collectionView.rac_delegate = model?.delegate
        collectionView.collectionViewLayout = layout
        
        model?.dataSource.pushbackSignal.observe(next: { [weak self] value in
            switch value {
            case let CellActions.Button1(x):
                self?.displayMessage("Action", message: x)
            case let CellActions.Button2(x):
                self?.displayMessage("Action", message: x)
            default:
                print("noop")
            }
        })
        
        model?.delegate.selectionSignal.observe(next: { [weak self] value in
            
            let navController = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("ReactiveCollectionView") as! UINavigationController
            
            switch value as! SelectionActions  {
            case .Push:
                self?.navigationController?.pushViewController(navController.viewControllers[0], animated: true)
            case .Pop:
                self?.navigationController?.presentViewController(navController, animated: true, completion: nil)
            }
        })
    }
    
    deinit {
        print("controller deinit")
    }
}