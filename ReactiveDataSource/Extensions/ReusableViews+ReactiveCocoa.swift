import UIKit
import ReactiveCocoa

public protocol ReactiveReuse {
    var reuseSignal: RACSignal { get }
}

public extension ReactiveReuse {
    
    public var rac_prepareForReuse: SignalProducer<Void, NoError> {
        
        return reuseSignal.toSignalProducer()
            .flatMapError { _ in SignalProducer<AnyObject?, NoError>.empty }
            .map { _ in return }
    }
}

extension UITableViewCell: ReactiveReuse {
    
    private struct Associated {
        static var reused: UInt8 = 0
    }

    public var reuseSignal: RACSignal {
        return associatedObject(self, key: &Associated.reused) { self.rac_signalForSelector("prepareForReuse") }
    }
}

extension UITableViewHeaderFooterView: ReactiveReuse {
    
    private struct Associated {
        static var reused: UInt8 = 0
    }
    
    public var reuseSignal: RACSignal {
        return associatedObject(self, key: &Associated.reused) { self.rac_signalForSelector("prepareForReuse") }
    }
}

extension UICollectionReusableView: ReactiveReuse {
    
    private struct Associated {
        static var reused: UInt8 = 0
    }
    
    public var reuseSignal: RACSignal {
        return associatedObject(self, key: &Associated.reused) { self.rac_signalForSelector("prepareForReuse") }
    }
}
