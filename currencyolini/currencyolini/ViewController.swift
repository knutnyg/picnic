
import UIKit
import CoreLocation

class ViewController: UIViewController {

    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var fromAmount: UITextField!
    @IBOutlet weak var toAmount: UITextField!

    @IBOutlet weak var fromLabel: UILabel!
    @IBOutlet weak var toLabel: UILabel!


    var userModel = UserModel()
    var locationManager = LocationManagerWrapper()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        locationManager.start()
        
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func convertButtonClicked(sender: UIButton) {
        // Get user preference
        var test = NSUserDefaults.standardUserDefaults();
//        var conversionRate = test.integerForKey("slider_preference");
        let fromCurrency = test.stringForKey("from_country")!
        let toCurrency = test.stringForKey("to_country")!
        
        fromLabel.text = fromCurrency
        toLabel.text = toCurrency
        
        println("http://rate-exchange.appspot.com/currency?from=\(fromCurrency)&to=\(toCurrency)")
        let url = NSURL(string: "http://rate-exchange.appspot.com/currency?from=\(fromCurrency)&to=\(toCurrency)" )
        let request = NSURLRequest(URL: url!)
        NSURLConnection.sendAsynchronousRequest(request, queue: NSOperationQueue.mainQueue()) {(response, data, error) in
            var error: NSError?
            var boardsDictionary: NSDictionary = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.MutableContainers, error: &error) as NSDictionary
            var conversionRate : Double = boardsDictionary.objectForKey("rate") as Double;
            println(conversionRate)
                    if let number = self.fromAmount.text?.toInt() {
                      self.toAmount.text = "\(Double(number) * conversionRate)"
                }
        }
    }



    
}

