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
//        test.createModel(["test1":1, "test2":"2", "test33":"3", "test4":["11","12","13"], "test5":["name":"RH"]])
        test.createModel("{\"test1\":1,\"test2\":\"2\",\"test33\":\"3\",\"test4\":[\"11\",\"12\",\"13\"],\"test5\":{\"name\":\"RH\"}}")
        NSLog("%@", test.test1!)
        NSLog("%@", test.test3!)
        NSLog("%@", test.test4![0].age!)
        NSLog("%@", test.test5!.name!)
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}



public class testModel: NSObject {
    public var test1: NSNumber?   //Int, Float, Double ---> NSNumber
    public var test2: String?
    public var test3: String?
    public var test4: [arrayModel]?
    public var test5: dictionaryModel?
    
    public override func specialMapping() -> [String: String]? {
        return ["test3":"test33"]
    }
    
    public override func arrayElementToModel() -> [String: String]? {
        return ["test4":"arrayModel"]
    }
}

public class dictionaryModel:NSObject {
    public var name: String?
}

public class arrayModel:NSObject {
    required override public init() {
        super.init()
    }
    public var age: String?
}
