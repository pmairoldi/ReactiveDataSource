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
        
        model = CollectionViewModel(collectionView: collectionView)
        
        collectionView.dataSource = model?.dataSource
        collectionView.delegate = self
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
    }
}

extension CollectionViewController {
    
    override func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        collectionView.deselectItemAtIndexPath(indexPath, animated: true)
    }
}