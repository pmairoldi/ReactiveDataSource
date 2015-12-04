import UIKit
import ReactiveCocoa

public final class CollectionViewDataSource<Provider: CollectionViewProvider>: NSObject, UICollectionViewDataSource {
    
    private let sections = MutableProperty<[Section<Provider.ItemType, Provider.HeaderType, Provider.FooterType>]>([])
    
    public init(_ sections: SignalProducer<[[Provider.ItemType]], NoError>, headers: SignalProducer<[Provider.HeaderType], NoError>? = nil, footers: SignalProducer<[Provider.FooterType], NoError>? = nil) {
        
        self.sections <~ mapSections(sections, headers: headers, footers: footers)
        
        super.init()
    }
    
    public convenience init(_ items: SignalProducer<[Provider.ItemType], NoError>, headers: SignalProducer<[Provider.HeaderType], NoError>? = nil, footers: SignalProducer<[Provider.FooterType], NoError>? = nil) {
        self.init(items.map { [$0] }, headers: headers, footers: footers)
    }
    
    public func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return sections.value.count
    }
    public func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return sections.value.atIndex(section)?.count ?? 0
    }
    
    public func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        guard let item = sections.value.atIndex(indexPath.section)?.atIndex(indexPath.row) else {
            return UICollectionViewCell()
        }
        
        return collectionView.dequeueReusableCellWithReuseIdentifier(Provider.reuseIdentifier(item), forIndexPath: indexPath)
    }
    
    public func collectionView(collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, atIndexPath indexPath: NSIndexPath) -> UICollectionReusableView {
        
        guard let item = sections.value.atIndex(indexPath.section) else {
            return UICollectionReusableView()
        }
        
        guard let reuseIdentifier = Provider.supplementaryReuseIdentifier(item, kind: SupplementaryElementKind(rawValue: kind)) else {
            return UICollectionReusableView()
        }
        
        return collectionView.dequeueReusableSupplementaryViewOfKind(kind, withReuseIdentifier: reuseIdentifier, forIndexPath: indexPath)
    }
}
