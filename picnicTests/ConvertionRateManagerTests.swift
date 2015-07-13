
import Foundation
import XCTest


class ConvertionRateManagerTests : XCTestCase {

    var userModel:UserModel!
//    var conversionRateManagerSub:ConversionRateManagerSub!
//    var conversionRateManagerIntegration:ConversionRateManager!
    
    override func setUp() {
        super.setUp()
        userModel = UserModel()
    }
    
    func testMissingConfigFileThrowsException(){
        
        var cvr = ConversionRateManager(userModel: userModel)
        cvr.configPath = "wrong"
        XCTAssertNil(cvr.loadConfig(), "loading config should fail: 404")
    }
    
    func testGetAllCurrenciesIllegalResponse(){
        var crm = ConversionRateManager(userModel: userModel)
        setBundleToTest(crm)
        crm.config = crm.loadConfig()
        
        var URL = crm.getAllCurrenciesURL()!
        var expected = "http://example.com/api/currencies"
        
        XCTAssertEqual(URL.description,expected,"should be equal")
    }
    
    func testGetAllCurrenciesURL(){
        var crm = ConversionRateManager(userModel: userModel)
        setBundleToTest(crm)
        crm.config = crm.loadConfig()
        
        var URL = crm.getAllCurrenciesURL()!
        var expected = "http://example.com/api/currencies"
        
        XCTAssertEqual(URL.description,expected,"should be equal")
        
    }
    
    func testOfflineConversionRate(){
        var userModel = UserModel()
        var crm = ConversionRateManager(userModel: userModel)
        
        var dict:[String:OfflineEntry] = [:]
        dict["NOK"] = OfflineEntry(timeStamp: NSDate(), unit_from: "USD", unit_to: "NOK", value: 8)
        dict["USD"] = OfflineEntry(timeStamp: NSDate(), unit_from: "USD", unit_to: "USD", value: 1)
        dict["SEK"] = OfflineEntry(timeStamp: NSDate(), unit_from: "USD", unit_to: "SEK", value: 10)
        
        var norLocale = NSLocale(localeIdentifier: "nb_NO")
        var usdLocale = NSLocale(localeIdentifier: "en_US")
        var seLocale = NSLocale(localeIdentifier: "se_SE")
        
        userModel.offlineData = dict
        var conversionRateUSDNOK = userModel.getConversionrate(norLocale, toLocale: usdLocale)
        XCTAssert(conversionRateUSDNOK! == 0.125, "Conversionrate should be 0.125")
        
        var conversionRateUSDSEK = userModel.getConversionrate(seLocale, toLocale: usdLocale)
        XCTAssert(conversionRateUSDSEK! == 0.1, "Conversionrate should be 0.1")
        
        var conversionRateSEKNOK = userModel.getConversionrate(seLocale, toLocale: norLocale)
        XCTAssert(conversionRateSEKNOK! == 0.8, "Conversionrate should be 0.8")
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