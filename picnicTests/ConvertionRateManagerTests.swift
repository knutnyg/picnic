
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
        
        let cvr = ConversionRateManager(userModel: userModel)
        cvr.configPath = "wrong"
        XCTAssertNil(cvr.loadConfig(), "loading config should fail: 404")
    }
    
    func testGetAllCurrenciesIllegalResponse(){
        let crm = ConversionRateManager(userModel: userModel)
        setBundleToTest(crm)
        crm.config = crm.loadConfig()
        
        let URL = crm.getAllCurrenciesURL()!
        let expected = "http://example.com/api/currencies"
        
        XCTAssertEqual(URL.description,expected,"should be equal")
    }
    
    func testGetAllCurrenciesURL(){
        let crm = ConversionRateManager(userModel: userModel)
        setBundleToTest(crm)
        crm.config = crm.loadConfig()
        
        let URL = crm.getAllCurrenciesURL()!
        let expected = "http://example.com/api/currencies"
        
        XCTAssertEqual(URL.description,expected,"should be equal")
        
    }
    
    func testOfflineConversionRate(){
        let userModel = UserModel()
        
        var dict:[String:OfflineEntry] = [:]
        dict["NOK"] = OfflineEntry(timeStamp: NSDate(), unit_from: "USD", unit_to: "NOK", value: 8)
        dict["USD"] = OfflineEntry(timeStamp: NSDate(), unit_from: "USD", unit_to: "USD", value: 1)
        dict["SEK"] = OfflineEntry(timeStamp: NSDate(), unit_from: "USD", unit_to: "SEK", value: 10)
        
        let norLocale = NSLocale(localeIdentifier: "nb_NO")
        let usdLocale = NSLocale(localeIdentifier: "en_US")
        let seLocale = NSLocale(localeIdentifier: "se_SE")
        
        userModel.offlineData = dict
        let conversionRateUSDNOK = userModel.getConversionrate(norLocale, toLocale: usdLocale)
        XCTAssert(conversionRateUSDNOK! == 0.125, "Conversionrate should be 0.125")
        
        let conversionRateUSDSEK = userModel.getConversionrate(seLocale, toLocale: usdLocale)
        XCTAssert(conversionRateUSDSEK! == 0.1, "Conversionrate should be 0.1")
        
        let conversionRateSEKNOK = userModel.getConversionrate(seLocale, toLocale: norLocale)
        XCTAssert(conversionRateSEKNOK! == 0.8, "Conversionrate should be 0.8")
    }
    
    func testSavingAndLoadingOfflineDataFile(){
        var dict:[String:OfflineEntry] = [:]
        dict["NOK"] = OfflineEntry(timeStamp: NSDate(), unit_from: "USD", unit_to: "NOK", value: 2)
        saveDictionaryToDisk("test.dat", dict: dict)
        
        let loadedDict = readOfflineDateFromDisk("test.dat")
        XCTAssertNotNil(loadedDict, "shouldNotBeNil")
    }
    
    func testLoadingNilShouldNotCrashApp(){
        let result = readOfflineDateFromDisk("doesNotExist.dat")
        XCTAssertNil(result, "should be nil!")
    }
    
    func setBundleToTest(crm:ConversionRateManager){
        let bundle = NSBundle(forClass: ConvertionRateManagerTests.self)
        crm.configPath = bundle.pathForResource("config_test", ofType: "plist")
    }
    
}