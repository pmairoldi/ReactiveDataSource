import UIKit
import ReactiveDataSource
import ReactiveCocoa

class CollectionViewController: UICollectionViewController {
    
    /// Make sure that the dataSource is a strong reference
    /// UICollectionView's dataSource property is marked weak
    /// so it will be deallocated if not retained properly
    lazy var model: CollectionViewModel = {
       return CollectionViewModel()
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard let collectionView = collectionView else {
            return
        }
        
        collectionView.registerNib(UINib(nibName: "CollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "Cell")
        
        let layout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        layout.minimumInteritemSpacing = 10
        layout.minimumLineSpacing = 10
        layout.itemSize = CGSizeMake(CGRectGetWidth(collectionView.frame)/2 - layout.sectionInset.left - layout.minimumInteritemSpacing/2, CGRectGetWidth(collectionView.frame)/2 - layout.sectionInset.top - layout.minimumLineSpacing/2)
        
        collectionView.dataSource = model.dataSource
        collectionView.delegate = model.delegate
        collectionView.collectionViewLayout = layout
        
        model.delegate.pushback.values.observeNext(pushbackAction())
        model.delegate.selection.values.observeNext(selectionAction())
    }
    
    deinit {
        print("controller deinit")
    }
}
