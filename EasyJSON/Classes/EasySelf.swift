//
//  EasySelf.swift
//  EasyJSONDemo
//
//  Created by 荣浩 on 16/2/23.
//  Copyright © 2016年 荣浩. All rights reserved.
//

import Foundation

class EasySelf: NSObject {
    // MARK: - constant and veriable and property
    private var propertyArray = [EasyProperty]()
    
    var propertyCount: Int? {
        get {
            return propertyArray.count
        }
    }
    
    subscript(index: Int) ->EasyProperty? {
        get {
            return propertyArray[index]
        }
    }
    
// MARK: - life cycle
    internal init(obj: NSObject) {
        super.init()
        self.analyzeSelf(obj.classForCoder)
    }


// MARK: - public method
    
    
// MARK: - private method
    private func analyzeSelf(type: AnyClass) {
        var propertyCount = UInt32()
        let properties = class_copyPropertyList(type, &propertyCount);
        for var propertyIndex: UInt32 = 0; propertyIndex < propertyCount; propertyIndex++ {
            let attributes = property_getAttributes(properties[Int(propertyIndex)])
            let propertyAttributes = String.fromCString(attributes)
            //            NSLog("%@", propertyAttributes!)
            let propertyType = EasyProperty(attributesStr: propertyAttributes!)
            propertyArray.append(propertyType)
        }
    }
}
