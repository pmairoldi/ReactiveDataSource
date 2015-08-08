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
        
        model?.dataSource.pushbackSignal.observe(next: pushbackAction())
        model?.delegate.selectionSignal.observe(next: selectionAction())
    }
    
    deinit {
        print("controller deinit")
    }
}
