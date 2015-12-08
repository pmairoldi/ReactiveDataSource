import UIKit
import ReactiveCocoa

public final class TableViewDataSource<Provider: TableViewProvider>: NSObject, UITableViewDataSource {
    
    private let sections = MutableProperty<[Section<Provider.ItemType, Provider.HeaderType, Provider.FooterType>]>([])
    
    public init(_ sections: SignalProducer<[[Provider.ItemType]], NoError>, headers: SignalProducer<[Provider.HeaderType], NoError>? = nil, footers: SignalProducer<[Provider.FooterType], NoError>? = nil) {
        
        self.sections <~ mapSections(sections, headers: headers, footers: footers)
        
        super.init()
    }
    
    public convenience init(_ items: SignalProducer<[Provider.ItemType], NoError>, headers: SignalProducer<[Provider.HeaderType], NoError>? = nil, footers: SignalProducer<[Provider.FooterType], NoError>? = nil) {
        self.init(items.map { [$0] }, headers: headers, footers: footers)
    }
    
    public func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return sections.value.count
    }
    
    public func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sections.value.atIndex(section)?.count ?? 0
    }
    
    public func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        guard let item = sections.value.atIndex(indexPath.section)?.atIndex(indexPath.row) else {
            return UITableViewCell()
        }
        
        return tableView.dequeueReusableCellWithIdentifier(Provider.reuseIdentifier(item), forIndexPath: indexPath)
    }
}
