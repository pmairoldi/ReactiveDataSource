import UIKit
import ReactiveCocoa

//public extension UICollectionView {
//    
//    private struct Associated {
//        static var delegate: UInt8 = 0
//        static var dataSource: UInt8 = 0
//    }
//    
//    public var rac_delegate: CollectionViewDelegate? {
//        
//        get {
//            return objc_getAssociatedObject(self, &Associated.delegate) as? CollectionViewDelegate
//        }
//        
//        set(newValue) {
//            objc_setAssociatedObject(self, &Associated.delegate, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN)
//            
//            self.delegate = newValue
//        }
//    }
//    
//    public var rac_dataSource: CollectionViewDataSource? {
//        
//        get {
//            return objc_getAssociatedObject(self, &Associated.dataSource) as? CollectionViewDataSource
//        }
//        
//        set(newValue) {
//            objc_setAssociatedObject(self, &Associated.dataSource, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN)
//            
//            self.dataSource = newValue
//            newValue?.data.property.producer.startWithNext { [weak self] _ in self?.reloadData() }
//        }
//    }
//}
