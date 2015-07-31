import UIKit
import ReactiveCocoa

public extension UITableViewHeaderFooterView {
    
    private struct Associated {
        static var reused: UInt8 = 0
    }
    
    public var rac_prepareForReuse: SignalProducer<Void, NoError> {
        
        let signal = associatedObject(self, key: &Associated.reused) { self.rac_signalForSelector("prepareForReuse") }
        
        return signal.toSignalProducer()
            .mapError { $0 as! NoError }
            .map { _ in return }
    }
}