//
//  ViewControllerTest.swift
//  currencyolini
//
//  Created by Knut Nygaard on 25/02/15.
//  Copyright (c) 2015 Knut Nygaard. All rights reserved.
//

import Foundation
import UIKit
import XCTest

class ViewControllerTest : XCTestCase {
    
    let viewController = ViewController ()
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
        
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testInvalidNumberIsNotValid() {
        // This is an example of a functional test case.
        XCTAssertTrue(viewController.isValid(""), "Pass")
        XCTAssertTrue(viewController.isValid("1200"), "Pass")
        XCTAssertTrue(viewController.isValid("awd"), "")
//        XCTAssert(viewController.isValid("120,0"), "valid")
//        XCTAssert(viewController.isValid("0.120,0"), "invalid")
//        XCTAssert(viewController.isValid(",0,120,0"), "invalid")
//        XCTAssert(viewController.isValid("120,.,0"), "invalid")
//        XCTAssert(viewController.isValid("120,.0,"), "invalid")
//        XCTAssert(viewController.isValid("1200"), "valid")
    }
    
    

}
