//
//  Util.swift
//  ReactiveTwitterSearch
//
//  Created by Colin Eberhardt on 10/05/2015.
//  Copyright (c) 2015 Colin Eberhardt. All rights reserved.
//

import UIKit
import ReactiveCocoa

struct AssociationKey {
    static var hidden: UInt8 = 1
    static var alpha: UInt8 = 2
    static var text: UInt8 = 3
    static var image: UInt8 = 4
    static var enabled: UInt8 = 5
    static var tap: UInt8 = 6
    static var attributedText: UInt8 = 7
    static var textColor: UInt8 = 8
    static var titleText: UInt8 = 9
    static var dataSource: UInt8 = 10
    static var prepareForReuse: UInt8 = 10
}

// lazily creates a gettable associated property via the given factory
func lazyAssociatedProperty<T: AnyObject>(host: AnyObject, key: UnsafePointer<Void>, factory: ()->T) -> T {
    var associatedProperty = objc_getAssociatedObject(host, key) as? T
    
    if associatedProperty == nil {
        associatedProperty = factory()
        objc_setAssociatedObject(host, key, associatedProperty, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN)
    }
    return associatedProperty!
}

func lazyMutableProperty<T>(host: AnyObject, key: UnsafePointer<Void>, setter: T -> (), getter: () -> T) -> MutableProperty<T> {
    return lazyAssociatedProperty(host, key: key) {
        let property = MutableProperty<T>(getter())
        property.producer
            .start(next: {
                newValue in
                setter(newValue)
            })
        return property
    }
}

extension UIView {
    public var rac_alpha: MutableProperty<CGFloat> {
        return lazyMutableProperty(self, key: &AssociationKey.alpha, setter: { self.alpha = $0 }, getter: { self.alpha  })
    }
    
    public var rac_hidden: MutableProperty<Bool> {
        return lazyMutableProperty(self, key: &AssociationKey.hidden, setter: { self.hidden = $0 }, getter: { self.hidden  })
    }
}

extension UIImageView {
    public var rac_image: MutableProperty<UIImage?> {
        return lazyMutableProperty(self, key: &AssociationKey.image, setter: { self.image = $0 }, getter: { self.image })
    }
}

extension UILabel {
    public var rac_text: MutableProperty<String> {
        return lazyMutableProperty(self, key: &AssociationKey.text, setter: { self.text = $0 }, getter: { self.text ?? "" })
    }
    
    public var rac_attributedText: MutableProperty<NSAttributedString> {
        return lazyMutableProperty(self, key: &AssociationKey.attributedText, setter: { self.attributedText = $0 }, getter: { self.attributedText ?? NSAttributedString(string: "") })
    }
    
    public var rac_textColor: MutableProperty<UIColor> {
        return lazyMutableProperty(self, key: &AssociationKey.textColor, setter: { self.textColor = $0 }, getter: { self.textColor ?? UIColor.blackColor() })
    }
}

extension UITextField {
    public var rac_text: MutableProperty<String> {
        return lazyAssociatedProperty(self, key: &AssociationKey.text) {
            
            self.addTarget(self, action: "changed", forControlEvents: UIControlEvents.EditingChanged)
            
            let property = MutableProperty<String>(self.text ?? "")
            property.producer
                .start(next: {
                    newValue in
                    self.text = newValue
                })
            return property
        }
    }
    
    func changed() {
        rac_text.value = self.text!
    }
}

extension UIControl {
    public var rac_enabled: MutableProperty<Bool> {
        return lazyMutableProperty(self, key: &AssociationKey.enabled, setter: { self.enabled = $0 }, getter: { self.enabled })
    }
}

extension UIButton {
    public var rac_title: MutableProperty<String> {
        return lazyMutableProperty(self, key: &AssociationKey.titleText, setter: { self.setTitle($0, forState: UIControlState.Normal) }, getter: { self.titleLabel?.text ?? "" })
    }
}

extension UITableViewCell {
    
    public var rac_prepareForReuse: SignalProducer<Void, NoError> {
        
        let signal = lazyAssociatedProperty(self, key: &AssociationKey.prepareForReuse) { self.rac_signalForSelector("prepareForReuse") }
        
        return signal.toSignalProducer()
            .mapError { $0 as! NoError }
            .map { _ in return }
    }
}
