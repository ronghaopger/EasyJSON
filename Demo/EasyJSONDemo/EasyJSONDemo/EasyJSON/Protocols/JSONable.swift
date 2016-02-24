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
//        do {
//            let data = try NSJSONSerialization.dataWithJSONObject(self, options: .PrettyPrinted)
//            return String(data: data, encoding: NSUTF8StringEncoding)
//        }
//        catch {
//            debugPrint("error")
//        }
        return ""
    }
}