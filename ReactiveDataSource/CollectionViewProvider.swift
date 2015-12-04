import UIKit
import ReactiveCocoa

public protocol SizableCollectionView {
    func sizeForCollectionView(collectionView: UICollectionView, flowLayout: UICollectionViewFlowLayout) -> CGSize
}

public struct Section<Item, Header, Footer> {
    
    private let items: [Item]
    
    public let header: Header?
    public let footer: Footer?
    
    public init(items: [Item], header: Header? = nil, footer: Footer? = nil) {
        self.items = items
        self.header = header
        self.footer = footer
    }
    
    public var count: Int {
        return items.count
    }
    
    public func atIndex(index: Int) -> Item? {
        return items.atIndex(index)
    }
}

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

public protocol CollectionViewProvider {
    
    typealias ItemType
    typealias HeaderType
    typealias FooterType
    
    static func reuseIdentifier(item: ItemType) -> String
    static func supplementaryReuseIdentifier(item: Section<ItemType, HeaderType, FooterType>, kind: SupplementaryElementKind) -> String?
    
    static func sizingCell(item: ItemType) -> SizableCollectionView
    static func sizingSupplementaryView(item: Section<ItemType, HeaderType, FooterType>, kind: SupplementaryElementKind) -> SizableCollectionView?
    
    static func select(item: ItemType, indexPath: NSIndexPath, selection: Action<Actionable, Actionable, NoError>)
    
    static func bind(cell cell: UICollectionViewCell, to item: ItemType, pushback: Action<Actionable, Actionable, NoError>)
    static func unbind(cell cell: UICollectionViewCell, from item: ItemType)
    
    static func bind(supplementaryView supplementaryView: UICollectionReusableView, to item: Section<ItemType, HeaderType, FooterType>, ofKind kind: SupplementaryElementKind, pushback: Action<Actionable, Actionable, NoError>)
    static func unbind(supplementaryView supplementaryView: UICollectionReusableView, from item: Section<ItemType, HeaderType, FooterType>, ofKind kind: SupplementaryElementKind)
}

//MARK: Mapping to Section

private func mapSections<ItemType, HeaderType, FooterType>(sections: SignalProducer<[[ItemType]], NoError>, headers: SignalProducer<[HeaderType], NoError>, footers: SignalProducer<[FooterType], NoError>) -> SignalProducer<[Section<ItemType, HeaderType, FooterType>], NoError> {
    
    return combineLatest(sections, headers, footers).map { sections, headers, footers  in
        return zip(sections, zip(headers, footers)).map { items, supplementary in
            return Section(items: items, header: supplementary.0, footer: supplementary.1)
        }
    }
}

private func mapSections<ItemType, HeaderType, FooterType>(sections: SignalProducer<[[ItemType]], NoError>, headers: SignalProducer<[HeaderType], NoError>) -> SignalProducer<[Section<ItemType, HeaderType, FooterType>], NoError> {
    
    return combineLatest(sections, headers).map { sections, headers  in
        return zip(sections, headers).map { items, header in
            return Section(items: items, header: header, footer: nil)
        }
    }
}

private func mapSections<ItemType, HeaderType, FooterType>(sections: SignalProducer<[[ItemType]], NoError>, footers: SignalProducer<[FooterType], NoError>) -> SignalProducer<[Section<ItemType, HeaderType, FooterType>], NoError> {
    
    return combineLatest(sections, footers).map { sections, footers  in
        return zip(sections, footers).map { items, footer in
            return Section(items: items, header: nil, footer: footer)
        }
    }
}

private func mapSections<ItemType, HeaderType, FooterType>(sections: SignalProducer<[[ItemType]], NoError>) -> SignalProducer<[Section<ItemType, HeaderType, FooterType>], NoError> {
    
    return sections.map { sections in
        return sections.map { items in
            return Section(items: items, header: nil, footer: nil)
        }
    }
}

public func mapSections<ItemType, HeaderType, FooterType>(sections: SignalProducer<[[ItemType]], NoError>, headers: SignalProducer<[HeaderType], NoError>?, footers: SignalProducer<[FooterType], NoError>?) -> SignalProducer<[Section<ItemType, HeaderType, FooterType>], NoError> {
    
    switch (headers, footers) {
    case let (.Some(headers), .Some(footers)):
        return mapSections(sections, headers: headers, footers: footers)
    case let (.Some(headers), .None):
        return mapSections(sections, headers: headers)
    case let (.None, .Some(footers)):
        return mapSections(sections, footers: footers)
    case (.None, .None):
        return mapSections(sections)
    }
}
