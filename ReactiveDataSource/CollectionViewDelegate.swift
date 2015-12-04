import UIKit
import ReactiveCocoa

public final class CollectionViewDelegate<Provider: CollectionViewProvider>: NSObject, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    private let sections = MutableProperty<[Section<Provider.ItemType, Provider.HeaderType, Provider.FooterType>]>([])
    
    public let selection = Action<Actionable, Actionable, NoError> { SignalProducer(value: $0) }
    public let pushback = Action<Actionable, Actionable, NoError> { SignalProducer(value: $0) }
    
    public init(_ sections: SignalProducer<[[Provider.ItemType]], NoError>, headers: SignalProducer<[Provider.HeaderType], NoError>? = nil, footers: SignalProducer<[Provider.FooterType], NoError>? = nil) {
        
        self.sections <~ mapSections(sections, headers: headers, footers: footers)
        
        super.init()
    }
    
    public convenience init(_ items: SignalProducer<[Provider.ItemType], NoError>, headers: SignalProducer<[Provider.HeaderType], NoError>? = nil, footers: SignalProducer<[Provider.FooterType], NoError>? = nil) {
        self.init(items.map { [$0] }, headers: headers, footers: footers)
    }
    
    public func collectionView(collectionView: UICollectionView, willDisplayCell cell: UICollectionViewCell, forItemAtIndexPath indexPath: NSIndexPath) {
        
        guard let item = sections.value.atIndex(indexPath.section)?.atIndex(indexPath.row) else {
            return
        }
        
        let completedClosure: () -> () = { [weak cell] in
            (cell as? Bindable)?.unbind()
        }
        
        //TODO: add viewmodel
        cell.rac_prepareForReuse.startWithSignal { signal, disposable in
            (cell as? Bindable)?.bind(item, pushback: pushback, reuse: signal)
            signal.takeUntil(signal).observeCompleted(completedClosure)
        }
    }
    
    public func collectionView(collectionView: UICollectionView, didEndDisplayingCell cell: UICollectionViewCell, forItemAtIndexPath indexPath: NSIndexPath) {
        
        guard let cell = cell as? Bindable else {
            return
        }
        
        cell.unbind()
    }
    
    public func collectionView(collectionView: UICollectionView, willDisplaySupplementaryView view: UICollectionReusableView, forElementKind elementKind: String, atIndexPath indexPath: NSIndexPath) {
        
        guard let item = sections.value.atIndex(indexPath.section) else {
            return
        }
        
        Provider.bind(supplementaryView: view, to: item, ofKind: SupplementaryElementKind(rawValue: elementKind), pushback: pushback)
    }
    
    public func collectionView(collectionView: UICollectionView, didEndDisplayingSupplementaryView view: UICollectionReusableView, forElementOfKind elementKind: String, atIndexPath indexPath: NSIndexPath) {
        
        guard let item = sections.value.atIndex(indexPath.section) else {
            return
        }
        
        Provider.unbind(supplementaryView: view, from: item, ofKind: SupplementaryElementKind(rawValue: elementKind))
    }
    
    public func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        
        guard let item = sections.value.atIndex(indexPath.section)?.atIndex(indexPath.row) else {
            return
        }
        
        Provider.select(item, indexPath: indexPath, selection: selection)
    }
    
    //    public func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
    //
    //        guard let flowLayout = collectionViewLayout as? UICollectionViewFlowLayout else {
    //            return CGSizeZero
    //        }
    //
    //        guard let item = sections.value.atIndex(indexPath.section)?.atIndex(indexPath.row) else {
    //            return CGSizeZero
    //        }
    //
    //        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(Provider.reuseIdentifier(item), forIndexPath: indexPath)
    //
    //        Provider.bind(cell: binableCell, to: item, pushback: pushback)
    //
    //        if let binableCell = cell as? UICollectionViewCell {
    //        }
    //
    //        return cell.sizeForCollectionView(collectionView, flowLayout: flowLayout)
    //    }
    
    public func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        
        guard let flowLayout = collectionViewLayout as? UICollectionViewFlowLayout else {
            return CGSizeZero
        }
        
        guard let item = sections.value.atIndex(section) else {
            return CGSizeZero
        }
        
        let supplementaryView = Provider.sizingSupplementaryView(item, kind: .Header)
        
        if let binableReusableView = supplementaryView as? UICollectionReusableView {
            Provider.bind(supplementaryView: binableReusableView, to: item, ofKind: .Header, pushback: pushback)
        }
        
        return supplementaryView?.sizeForCollectionView(collectionView, flowLayout: flowLayout) ?? flowLayout.headerReferenceSize
    }
    
    public func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {
        
        guard let flowLayout = collectionViewLayout as? UICollectionViewFlowLayout else {
            return CGSizeZero
        }
        
        guard let item = sections.value.atIndex(section) else {
            return CGSizeZero
        }
        
        let supplementaryView = Provider.sizingSupplementaryView(item, kind: .Footer)
        
        if let binableReusableView = supplementaryView as? UICollectionReusableView {
            Provider.bind(supplementaryView: binableReusableView, to: item, ofKind: .Footer, pushback: pushback)
        }
        
        return supplementaryView?.sizeForCollectionView(collectionView, flowLayout: flowLayout) ?? flowLayout.footerReferenceSize
    }
}
