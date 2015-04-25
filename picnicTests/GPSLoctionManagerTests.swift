
import UIKit
import XCTest
import BrightFutures

class GPSLocationManagerTests: XCTestCase {
    
    var userModel:UserModel!
    var locationManager:GPSLocationManagerSub!

    override func setUp() {
        super.setUp()
        userModel = UserModel()
        locationManager = GPSLocationManagerSub(userModel: userModel)
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testLocationManagerInit(){
        XCTAssertNotNil(self.locationManager, "LocationManager should not be nil")
    }
    
        
    func testGetCurrentLocaleSuccess(){
        let expectedLocale = NSLocale(localeIdentifier: "en_GB")
        let expectation = self.expectationWithDescription("delayed answer")
        
        locationManager.getUserCurrentLocale()
            .onSuccess { locale in
                XCTAssertEqual(locale.objectForKey(NSLocaleCountryCode) as! String, expectedLocale.objectForKey(NSLocaleCountryCode) as! String, "returned locale should be same country as expected locale")
                expectation.fulfill()
            }.onFailure {error in
                XCTAssert(false, "Get current user locale should not return error")
                expectation.fulfill()
            }
        
        self.waitForExpectationsWithTimeout(5, handler: nil)
    }
    
    func testGetCurrentLocaleFailure(){
        let expectedLocale = NSLocale(localeIdentifier: "en_GB")
        let expectation = self.expectationWithDescription("delayed answer")
        locationManager.shouldFail = true
        
        locationManager.getUserCurrentLocale()
            .onSuccess { locale in
                XCTAssert(false, "Should fail")
                expectation.fulfill()
            }.onFailure {error in
                XCTAssert(true, "Get current user locale should return error")
                expectation.fulfill()
        }
        
        self.waitForExpectationsWithTimeout(5, handler: nil)
        locationManager.shouldFail = false
    }
}