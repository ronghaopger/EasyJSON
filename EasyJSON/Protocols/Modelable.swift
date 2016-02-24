//
//  Modelable.swift
//  EasyJSONDemo
//
//  Created by 荣浩 on 16/2/23.
//  Copyright © 2016年 荣浩. All rights reserved.
//

import Foundation


public protocol Modelable {
    func createModel(jsonStr:String)
    func createModel(jsonObj: AnyObject)
    
    func specialMapping() -> [String: String]?
    func arrayElementToModel() -> [String: String]?
}

extension Modelable where Self: NSObject {
    public func createModel(jsonStr:String) {
        var jsonObject: AnyObject?
        do {
            jsonObject = try NSJSONSerialization.JSONObjectWithData((jsonStr.dataUsingEncoding(NSUTF8StringEncoding))!, options: .AllowFragments)
        }
        catch let error as NSError {
            NSLog("%@", error.code)
            return
        }
        self.createModel(jsonObject!)
    }
    
    
    public func createModel(jsonObj: AnyObject) {
        //special mapping
        let mappingDic = self.specialMapping()
        //analyze self
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
                if let value = jsonObj as? String {
                    self.setValue(value, forKey: orignKey!)
                }
                else if let value = jsonObj as? [String:AnyObject] {
                    self.setValue(value[key!], forKey: orignKey!)
                }
            case .Number:
                //setValue不支持Int,Float,Double
                let value = jsonObj[key!] as? NSNumber
                self.setValue(value, forKey: orignKey!)
            case .SelfDefining(let name):
                let value = jsonObj as! [String:AnyObject]
                let obj = self.createObj(name as String)
                obj.createModel(value[key!]!)
                self.setValue(obj, forKey: orignKey!)
            case .Array:
                let typeName = self.getElementType(orignKey!)
                let value = jsonObj as! [String:AnyObject]
                let subJsonArray = value[key!] as! [AnyObject]
                var subModelArray = [NSObject]()
                for var i = 0; i < subJsonArray.count; i++ {
                    let obj = self.createObj(typeName)
                    obj.createModel(subJsonArray[i])
                    subModelArray.append(obj)
                }
                self.setValue(subModelArray, forKey: orignKey!)
            default:
                break
            }
        }
    }
    
// MARK: private method
    private func createObj(typeName:String) ->NSObject {
        let cls = NSClassFromString(NSBundle.mainBundle().objectForInfoDictionaryKey("CFBundleName")!.description + "." + typeName) as? NSObject.Type
        let obj = cls!.init()
        return obj
    }
    
    private func getElementType(key:String) ->String {
        let arrayDic = self.arrayElementToModel()
        if (arrayDic != nil && arrayDic?.keys.contains(key) == true) {
            return arrayDic![key]!
        }
        return ""
    }
}