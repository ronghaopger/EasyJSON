//
//  Modelable.swift
//  EasyJSONDemo
//
//  Created by 荣浩 on 16/2/23.
//  Copyright © 2016年 荣浩. All rights reserved.
//

import Foundation

public protocol Modelable {
    func createModel(with jsonStr: String)
    func createModel(with jsonObj: AnyObject)
    
    func specialMapping() -> [String: String]?
    func arrayElementToModel() -> [String: String]?
}

extension Modelable where Self: NSObject {
    public func createModel(with jsonStr:String) {
        var jsonObject: AnyObject
        do {
            jsonObject = try JSONSerialization.jsonObject(with: (jsonStr.data(using: String.Encoding.utf8))!, options: .allowFragments) as AnyObject
        }
        catch let error as NSError {
            NSLog("%@", error.code)
            return
        }
        createModel(with: jsonObject)
    }
    
    
    public func createModel(with jsonObj: AnyObject) {
        //special mapping
        let mappingDic = specialMapping()
        //analyze self
        let easySelf = EasySelf(obj: self)
        for i in 0..<easySelf.PropertyCount {
            let property = easySelf[i]
            //special mapping
            let orignKey = property?.name
            var key: String? = orignKey
            if (mappingDic != nil
                && mappingDic?.keys.contains(orignKey!) == true) {
                    key = mappingDic![orignKey!]!
            }
            
            switch property!.type {
            case .string:
                if let value = jsonObj as? String {
                    self.setValue(value, forKey: orignKey!)
                }
                else if let value = jsonObj as? [String:AnyObject] {
                    self.setValue(value[key!], forKey: orignKey!)
                }
            case .number:
                //setValue不支持Int,Float,Double
                let value = jsonObj[key!] as? NSNumber
                self.setValue(value, forKey: orignKey!)
            case .selfDefining(let name):
                let value = jsonObj as! [String:AnyObject]
                let obj = self.createObj(with: name)
                obj.createModel(with: value[key!]!)
                self.setValue(obj, forKey: orignKey!)
            case .array:
                let typeName = self.getElementType(with: orignKey!)
                let value = jsonObj as! [String:AnyObject]
                let subJsonArray = value[key!] as! [AnyObject]
                var subModelArray = [NSObject]()
                for i in 0 ..< subJsonArray.count {
                    let obj = self.createObj(with: typeName)
                    obj.createModel(with: subJsonArray[i])
                    subModelArray.append(obj)
                }
                self.setValue(subModelArray, forKey: orignKey!)
            default:
                break
            }
        }
    }
    
// MARK: private method
    private func createObj(with typeName:String) ->NSObject {
        let cls = NSClassFromString((Bundle.main.object(forInfoDictionaryKey: "CFBundleName")! as AnyObject).description + "." + typeName) as? NSObject.Type
        let obj = cls!.init()
        return obj
    }
    
    private func getElementType(with key:String) ->String {
        let arrayDic = self.arrayElementToModel()
        if (arrayDic != nil && arrayDic?.keys.contains(key) == true) {
            return arrayDic![key]!
        }
        return ""
    }
}
