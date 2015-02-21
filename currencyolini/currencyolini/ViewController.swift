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
        label.text = "Hello World";
        // Get user preference
        var test = NSUserDefaults.standardUserDefaults();
        var conversionRate = test.integerForKey("slider_preference");
        if let number = self.fromAmount.text?.toInt() {
            self.toAmount.text = "\(number * conversionRate)"
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
        
        userModel.c
    }
    
    func locationManager(manager: CLLocationManager!, didFailWithError error: NSError!) {
        println("Error: " + error.localizedDescription)
    }

    
}

