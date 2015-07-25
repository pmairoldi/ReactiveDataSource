internal extension Array {
    
    internal func atIndex(index: Int) -> Element? {
        if index >= count {
            return nil
        } else {
            return self[index]
        }
    }
}