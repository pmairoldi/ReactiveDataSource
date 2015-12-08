import UIKit

public enum SupplementaryElementKind {
    case Header
    case Footer
    
    public init(rawValue: String) {
        if rawValue == UICollectionElementKindSectionFooter {
            self = .Footer
        } else {
            self = .Header
        }
    }
    
    public var rawValue: String {
        switch self {
        case .Header:
            return UICollectionElementKindSectionHeader
        case .Footer:
            return UICollectionElementKindSectionFooter
        }
    }
}
