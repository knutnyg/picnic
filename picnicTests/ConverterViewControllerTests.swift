//
//  ConverterViewControllerTest.swift
//  picnic
//
//  Created by Knut Nygaard on 5/5/15.
//  Copyright (c) 2015 Knut Nygaard. All rights reserved.
//

import UIKit
import XCTest
import BrightFutures

class ConverterViewControllerTests: XCTestCase {
    
    var userModel:UserModel!
    var vc:ConverterViewController!
    
    override func setUp() {
        super.setUp()
        vc = ConverterViewController()
        vc.userModel = UserModel()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testDateAddDayExtension(){
        var date1 = NSDate().addDays(2)
        var date2 = NSDate()
        
        let interval = date1.timeIntervalSinceDate(date2)
        XCTAssertGreaterThan(interval, 10000, "2 days is greater than 10000 ms")
    }
    
    func testDateSubtractDayExtension(){
        var date1 = NSDate().addDays(-2)
        var date2 = NSDate()
        
        let interval = date2.timeIntervalSinceDate(date1)
        XCTAssertGreaterThan(interval, 10000, "2 days is greater than 10000 ms")
    }

    func testNewDataIsNotOld(){
        var timestamp = NSDate().addHours(-10)
        XCTAssertFalse(vc.isDataOld(timestamp), "Should be false")
    }
    
    func testOldDataIsOld(){
        var timestamp = NSDate().addDays(-3)
        XCTAssertTrue(vc.isDataOld(timestamp), "Should be true")
    }

}
