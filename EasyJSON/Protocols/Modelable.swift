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
                let cls = NSClassFromString(NSBundle.mainBundle().objectForInfoDictionaryKey("CFBundleName")!.description + "." + (name as String)) as? NSObject.Type
                let obj = cls!.init()
                let value = jsonObj as! [String:AnyObject]
                obj.createModel(value[key!]!)
                self.setValue(obj, forKey: orignKey!)
            case .Array:
                let arrayDic = self.arrayElementToModel()
                if (arrayDic != nil
                    && arrayDic?.keys.contains(orignKey!) == true) {
                        let type = arrayDic![orignKey!]
                        if let cls = NSClassFromString(NSBundle.mainBundle().objectForInfoDictionaryKey("CFBundleName")!.description + "." + type!) as? NSObject.Type {
                            let value = jsonObj as! [String:AnyObject]
                            let subJsonArray = value[key!] as! [AnyObject]
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