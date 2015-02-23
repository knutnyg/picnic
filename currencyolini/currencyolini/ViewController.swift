
import UIKit
import CoreLocation

class ViewController: UIViewController {

    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var fromAmount: UITextField!
    @IBOutlet weak var toAmount: UITextField!

    @IBOutlet weak var fromLabel: UILabel!
    @IBOutlet weak var toLabel: UILabel!

    @IBOutlet weak var fromCountry: UILabel!
    @IBOutlet weak var toCountry: UILabel!
    
    var userModel = UserModel()
    var locationManager = LocationManagerWrapper()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
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
    
   
    func updateUserCurrentLocale(locale:NSLocale){
        self.userModel.currentLocale = locale
        fromLabel.text = locale.objectForKey(NSLocaleCurrencyCode) as? String
        
        let countryCode:String = locale.objectForKey(NSLocaleCountryCode) as String
        var country: String = locale.displayNameForKey(NSLocaleCountryCode, value: countryCode)!
        
        fromCountry.text = country
    }
    
    func updateUserHomeLocale() {
        let locale:NSLocale = locationManager.getUserHomeLocale()
        self.userModel.homeLocale = locale
        toLabel.text = locale.objectForKey(NSLocaleCurrencyCode) as? String
        
        let countryCode:String = locale.objectForKey(NSLocaleCountryCode) as String
        var country: String = locale.displayNameForKey(NSLocaleCountryCode, value: countryCode)!
        
        toCountry.text = country
    }


    
}

