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
    case number
    case string
    case bool
    case array
    case dictionary
    case null
    case selfDefining(String)
}

// MARK: - EasySelf
class EasySelf: NSObject {
    // MARK: - constant and veriable and property
    private var propertyArray = [EasyProperty]()
    
    var PropertyCount: Int {
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
    private func analyzeSelf(_ type: AnyClass) {
        var propertyCount = UInt32()
        let properties = class_copyPropertyList(type, &propertyCount);
        for propertyIndex: UInt32 in 0 ..< propertyCount {
            let attributes = property_getAttributes(properties?[Int(propertyIndex)])
            let propertyAttributes = String(cString: attributes!)
            //            NSLog("%@", propertyAttributes!)
            let propertyType = EasyProperty(attributesStr: propertyAttributes)
            propertyArray.append(propertyType)
        }
    }
}

// MARK: - EasyProperty
class EasyProperty: NSObject {
    // MARK: - constant and veriable and property
    var name:String = ""
    var type:EasyType = .null
    
    // MARK: - life cycle
    init(attributesStr: String) {
        super.init()
        self.analyzeAttributes(attributesStr)
    }
    
    // MARK: - private method
    private func analyzeAttributes(_ attributesStr: String) {
        let attributeItems = attributesStr.components(separatedBy: ",")
        for index in 0 ..< attributeItems.count {
            let item = attributeItems[index]
            if item.contains("T") {
                if item.contains("NSNumber") {
                    type = .number
                }
                else if item.contains("NSString") {
                    type = .string
                }
                else if item.contains("NSArray") {
                    type = .array
                }
                else if item.contains("T@") {
                    type = .selfDefining(self.getModelName(item))
                }
            }
            else if item.contains("V") {
                name = item.replacingOccurrences(of: "V", with: "")
            }
        }
    }
    private func getModelName(_ item:String) ->String {
        //T@"_TtC12EasyJSONDemo10arrayModel"
        var regex: NSRegularExpression?
        do {
            regex = try NSRegularExpression(pattern: "[A-z.]+[0-9.]+", options: .caseInsensitive)
        }
        catch let error as NSError {
            NSLog("正则异常：%@", error.code)
            return ""
        }
        let result = regex!.matches(in: item, options: .reportCompletion, range: NSMakeRange(0, item.lengthOfBytes(using: String.Encoding.utf8)))
        let range = result[result.count-1].range
        let startIndex = item.characters.index(item.startIndex, offsetBy: range.location+range.length)
        return item.substring(from: startIndex).replacingOccurrences(of: "\"", with: "")
    }
}
