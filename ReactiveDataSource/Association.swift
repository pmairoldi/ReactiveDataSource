//
//  Association.swift
//  Rex
//
//  Created by Neil Pankey on 6/19/15.
//  Copyright (c) 2015 Neil Pankey. All rights reserved.
//

import ReactiveCocoa

/// On first use attaches the object returned from `initial` to the `host` object
/// using `key` via `objc_setAssociatedObject`. On subsequent usage, returns said
/// object via `objc_getAssociatedObject`.
internal func associatedObject<T: AnyObject>(host: AnyObject, key: UnsafePointer<()>, initial: () -> T) -> T {
    var value = objc_getAssociatedObject(host, key) as? T
    if value == nil {
        value = initial()
        objc_setAssociatedObject(host, key, value, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN)
    }
    return value!
}
