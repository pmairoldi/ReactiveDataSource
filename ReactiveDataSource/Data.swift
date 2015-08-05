import Foundation
import ReactiveCocoa

internal class RowData<T> {
    
    internal let property = MutableProperty([[T]]())
    
    func numberOfSections() -> Int {
        return property.value.count
    }
    
    func numberOfRows(inSection section: Int) -> Int {
        guard let array = property.value.atIndex(section) else {
            return 0
        }
        return array.count
    }
    
    func item(atIndexPath indexPath: NSIndexPath) -> T? {
        return property.value.atIndex(indexPath.section)?.atIndex(indexPath.row)
    }
}

internal class SectionData<T> {
    
    internal let property = MutableProperty([T]())
    
    func item(inSection section: Int) -> T? {
        return property.value.atIndex(section)
    }
}
