
import Foundation
import UIKit
import XCTest
import BrightFutures

class LocationManagerTests: XCTestCase {
    
    var userModel:UserModel!
    var locationManager:LocationManagerSub!
    
    override func setUp() {
        super.setUp()
        userModel = UserModel()
        locationManager = LocationManagerSub(userModel: userModel)
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }


    func testHomeLocaleReturnsWithNoOverride(){
        let locale = locationManager.getUserHomeLocale(false)
        let expectedLocale = NSLocale(localeIdentifier: "nb_NO")
        XCTAssertEqual(locale.objectForKey(NSLocaleCountryCode) as! String, expectedLocale.objectForKey(NSLocaleCountryCode) as! String, "returned locale should be same country as expected locale")
    }

    func testHomeLocaleReturnsOverride(){
        userModel.shouldOverrideLogical = true
        let overrideLocale = NSLocale(localeIdentifier: "en_GB")
        userModel.overrideLogicalLocale = overrideLocale
        
        let locale = locationManager.getUserHomeLocale(true)
        XCTAssertEqual(locale.objectForKey(NSLocaleCountryCode) as! String, overrideLocale.objectForKey(NSLocaleCountryCode) as! String, "returned locale should be the one set to override")
        
        userModel.shouldOverrideLogical = false
        userModel.overrideLogicalLocale = nil
    }
    
    func testCurrentLocaleSuccess(){
        let expectedLocale = NSLocale(localeIdentifier: "en_GB")
        let expectation = self.expectationWithDescription("delayed answer")
        
        locationManager.getUserCurrentLocale(false)
            .onSuccess { locale in
                XCTAssertEqual(locale.objectForKey(NSLocaleCountryCode) as! String, expectedLocale.objectForKey(NSLocaleCountryCode) as! String, "returned locale should be same country as expected locale")
                expectation.fulfill()
            }
            .onFailure { error in
                XCTAssert(true, "Get current user locale should return error")
                expectation.fulfill()
        }
        self.waitForExpectationsWithTimeout(5, handler: nil)
    }
    
    func testCurrentLocaleWithOverrideSuccess(){
        let expectedLocale = NSLocale(localeIdentifier: "nb_NO")
        let expectation = self.expectationWithDescription("delayed answer")
        userModel.shouldOverrideGPS = true
        userModel.overrideGPSLocale = NSLocale(localeIdentifier: "nb_NO")
        
        locationManager.getUserCurrentLocale(true)
            .onSuccess { locale in
                XCTAssertEqual(locale.objectForKey(NSLocaleCountryCode) as! String, expectedLocale.objectForKey(NSLocaleCountryCode) as! String, "returned locale should be same country as expected locale")
                expectation.fulfill()
            }
            .onFailure { error in
                XCTAssert(true, "Get current user locale should return error")
                expectation.fulfill()
        }
        self.waitForExpectationsWithTimeout(5, handler: nil)
    }
    
    func testCurrentLocaleWithOverrideInvalidData(){
        let expectation = self.expectationWithDescription("delayed answer")
        userModel.shouldOverrideGPS = true
        userModel.overrideGPSLocale = nil
        
        locationManager.getUserCurrentLocale(true)
            .onSuccess { locale in
                XCTAssert(false, "Should fail")
                expectation.fulfill()
            }.onFailure {error in
                XCTAssert(true, "Get current user locale should return error")
                expectation.fulfill()
            }
        self.waitForExpectationsWithTimeout(5, handler: nil)
    }
    
    func testCurrentLocaleWithGPSFailWithGSMSuccess(){
        let expectedLocale = NSLocale(localeIdentifier: "nb_NO")
        let expectation = self.expectationWithDescription("delayed answer")
        
        (locationManager.gpsLocationManager as! GPSLocationManagerSub).shouldFail = true

        locationManager.getUserCurrentLocale(false)
            .onSuccess { locale in
                XCTAssertEqual(locale.objectForKey(NSLocaleCountryCode) as! String, expectedLocale.objectForKey(NSLocaleCountryCode) as! String, "returned locale should be same country as expected locale")
                expectation.fulfill()
            }
            .onFailure { error in
                XCTAssert(true, "Get current user locale should return error")
                expectation.fulfill()
        }
        self.waitForExpectationsWithTimeout(5, handler: nil)
    }
    
    func testCurrentLocaleWithGPSFailWithGSMFail(){
        let expectedLocale = NSLocale(localeIdentifier: "nb_NO")
        let expectation = self.expectationWithDescription("delayed answer")
        
        (locationManager.gpsLocationManager as! GPSLocationManagerSub).shouldFail = true
        (locationManager.celluarLocationManager as! CelluarLocationManagerSub).shouldFail = true
        
        locationManager.getUserCurrentLocale(false)
            .onSuccess { locale in
                XCTAssert(false, "Should fail")
                expectation.fulfill()
            }.onFailure {error in
                XCTAssert(true, "Get current user locale should return error")
                expectation.fulfill()        }
        self.waitForExpectationsWithTimeout(5, handler: nil)
    }
}