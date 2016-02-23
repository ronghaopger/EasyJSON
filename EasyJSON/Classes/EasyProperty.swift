//
//  EasyType.swift
//  EasyJSONDemo
//
//  Created by 荣浩 on 16/2/23.
//  Copyright © 2016年 荣浩. All rights reserved.
//

import UIKit

public enum EasyType {
    case Number
    case String
    case Bool
    case Array
    case Dictionary
    case Null
    case SelfDefining(NSString)
}

class EasyProperty: NSObject {
// MARK: - constant and veriable and property
    var name:String = ""
    var type:EasyType = .Null
    
// MARK: - life cycle
    init(attributesStr: String) {
        super.init()
        self.analyzeAttributes(attributesStr)
    }
    
    init(name:String, value:Any) {
        super.init()
        self.name = name
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
                    //T@"_TtC12EasyJSONDemo10arrayModel"
                    //TODO:用正则处理上述字符串
                    type = .SelfDefining("dictionaryModel")
                }
            }
            else if item.containsString("V") {
                name = item.stringByReplacingOccurrencesOfString("V", withString: "")
            }
        }
    }
}
