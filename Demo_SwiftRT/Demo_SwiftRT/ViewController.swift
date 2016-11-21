//
//  ViewController.swift
//  EasyJSONDemo
//
//  Created by 荣浩 on 16/2/19.
//  Copyright © 2016年 荣浩. All rights reserved.
//

import UIKit


class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        let test = testModel()
        test.createModel(with: ["test1":1 as AnyObject, "test2":"2", "test33":"3", "test4":["11","12","13"], "test5":["name":"RH"]])
        NSLog("%@", test.test1!)
        NSLog("%@", test.test4![0].age!)
        NSLog("%@", test.test5!.name!)
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}



open class testModel: NSObject {
    open var test1: NSNumber?   //Int, Float, Double ---> NSNumber
    open var test2: String?
    open var test3: String?
    open var test4: [arrayModel]?
    open var test5: dictionaryModel?
    
    open override func specialMapping() -> [String: String]? {
        return ["test3":"test33"]
    }
    
    open override func arrayElementToModel() -> [String: String]? {
        return ["test4":"arrayModel"]
    }
    
    override   open func dictionaryToModel() -> [String: String]? {
        return ["test5":"dictionaryModel"]
    }
}

open class dictionaryModel:NSObject {
    open var name: String?
}

open class arrayModel:NSObject {
    open var age: String?
}
