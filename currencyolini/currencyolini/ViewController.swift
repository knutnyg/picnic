
import UIKit
import CoreLocation

class ViewController: UIViewController, UserModelObserver {

    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var fromAmount: UITextField!
    @IBOutlet weak var toAmount: UITextField!

    @IBOutlet weak var fromLabel: UILabel!
    @IBOutlet weak var toLabel: UILabel!

    @IBOutlet weak var fromCountry: UILabel!
    @IBOutlet weak var toCountry: UILabel!
    
    @IBOutlet weak var swapButton: UIButton!
    
    var userModel = UserModel()
    var locationManager = LocationManagerWrapper()
    
    let userDefaults = NSUserDefaults.standardUserDefaults();

    
    override func viewDidLoad() {
        super.viewDidLoad()
        userModel.addObserver(self)
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        self.updateUserHomeLocale()
        
        locationManager.getUserCurrentLocale()
            .onSuccess { locale in
                self.updateUserCurrentLocale(locale) }
            .onFailure { error in
                println("failed getting country")
        }
    }
    
   
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func convertButtonClicked(sender: UIButton) {

        let fromCurrency = userModel.currentLocale.objectForKey(NSLocaleCurrencyCode) as String
        let toCurrency = userModel.homeLocale.objectForKey(NSLocaleCurrencyCode) as String
        
        let url = NSURL(string: "http://rate-exchange.appspot.com/currency?from=\(fromCurrency)&to=\(toCurrency)" )
        
        let request = NSURLRequest(URL: url!)
        NSURLConnection.sendAsynchronousRequest(request, queue: NSOperationQueue.mainQueue()) {(response, data, error) in
            var error: NSError?
            var boardsDictionary: NSDictionary = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.MutableContainers, error: &error) as NSDictionary
            var conversionRate : Double = boardsDictionary.objectForKey("rate") as Double;
            
            if let number = self.fromAmount.text?.toInt() {
                self.toAmount.text = "\(Double(number) * conversionRate)"
            }
        }
    }
    
    
    @IBAction func swapButtonPressed(){
        var temp:NSLocale = self.userModel.currentLocale
        
        self.userModel.setCurrentLocale(self.userModel.homeLocale)
        self.userModel.setHomeLocale(temp)
    }
   
    func updateUserCurrentLocale(locale:NSLocale){       
        
        if((userDefaults.stringForKey("to_country")) != ""){
            self.userModel.setCurrentLocale(NSLocale(localeIdentifier: userDefaults.stringForKey("to_country")!))
            return
        }
        self.userModel.setCurrentLocale(locale)
    }
    
    func updateUserHomeLocale() {
        
        if((userDefaults.stringForKey("from_country")) != ""){
            self.userModel.setHomeLocale(NSLocale(localeIdentifier: userDefaults.stringForKey("from_country")!))
            return
        }
        let locale:NSLocale = locationManager.getUserHomeLocale()
        self.userModel.setHomeLocale(locale)
    }
    
    func homeLocaleHasChanged() {
        setToCountyText()
        setToCurrencyLabel()
    }
    
    func currentLocaleHasChanged() {
        setFromCountryText()
        setFromCurrencyLabel()
    }
    
    func setToCountyText(){
        let locale:NSLocale = self.userModel.homeLocale
        let countryCode:String = locale.objectForKey(NSLocaleCountryCode) as String
        var country: String = locale.displayNameForKey(NSLocaleCountryCode, value: countryCode)!
        toCountry.text = country
    }
    
    func setFromCountryText() {
        let locale:NSLocale = self.userModel.currentLocale
        let countryCode:String = locale.objectForKey(NSLocaleCountryCode) as String
        var country: String = locale.displayNameForKey(NSLocaleCountryCode, value: countryCode)!
        fromCountry.text = country
    }
    
    func setToCurrencyLabel() {
        toLabel.text = self.userModel.homeLocale.objectForKey(NSLocaleCurrencyCode) as? String
    }
    
    func setFromCurrencyLabel() {
        fromLabel.text = self.userModel.currentLocale.objectForKey(NSLocaleCurrencyCode) as? String
    }


    
}

