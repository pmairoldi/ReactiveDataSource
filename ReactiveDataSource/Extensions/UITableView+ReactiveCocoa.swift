import UIKit
import ReactiveCocoa

public extension UITableView {
    
    private struct Associated {
        static var delegate: UInt8 = 0
        static var dataSource: UInt8 = 0
    }
    
    public var rac_delegate: TableViewDelegate? {
        
        get {
            return objc_getAssociatedObject(self, &Associated.delegate) as? TableViewDelegate
        }
        
        set(newValue) {
            objc_setAssociatedObject(self, &Associated.delegate, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN)
            
            self.delegate = newValue
        }
    }
    
    public var rac_dataSource: TableViewDataSource? {
        
        get {
            return objc_getAssociatedObject(self, &Associated.dataSource) as? TableViewDataSource
        }
        
        set(newValue) {
            objc_setAssociatedObject(self, &Associated.dataSource, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN)
            
            self.dataSource = newValue
            newValue?.data.property.producer.startWithNext { [weak self] _ in self?.reloadData() }
        }
    }
}
