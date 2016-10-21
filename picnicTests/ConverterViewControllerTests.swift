//
//  ConverterViewControllerTest.swift
//  picnic
//
//  Created by Knut Nygaard on 5/5/15.
//  Copyright (c) 2015 Knut Nygaard. All rights reserved.
//

import UIKit
import XCTest

class ConverterViewControllerTests: XCTestCase {
    
    var userModel:UserModel!
    var vc:ConverterViewController!
    
    override func setUp() {
        super.setUp()
        vc = ConverterViewController()
        vc.storedFileName = "test.dat"
        vc.userModel = UserModel()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testDateAddDayExtension(){
        let date1 = Date().addDays(2)
        let date2 = Date()
        
        let interval = date1.timeIntervalSince(date2)
        XCTAssertGreaterThan(interval, 10000, "2 days is greater than 10000 ms")
    }
    
    func testDateSubtractDayExtension(){
        let date1 = Date().addDays(-2)
        let date2 = Date()
        
        let interval = date2.timeIntervalSince(date1)
        XCTAssertGreaterThan(interval, 10000, "2 days is greater than 10000 ms")
    }
}
