
import UIKit
import XCTest

class GPSLocationManagerTests: XCTestCase {
    
    var userModel:UserModel!
    var locationManager:GPSLocationManager!

    override func setUp() {
        super.setUp()
        userModel = UserModel()
        locationManager = GPSLocationManager(userModel: userModel)
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testLocationManagerInit(){
        XCTAssertNotNil(self.locationManager, "LocationManager should not be nil")
    }
    
}