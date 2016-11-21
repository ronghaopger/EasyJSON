//
//  JSONable.swift
//  EasyJSONDemo
//
//  Created by 荣浩 on 16/2/23.
//  Copyright © 2016年 荣浩. All rights reserved.
//

import Foundation

public protocol JSONable {
    func toJSON() ->String?
}

extension JSONable where Self: NSObject {    
    public func toJSON() -> String? {
        do {
            let data = try JSONSerialization.data(withJSONObject: self, options: .prettyPrinted)
            return String(data: data, encoding: String.Encoding.utf8)
        }
        catch {
            debugPrint("error")
        }
        return nil
    }
}
