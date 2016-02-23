//
//  Modelable.swift
//  EasyJSONDemo
//
//  Created by 荣浩 on 16/2/23.
//  Copyright © 2016年 荣浩. All rights reserved.
//

import Foundation
import SwiftyJSON


public protocol Modelable {
    func createModel(json: JSON)
    
    func specialMapping() -> [String: String]?
    func arrayElementToModel() -> [String: String]?
    func dictionaryToModel() -> [String: String]?
}

extension Modelable where Self: NSObject {
    public func createModel(json: JSON) {
        //special mapping
        let mappingDic = self.specialMapping()
        let easySelf = EasySelf(obj: self)
        for var i = 0; i < easySelf.propertyCount; i++ {
            let property = easySelf[i]
            //special mapping
            let orignKey = property?.name
            var key: String? = orignKey
            if (mappingDic != nil
                && mappingDic?.keys.contains(orignKey!) == true) {
                    key = mappingDic![orignKey!]!
            }
            
            switch property!.type {
            case .String:
                if json.type == Type.String {
                    self.setValue(json.string, forKey: orignKey!)
                }
                else if json.type == Type.Dictionary {
                    self.setValue(json[orignKey!].string, forKey: orignKey!)
                }
            case .Number:
                //setValue不支持Int,Float,Double
                let value = json[key!]
                self.setValue(value.numberValue, forKey: orignKey!)
            case .SelfDefining(let name):
                let cls = NSClassFromString(NSBundle.mainBundle().objectForInfoDictionaryKey("CFBundleName")!.description + "." + (name as String)) as? NSObject.Type
                let obj = cls!.init()
                obj.createModel(json[key!])
                self.setValue(obj, forKey: orignKey!)
            case .Array:
                let arrayDic = self.arrayElementToModel()
                if (arrayDic != nil
                    && arrayDic?.keys.contains(orignKey!) == true) {
                        let type = arrayDic![orignKey!]
                        if let cls = NSClassFromString(NSBundle.mainBundle().objectForInfoDictionaryKey("CFBundleName")!.description + "." + type!) as? NSObject.Type {
                            let subJsonArray = json[key!]
                            var subModelArray = [NSObject]()
                            for var i = 0; i < subJsonArray.count; i++ {
                                let obj = cls.init()
                                obj.createModel(subJsonArray[i])
                                subModelArray.append(obj)
                            }
                            self.setValue(subModelArray, forKey: orignKey!)
                        } else {
                            debugPrint("setup replace object class with error name!");
                        }
                }
                
            default:
                break
            }
        }
    }
}