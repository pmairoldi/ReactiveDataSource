import UIKit
import ReactiveCocoa

public extension UITableViewCell {
    
    public var rac_prepareForReuse: SignalProducer<Void, NoError> {
        
        let signal = associatedObject(self, key: &reused) { self.rac_signalForSelector("prepareForReuse") }
        
        return signal.toSignalProducer()
            .mapError { $0 as! NoError }
            .map { _ in return }
    }
}

private var reused: UInt8 = 0