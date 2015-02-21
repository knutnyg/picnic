//
//  ViewController.swift
//  currencyolini
//
//  Created by Knut Nygaard on 21/02/15.
//  Copyright (c) 2015 Knut Nygaard. All rights reserved.
//

import UIKit
import CoreLocation

class ViewController: UIViewController, CLLocationManagerDelegate{

    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var fromAmount: UITextField!
    @IBOutlet weak var toAmount: UITextField!

    @IBOutlet weak var fromLabel: UILabel!
    @IBOutlet weak var toLabel: UILabel!


    let locationManager = CLLocationManager()
    let userModel = UserModel()

    override func viewDidLoad() {
        super.viewDidLoad()

        self.locationManager.delegate = self
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
        self.locationManager.requestWhenInUseAuthorization()
        self.locationManager.startUpdatingLocation()
        
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

    func locationManager(manager: CLLocationManager!, didUpdateLocations locations: [AnyObject]!) {
        CLGeocoder().reverseGeocodeLocation(manager.location, completionHandler: {(placemarks, error)->Void in
            
            if (error != nil) {
                println("Error: " + error.localizedDescription)
                return
            }
            
            if placemarks.count > 0 {
                let pm = placemarks[0] as CLPlacemark
                self.displayLocationInfo(pm)
            } else {
                println("Error with the data.")
            }
        })
    }
    
    func displayLocationInfo(placemark: CLPlacemark) {
                println("in locaitonmanager")
        self.locationManager.stopUpdatingLocation()
        println(placemark.locality)
        println(placemark.postalCode)
        println(placemark.administrativeArea)
        println(placemark.country)
        
    }
    
    func locationManager(manager: CLLocationManager!, didFailWithError error: NSError!) {
        println("Error: " + error.localizedDescription)
    }

    
}

