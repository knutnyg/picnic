
import Foundation
import XCTest
import BrightFutures


class ConvertionRateManagerTests : XCTestCase {
    
    var conversionRateManagerIntegration = ConversionRateManager()
    var conversionRateManagerSub = ConversionRateManagerSub()
    
    func testIntegrationTestConversionRate(){
        let expectation = self.expectationWithDescription("delayed answer")
        
        var userModel = UserModel()
        userModel.currentLocale = NSLocale(localeIdentifier: "en_US")
        userModel.homeLocale = NSLocale(localeIdentifier: "nb_NO")
        conversionRateManagerIntegration.getConvertionRate(userModel)
            .onSuccess { conversionRate in
                XCTAssertNotNil(conversionRate.value, "value should not be nil")
                XCTAssertLessThan(conversionRate.value, 1, "value should be less than 1")
                expectation.fulfill()
            }.onFailure { error in
                XCTAssert(false, "Should get conversion rate")
                expectation.fulfill()
            }
        self.waitForExpectationsWithTimeout(5, handler: nil)
    }
    
    func testInvalidURL(){
        let expectation = self.expectationWithDescription("delayed answer")
        var userModel = UserModel()
        userModel.currentLocale = NSLocale(localeIdentifier: "en_US")
        userModel.homeLocale = NSLocale(localeIdentifier: "nb_NO")
        
        conversionRateManagerSub.getConvertionRate(userModel)
            .onSuccess { rate in
                XCTAssert(false, "this should not work")
                expectation.fulfill()
            }
            .onFailure { error in
                XCTAssert(true, "should fail")
                XCTAssertEqual(error.code.description, "3840", "Should return errorcode 3840")
                expectation.fulfill()
        }
        self.waitForExpectationsWithTimeout(5, handler: nil)
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
        
        var url = crm.getConversionURL("NOK", currentCurrency: "DKK")?.description
        XCTAssertNotNil(url, "url should not be nil")
        
        if let u = url {
            XCTAssertEqual("http://example.com/api/exchange/NOK/DKK", url!, "URLS should match")
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
        
        var crm = ConversionRateManager()
        crm.config = ["api_url":"invalid url"]

        crm.getConvertionRate(userModel)
            .onSuccess{conv in
                XCTAssert(false, "should fail!")
            }
            .onFailure {error in
                XCTAssert(true, "invalid url should fail")
                expectation.fulfill()
            }
        self.waitForExpectationsWithTimeout(5, handler: nil)
    }
    
    func testMissingLocale(){
        let expectation = self.expectationWithDescription("delayed answer")
        var userModel = UserModel()
        userModel.homeLocale = nil
        
        conversionRateManagerIntegration.getConvertionRate(userModel)
            .onFailure {error in
                XCTAssert(true, "missing locale should make conversion fail")
                expectation.fulfill()
        }
        self.waitForExpectationsWithTimeout(5, handler: nil)
    }
    
    func testGetAllCurrencies(){
        let expectation = self.expectationWithDescription("delayed answer")
        conversionRateManagerIntegration.getAllCurrencies()
            .onSuccess {dict in
                XCTAssert(true, "should succeed")
                expectation.fulfill()
        }
            .onFailure{error in
                XCTAssert(false, "should succeed")
                expectation.fulfill()
        }
        self.waitForExpectationsWithTimeout(10, handler: nil)
    }
    
    func testGetAllCurrenciesURL(){
        var crm = ConversionRateManager()
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
    
    func testFallbackToOffline(){
        let expectation = self.expectationWithDescription("delayed answer")
        
        var dict:[String:OfflineEntry] = [:]
        dict["NOK"] = OfflineEntry(timeStamp: NSDate(), unit_from: "USD", unit_to: "NOK", value: 0.2)
        dict["SEK"] = OfflineEntry(timeStamp: NSDate(), unit_from: "USD", unit_to: "SEK", value: 0.3)
        
        var userModel = UserModel()
        userModel.currentLocale = NSLocale(localeIdentifier: "se_SE")
        userModel.homeLocale = NSLocale(localeIdentifier: "nb_NO")
        
        userModel.offlineData = dict
        
        var crm = ConversionRateManager()
        crm.config = ["api_url":"www.awdadawdawdawgiufbflawif.com/"]
        
        crm.getConvertionRate(userModel)
            .onSuccess{conv in
                XCTAssert(true, "should be picked up by fallback")
                XCTAssertGreaterThan(conv.value, 1, "should be positive")
                expectation.fulfill()
            }
            .onFailure {error in
                XCTAssert(true, "invalid url should fail")
                expectation.fulfill()
        }
        self.waitForExpectationsWithTimeout(5, handler: nil)

    }
    
    func testOldFallbackDataShowsAgeLabel(){
        let expectation = self.expectationWithDescription("delayed answer")
        var conv = ConverterViewController()
        conv.viewDidLoad()
        
        
        var dict:[String:OfflineEntry] = [:]
        dict["NOK"] = OfflineEntry(timeStamp: NSDate().addDays(-5), unit_from: "USD", unit_to: "NOK", value: 0.2)
        dict["SEK"] = OfflineEntry(timeStamp: NSDate().addDays(-5), unit_from: "USD", unit_to: "SEK", value: 0.3)
        
        var userModel = UserModel()
        userModel.currentLocale = NSLocale(localeIdentifier: "se_SE")
        userModel.homeLocale = NSLocale(localeIdentifier: "nb_NO")
        
        userModel.offlineData = dict
        
        var crm = ConversionRateManager()
        crm.config = ["api_url":"www.awdadawdawdawgiufbflawif.com/"]
        
        conv.conversionRateManager = crm
        conv.userModel = userModel
        
        conv.fetchCurrency()
        
        delay(1, {expectation.fulfill()})
        self.waitForExpectationsWithTimeout(5, handler: nil)
        
        XCTAssertTrue(conv.dataAgeLabel.text!.contains("Last updated"), "Data age label should be set")
    }
    
    func testNewFallbackDataShowsEmptyAgeLabel(){
        let expectation = self.expectationWithDescription("delayed answer")
        var conv = ConverterViewController()
        conv.viewDidLoad()
        
        
        var dict:[String:OfflineEntry] = [:]
        dict["NOK"] = OfflineEntry(timeStamp: NSDate(), unit_from: "USD", unit_to: "NOK", value: 0.2)
        dict["SEK"] = OfflineEntry(timeStamp: NSDate(), unit_from: "USD", unit_to: "SEK", value: 0.3)
        
        var userModel = UserModel()
        userModel.currentLocale = NSLocale(localeIdentifier: "se_SE")
        userModel.homeLocale = NSLocale(localeIdentifier: "nb_NO")
        
        userModel.offlineData = dict
        
        var crm = ConversionRateManager()
        crm.config = ["api_url":"www.awdadawdawdawgiufbflawif.com/"]
        
        conv.conversionRateManager = crm
        conv.userModel = userModel
        
        conv.fetchCurrency(completion: {expectation.fulfill()})
        
        self.waitForExpectationsWithTimeout(5, handler: nil)
        XCTAssertTrue(conv.dataAgeLabel.text!.isEmpty, "Data age label should be empty")
    }
    
    func testConversionRateFallback(){
        let expectation = self.expectationWithDescription("delayed answer")
        var conv = ConverterViewController()
        conv.viewDidLoad()
        
        
        var dict:[String:OfflineEntry] = [:]
        dict["NOK"] = OfflineEntry(timeStamp: NSDate(), unit_from: "USD", unit_to: "NOK", value: 0.125)
        dict["USD"] = OfflineEntry(timeStamp: NSDate(), unit_from: "USD", unit_to: "USD", value: 1)
        
        var userModel = UserModel()
        userModel.currentLocale = NSLocale(localeIdentifier: "en_US")
        userModel.homeLocale = NSLocale(localeIdentifier: "nb_NO")
        
        userModel.offlineData = dict
        
        var crm = ConversionRateManager()
        crm.config = ["api_url":"www.awdadawdawdawgiufbflawif.com/"]
        
        conv.conversionRateManager = crm
        conv.userModel = userModel
        
        conv.fetchCurrency(completion: {expectation.fulfill()})

        
        self.waitForExpectationsWithTimeout(5, handler: nil)
        
        XCTAssertGreaterThan(conv.userModel.convertionRate!, 1, "Should be grater than 1")
    }
    
}