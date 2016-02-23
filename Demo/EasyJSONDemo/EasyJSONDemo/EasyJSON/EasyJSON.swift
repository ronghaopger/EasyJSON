//
//  EasyJSON.swift
//  EasyJSON
//
//  Created by 荣浩 on 16/1/13.
//  Copyright © 2016年 荣浩. All rights reserved.
//

import Foundation

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