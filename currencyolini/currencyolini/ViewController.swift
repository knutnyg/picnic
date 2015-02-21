//
//  ViewController.swift
//  currencyolini
//
//  Created by Knut Nygaard on 21/02/15.
//  Copyright (c) 2015 Knut Nygaard. All rights reserved.
//

import UIKit
import CoreLocation

class ViewController: UIViewController {

    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var fromAmount: UITextField!
    @IBOutlet weak var toAmount: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()
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

}

