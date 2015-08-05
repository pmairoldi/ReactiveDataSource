internal extension Array {
    
    internal func atIndex(index: Int) -> Element? {
    
        guard index < count else {
            return nil
        }
        
        return self[index]
    }
}
