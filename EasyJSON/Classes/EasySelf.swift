//
//  EasySelf.swift
//  EasyJSONDemo
//
//  Created by 荣浩 on 16/2/23.
//  Copyright © 2016年 荣浩. All rights reserved.
//

import Foundation
// MARK: Type
public enum EasyType {
    case Number
    case String
    case Bool
    case Array
    case Dictionary
    case Null
    case SelfDefining(NSString)
}

// MARK: - EasySelf
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

// MARK: - EasyProperty
class EasyProperty: NSObject {
    // MARK: - constant and veriable and property
    var name:String = ""
    var type:EasyType = .Null
    
    // MARK: - life cycle
    init(attributesStr: String) {
        super.init()
        self.analyzeAttributes(attributesStr)
    }
    
    // MARK: - private method
    private func analyzeAttributes(attributesStr: String) {
        let attributeItems = attributesStr.componentsSeparatedByString(",")
        for var index = 0; index < attributeItems.count; index++ {
            let item = attributeItems[index]
            if item.containsString("T") {
                if item.containsString("NSNumber") {
                    type = .Number
                }
                else if item.containsString("NSString") {
                    type = .String
                }
                else if item.containsString("NSArray") {
                    type = .Array
                }
                else if item.containsString("T@") {
                    type = .SelfDefining(self.getModelName(item))
                }
            }
            else if item.containsString("V") {
                name = item.stringByReplacingOccurrencesOfString("V", withString: "")
            }
        }
    }
    private func getModelName(item:String) ->String {
        //T@"_TtC12EasyJSONDemo10arrayModel"
        var regex: NSRegularExpression?
        do {
            regex = try NSRegularExpression(pattern: "[A-z.]+[0-9.]+", options: .CaseInsensitive)
        }
        catch let error as NSError {
            NSLog("正则异常：%@", error.code)
            return ""
        }
        let result = regex!.matchesInString(item, options: .ReportCompletion, range: NSMakeRange(0, item.lengthOfBytesUsingEncoding(NSUTF8StringEncoding)))
        let range = result[result.count-1].range
        let startIndex = item.startIndex.advancedBy(range.location+range.length)
        return item.substringFromIndex(startIndex).stringByReplacingOccurrencesOfString("\"", withString: "")
    }
}
