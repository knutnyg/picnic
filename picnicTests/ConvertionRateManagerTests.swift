
import Foundation
import XCTest
import BrightFutures


class ConvertionRateManagerTests : XCTestCase {
    
    var conversionRateManagerIntegration = ConversionRateManager()
    var conversionRateManagerSub = ConversionRateManagerSub()
    
    func testIntegrationTestConversionRate(){
        var userModel = UserModel()
        userModel.currentLocale = NSLocale(localeIdentifier: "en_US")
        userModel.homeLocale = NSLocale(localeIdentifier: "nb_NO")
        conversionRateManagerIntegration.getConvertionRate(userModel)
            .onSuccess { conversionRate in
                XCTAssertNotNil(conversionRate, "value should not be nil")
                XCTAssertGreaterThan(conversionRate, 0, "value should be greater than 0")
            }.onFailure { error in
                XCTAssert(false, "Should get conversion rate")
            }
    }
    
    func testInvalidURL(){
        var userModel = UserModel()
        userModel.currentLocale = NSLocale(localeIdentifier: "en_US")
        userModel.homeLocale = NSLocale(localeIdentifier: "nb_NO")
        
        conversionRateManagerSub.getConvertionRate(userModel)
            .onSuccess { rate in
                XCTAssert(false, "this should not work")
            }
            .onFailure { error in
                XCTAssert(true, "should fail")
                XCTAssertEqual(error.code.description, "400", "Should return errorcode 400")
        }
    }
    
    func testDataParserFailsWithBadData(){
        var conversionRate = conversionRateManagerSub.getConversionRateFromResponse(NSData())
        XCTAssertNil(conversionRate, "should be nil")
    }
    
    func testConversionRateWithIllegalResponseValueIsNil(){
        var testbundle = NSBundle(forClass: ConvertionRateManagerTests.self)
        var url = testbundle.URLForResource("invalid_json", withExtension: "txt")!
        var data = NSData(contentsOfFile: url.path!)!
    
        var conversionRate = conversionRateManagerSub.getConversionRateFromResponse(data)
        XCTAssertNil(conversionRate, "should be nil")
    }
    
    func testGetURL(){
        var crm = ConversionRateManager()
        setBundleToTest(crm)
        crm.config = crm.loadConfig()
        
        var url = crm.getURL("NOK", currentCurrency: "DKK")?.description
        XCTAssertNotNil(url, "url should not be nil")
        
        if let u = url {
            XCTAssertEqual("http://example.com/example/api/NOK/DKK", url!, "URLS should match")
        }
    }
    
    func testMissingConfigFileThrowsException(){
        var cvr = ConversionRateManagerSub()
        cvr.configPath = "wrong"
        XCTAssertNil(cvr.loadConfig(), "loading config should fail: 404")
    }
    
    func testMalformedURLinConfig(){
        let expectation = self.expectationWithDescription("delayed answer")
        var userModel = UserModel()
        userModel.currentLocale = NSLocale(localeIdentifier: "en_US")
        userModel.homeLocale = NSLocale(localeIdentifier: "nb_NO")
        
        conversionRateManagerIntegration.config = ["api_url":"invalid url"]

        conversionRateManagerIntegration.getConvertionRate(userModel)
            .onFailure {error in
                XCTAssert(true, "invalid url should fail")
                expectation.fulfill()
            }
        self.waitForExpectationsWithTimeout(5, handler: nil)
    }
    
    func testMissingLocale(){
        let expectation = self.expectationWithDescription("delayed answer")
        var userModel = UserModel()
        userModel.homeLocale = NSLocale(localeIdentifier: "nb_NO")
        
        conversionRateManagerIntegration.getConvertionRate(userModel)
            .onFailure {error in
                XCTAssert(true, "missing locale should make conversion fail")
                expectation.fulfill()
        }
        self.waitForExpectationsWithTimeout(5, handler: nil)
    }
    
    func setBundleToTest(crm:ConversionRateManager){
        var bundle = NSBundle(forClass: ConvertionRateManagerTests.self)
        crm.configPath = bundle.pathForResource("config_test", ofType: "plist")
    }
}