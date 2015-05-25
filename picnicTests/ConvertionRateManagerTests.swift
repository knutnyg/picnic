
import Foundation
import XCTest


class ConvertionRateManagerTests : XCTestCase {

    var userModel:UserModel!
    var conversionRateManagerSub:ConversionRateManagerSub!
    var conversionRateManagerIntegration:ConversionRateManager!
    
    override func setUp() {
        super.setUp()
        userModel = UserModel()
        conversionRateManagerIntegration = ConversionRateManager(userModel: userModel)
        conversionRateManagerIntegration.storedFileName = "test.dat"
        conversionRateManagerSub = ConversionRateManagerSub(userModel: userModel)
        conversionRateManagerSub.storedFileName = "test.dat"
        // Put setup code here. This method is called before the invocation of each test method in the class.
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
    
    func testMissingConfigFileThrowsException(){
        var cvr = ConversionRateManagerSub(userModel: userModel)
        cvr.configPath = "wrong"
        XCTAssertNil(cvr.loadConfig(), "loading config should fail: 404")
    }
    
    func testGetAllCurrencies(){
        let expectation = self.expectationWithDescription("delayed answer")
        conversionRateManagerIntegration.updateAllCurrencies(
            success: {success in
                if success {
                    expectation.fulfill()
                }
            })
        self.waitForExpectationsWithTimeout(10, handler: nil)
        XCTAssert(true, "finished without errors")
    }
    
    func testGetAllCurrenciesURL(){
        var crm = ConversionRateManager(userModel: userModel)
        setBundleToTest(crm)
        crm.config = crm.loadConfig()
        
        var URL = crm.getAllCurrenciesURL()!
        var expected = "http://example.com/api/currencies"
        
        XCTAssertEqual(URL.description,expected,"should be equal")
        
    }
    
    func testSavingAndLoadingOfflineDataFile(){
        var dict:[String:OfflineEntry] = [:]
        dict["NOK"] = OfflineEntry(timeStamp: NSDate(), unit_from: "USD", unit_to: "NOK", value: 2)
        saveDictionaryToDisk("test.dat", dict)
        
        var loadedDict = readOfflineDateFromDisk("test.dat")
        XCTAssertNotNil(loadedDict, "shouldNotBeNil")
    }
    
    func testLoadingNilShouldNotCrashApp(){
        var result = readOfflineDateFromDisk("doesNotExist.dat")
        XCTAssertNil(result, "should be nil!")
    }
    
    func setBundleToTest(crm:ConversionRateManager){
        var bundle = NSBundle(forClass: ConvertionRateManagerTests.self)
        crm.configPath = bundle.pathForResource("config_test", ofType: "plist")
    }
    
}