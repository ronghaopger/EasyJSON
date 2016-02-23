//
//  EasyJSON.swift
//  EasyJSON
//
//  Created by 荣浩 on 16/1/13.
//  Copyright © 2016年 荣浩. All rights reserved.
//

import SwiftyJSON

extension NSObject: Easyable {
    
    public func specialMapping() -> [String: String]? {
        return nil
    }
    
    public func arrayElementToModel() -> [String: String]? {
        return nil
    }
    
    public func dictionaryToModel() -> [String: String]? {
        return nil
    }
}

public protocol Easyable: Modelable, JSONable {
}

public protocol Modelable {
    func createModel(json: JSON)
    
    func specialMapping() -> [String: String]?
    func arrayElementToModel() -> [String: String]?
    func dictionaryToModel() -> [String: String]?
}

extension Modelable where Self: NSObject {
    public func createModel(json: JSON) {
        let mappingDic = self.specialMapping()
        let modelDic = self.dictionaryToModel()
        let arrayDic = self.arrayElementToModel()
        let mirror = Mirror(reflecting: self)
        for item in mirror.children {
            let orignKey = item.label!
            var key: String?
            if (mappingDic != nil
                && mappingDic?.keys.contains(orignKey) == true) {
                    key = mappingDic![orignKey]!
            }
            else {
                key = orignKey
            }
            if (modelDic != nil
                && modelDic?.keys.contains(orignKey) == true) {
                    let type = modelDic![orignKey]!
                    if let cls = NSClassFromString(NSBundle.mainBundle().objectForInfoDictionaryKey("CFBundleName")!.description + "." + type) as? NSObject.Type {
                        let obj = cls.init()
                        obj.createModel(json[key!])
                        self.setValue(obj, forKey: orignKey)
                    } else {
                        debugPrint("setup replace object class with error name!");
                    }
            }
            else if (arrayDic != nil
                && arrayDic?.keys.contains(orignKey) == true) {
                    let type = arrayDic![orignKey]!
                    if let cls = NSClassFromString(NSBundle.mainBundle().objectForInfoDictionaryKey("CFBundleName")!.description + "." + type) as? NSObject.Type {
                        let subJsonArray = json[key!]
                        var subModelArray = [NSObject]()
                        for var i = 0; i < subJsonArray.count; i++ {
                            let obj = cls.init()
                            obj.createModel(subJsonArray[i])
                            subModelArray.append(obj)
                        }
                        self.setValue(subModelArray, forKey: orignKey)
                    } else {
                        debugPrint("setup replace object class with error name!");
                    }
            }
            else {
                if (json.type == .String) {
                    self.setValue(json.string, forKey: orignKey)
                }
                else {
                    let value = json[key!]
                    if (value.type == .Null) {
                        continue
                    }
                    else if (value.type == .Number) {
                        //setValue不支持Int,Float,Double
                        self.setValue(value.numberValue, forKey: orignKey)
                    }
                    else {
                        self.setValue(value.string, forKey: orignKey)
                    }
                }
            }
        }
    }
    
}

public protocol JSONable {
    func toJSON() ->String?
}

extension JSONable where Self: NSObject {
    public func toJSON() -> String? {
        do {
            let data = try NSJSONSerialization.dataWithJSONObject(self, options: .PrettyPrinted)
            return String(data: data, encoding: NSUTF8StringEncoding)
        }
        catch {
            debugPrint("error")
        }
        return nil
    }
}