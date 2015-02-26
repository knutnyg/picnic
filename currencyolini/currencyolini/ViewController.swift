
import UIKit
import CoreLocation
import BrightFutures


class ViewController: UIViewController, UserModelObserver, UITextFieldDelegate{

    @IBOutlet weak var label: UILabel!
    
    @IBOutlet weak var fromAmount: UITextField!
    @IBOutlet weak var toAmount: UITextField!

    @IBOutlet weak var fromCountry: UILabel!
    @IBOutlet weak var toCountry: UILabel!
    
    @IBOutlet weak var swapButton: UIButton!
    
    
    var userModel = UserModel()
    var locationManager = LocationManagerWrapper()
    
    let userDefaults = NSUserDefaults.standardUserDefaults();

    
    override func viewDidLoad() {
        super.viewDidLoad()
        userModel.addObserver(self)
        
        fromAmount.delegate = self
        toAmount.delegate = self
        
        swapButton.setTitle("\u{f0ec}", forState: .Normal)
        swapButton.transform = CGAffineTransformMakeRotation(3.14/2)
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        self.updateUserHomeLocale()
        
        locationManager.getUserCurrentLocale()
            .onSuccess { locale in
                self.updateUserCurrentLocale(locale)
                self.fetchCurrency()}
            .onFailure { error in
                println("failed getting country, using system locale")
                self.updateUserCurrentLocale(NSLocale.systemLocale())
                self.fetchCurrency()
        }
    }
    
    func fetchCurrency() {
        var homeCurrency:String = ""
        var currentCurrency:String = ""
        
        if let home = self.userModel.homeLocale {
            homeCurrency = home.objectForKey(NSLocaleCurrencyCode) as String
        }
        
        if let current = self.userModel.currentLocale {
            currentCurrency = current.objectForKey(NSLocaleCurrencyCode) as String
        }
        
        if(homeCurrency != "" && currentCurrency != ""){
            
            self.getConvertionRate(homeCurrency, currentCurrency: currentCurrency)
                .onSuccess { conv in
                    self.userModel.setConvertionRate(conv) }
                .onFailure { error in
                    println("failed to get currency")}
        }
        
    }

    func getConvertionRate(homeCurrency:String, currentCurrency:String) -> Future<Double> {
        
        let promise = Promise<Double>()
        
        let url = NSURL(string: "http://rate-exchange.appspot.com/currency?from=\(currentCurrency)&to=\(homeCurrency)" )
        
        let request = NSURLRequest(URL: url!)
        NSURLConnection.sendAsynchronousRequest(request, queue: NSOperationQueue.mainQueue()) {(response, data, error) in
            
            if error != nil {
                promise.failure(error!)
            } else {
                var boardsDictionary: NSDictionary = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.MutableContainers, error: nil) as NSDictionary
                var conversionRate : Double = boardsDictionary.objectForKey("rate") as Double;
                promise.success(conversionRate)
            }
        }
        return promise.future
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func convertButtonClicked(sender: UIButton) {
        let normalizedNumber = self.normalizeText(self.fromAmount.text)
        
            if self.isValid(normalizedNumber) {
                println("from: \(normalizedNumber) cur: \(self.userModel.convertionRate)")
                self.toAmount.text = "\(normalizedNumber.doubleValue * self.userModel.convertionRate!)"
            } else {
                self.displayErrorMessage()
            }        
    }
    
    
    @IBAction func swapButtonPressed(){
        
        var tempLocale:NSLocale = self.userModel.currentLocale!
        var tempCurrencyValue:String = self.toAmount.text
        
        self.userModel.setCurrentLocale(self.userModel.homeLocale!)
        self.userModel.setHomeLocale(tempLocale)
        if self.userModel.convertionRate != 0 {
            self.userModel.setConvertionRate(1.0/self.userModel.convertionRate!)

        }
        
        self.toAmount.text = self.fromAmount.text
        self.fromAmount.text = tempCurrencyValue
    }
   
    func updateUserCurrentLocale(locale:NSLocale){       
        if((userDefaults.stringForKey("to_country")) != nil && userDefaults.stringForKey("to_country") != ""){
            self.userModel.setCurrentLocale(NSLocale(localeIdentifier: userDefaults.stringForKey("to_country")!))
            return
        }
        self.userModel.setCurrentLocale(locale)
    }
    
    func updateUserHomeLocale() {
        
        if((userDefaults.stringForKey("from_country")) != nil && userDefaults.stringForKey("from_country") != ""){
            self.userModel.setHomeLocale(NSLocale(localeIdentifier: userDefaults.stringForKey("from_country")!))
            return
        }
        let locale:NSLocale = locationManager.getUserHomeLocale()
        self.userModel.setHomeLocale(locale)
    }
    

    
    func setToCountyText(){
        let locale:NSLocale = self.userModel.homeLocale!
        let countryCode:String = locale.objectForKey(NSLocaleCountryCode) as String
        var country: String = locale.displayNameForKey(NSLocaleCountryCode, value: countryCode)!
        toCountry.text = country
    }
    
    func setFromCountryText() {
        let locale:NSLocale = self.userModel.currentLocale!
        let countryCode:String = locale.objectForKey(NSLocaleCountryCode) as String
        var country: String = locale.displayNameForKey(NSLocaleCountryCode, value: countryCode)!
        fromCountry.text = country
    }
    
    func setToCurrencyLabel() {
        toAmount.placeholder = self.userModel.homeLocale!.objectForKey(NSLocaleCurrencyCode) as? String
    }
    
    func setFromCurrencyLabel() {
        fromAmount.placeholder = self.userModel.currentLocale!.objectForKey(NSLocaleCurrencyCode) as? String
    }

    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true;
    }
    
    override func touchesBegan(touches: NSSet, withEvent event: UIEvent) {
        self.view.endEditing(true)
    }
    
    func normalizeText(input:String) -> NSString{
        return input.stringByReplacingOccurrencesOfString(",", withString: ".", options: NSStringCompareOptions.LiteralSearch, range: nil) as NSString
    }
    
    
    func isValid(input:String) -> Bool{
        return true
    }
    
    func displayErrorMessage(){
        self.fromAmount.text = "0082384928"
    }
    
    
    
    func convertionRateHasChanged(){
        println(self.userModel.convertionRate)
    }

    func homeLocaleHasChanged() {
        setToCountyText()
        setToCurrencyLabel()
    }
    
    func currentLocaleHasChanged() {
        setFromCountryText()
        setFromCurrencyLabel()
    }
    
}

