import ReactiveCocoa

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
