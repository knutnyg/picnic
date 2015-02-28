//
//  ConverterViewController.swift
//  currencyolini
//
//  Created by Knut Nygaard on 2/28/15.
//  Copyright (c) 2015 Knut Nygaard. All rights reserved.
//

import Foundation
import BrightFutures
import UIKit

class ConverterViewController: UIViewController, UserModelObserver, UITextFieldDelegate {
    
    
    // -- UI Elements -- //
    var topCountryLabel:UILabel!
    var bottomCountryLabel:UILabel!
    
    var topTextField:UITextField!
    var bottomTextField:UITextField!
    
    var swapButton:UIButton!
    

    // -- App Elements -- //
    var userModel = UserModel()
    var locationManager = LocationManagerWrapper()
    
    let userDefaults = NSUserDefaults.standardUserDefaults();
    
    override func viewDidLoad() {
        super.viewDidLoad()
        userModel.addObserver(self)
        
        topCountryLabel = UILabel()
        topCountryLabel.setTranslatesAutoresizingMaskIntoConstraints(false)
        topCountryLabel.text = "placeholderTopLabel"
        
        topTextField = createTextField()
        
        bottomCountryLabel = UILabel()
        bottomCountryLabel.setTranslatesAutoresizingMaskIntoConstraints(false)
        bottomCountryLabel.text = "placeholderBottomLabel"

        bottomTextField = createTextField()
        
        swapButton = UIButton()
        swapButton.setTranslatesAutoresizingMaskIntoConstraints(false)
        swapButton.setTitle("\u{f0ec}", forState: .Normal)
        swapButton.setTitleColor(UIColor.blackColor(), forState: .Normal)
        swapButton.setTitleColor(UIColor.whiteColor(), forState: .Highlighted)
        swapButton.transform = CGAffineTransformMakeRotation(3.14/2)
        
        view.addSubview(topCountryLabel)
        view.addSubview(topTextField)
        view.addSubview(swapButton)
        view.addSubview(bottomCountryLabel)
        view.addSubview(bottomTextField)
        
        topTextField.addTarget(self, action: Selector("fromAmountEdited:"), forControlEvents: UIControlEvents.EditingChanged)
        bottomTextField.addTarget(self, action: Selector("toAmountEdited:"), forControlEvents: UIControlEvents.EditingChanged)
        
        let views: [NSObject : AnyObject] = ["topCountryLabel":topCountryLabel, "bottomCountryLabel":bottomCountryLabel,
            "topTextField":topTextField, "bottomTextField":bottomTextField, "swapButton":swapButton]
        
        
        self.setConstraintsBasedOnScreenSize(views)
        
        
        
    }
    
    func setConstraintsBasedOnScreenSize(views: [NSObject:AnyObject]){
        let screenHeight = view.frame.height
        
        switch screenHeight {
        case 480: setConstraintsForiPhoneFour(views)
        default: println("default")
        }
        
    }
    
    func setConstraintsForiPhoneFour(views: [NSObject:AnyObject]){
        
        let textFieldHeight = 46 as CGFloat
        let textFieldFontSize = 22 as CGFloat
        let swapButtonFontSize = 40 as CGFloat
        

        let verticalLayout = NSLayoutConstraint.constraintsWithVisualFormat("V:|-25-[topTextField(\(textFieldHeight))]-20-[swapButton]-20-[bottomTextField(\(textFieldHeight))]", options: NSLayoutFormatOptions(0), metrics: nil, views: views)
        self.view.addConstraints(verticalLayout)
        
        let topCountrylabelSpaceToTextField = NSLayoutConstraint.constraintsWithVisualFormat("V:[topCountryLabel]-2-[topTextField]", options: NSLayoutFormatOptions(0), metrics: nil, views: views)
        let topContryLabelLeftConst = NSLayoutConstraint.constraintsWithVisualFormat("H:|-8-[topCountryLabel]", options: NSLayoutFormatOptions(0), metrics: nil, views: views)
        self.view.addConstraints(topContryLabelLeftConst)
        self.view.addConstraints(topCountrylabelSpaceToTextField)

        self.topTextField.font = UIFont(name: "Verdana", size: textFieldFontSize)
        let topTextFieldWidthConst = NSLayoutConstraint.constraintsWithVisualFormat("H:|-8-[topTextField]-8-|", options: NSLayoutFormatOptions(0), metrics: nil, views: views)
        self.view.addConstraints(topTextFieldWidthConst)
        
        self.swapButton.titleLabel!.font = UIFont(name: "FontAwesome", size: swapButtonFontSize)
        let swapButtonWidthConst = NSLayoutConstraint.constraintsWithVisualFormat("H:|-8-[swapButton]-8-|", options: NSLayoutFormatOptions(0), metrics: nil, views: views)
        self.view.addConstraints(swapButtonWidthConst)
        
        let bottomContryLabelLeftConst = NSLayoutConstraint.constraintsWithVisualFormat("H:|-8-[bottomCountryLabel]", options: NSLayoutFormatOptions(0), metrics: nil, views: views)
        let bottomCountrylabelbottomConst = NSLayoutConstraint.constraintsWithVisualFormat("V:[bottomCountryLabel]-2-[bottomTextField]", options: NSLayoutFormatOptions(0), metrics: nil, views: views)
        self.view.addConstraints(bottomContryLabelLeftConst)
        self.view.addConstraints(bottomCountrylabelbottomConst)
        
        self.bottomTextField.font = UIFont(name: "Verdana", size: textFieldFontSize)
        let bottomTextFieldWidthConst = NSLayoutConstraint.constraintsWithVisualFormat("H:|-8-[bottomTextField]-8-|", options: NSLayoutFormatOptions(0), metrics: nil, views: views)
        self.view.addConstraints(bottomTextFieldWidthConst)
        
        
        
        
        
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
                self.updateUserCurrentLocale(NSLocale(localeIdentifier: "no_NO"))
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
            
            println(response)
            
            if error != nil {
                promise.failure(error!)
            } else {
                promise.success(1.0)
                //                var boardsDictionary: NSDictionary = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.MutableContainers, error: nil) as NSDictionary
                //                var conversionRate : Double = boardsDictionary.objectForKey("rate") as Double;
                
            }
        }
        return promise.future
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func swapButtonPressed(){
        
        var tempLocale:NSLocale = self.userModel.currentLocale!
        
        self.userModel.setCurrentLocale(self.userModel.homeLocale!)
        self.userModel.setHomeLocale(tempLocale)
        if self.userModel.convertionRate != 0 {
            self.userModel.setConvertionRate(1.0/self.userModel.convertionRate!)
            
        }
        
        bottomTextField.text = ""
        topTextField.text = ""
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
        bottomCountryLabel.text = country
    }
    
    func setFromCountryText() {
        let locale:NSLocale = self.userModel.currentLocale!
        let countryCode:String = locale.objectForKey(NSLocaleCountryCode) as String
        var country: String = locale.displayNameForKey(NSLocaleCountryCode, value: countryCode)!
        topCountryLabel.text = country
    }
    
    func setToCurrencyLabel() {
        bottomTextField.placeholder = self.userModel.homeLocale!.objectForKey(NSLocaleCurrencyCode) as? String
    }
    
    func setFromCurrencyLabel() {
        topTextField.placeholder = self.userModel.currentLocale!.objectForKey(NSLocaleCurrencyCode) as? String
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
        topTextField.text = "0082384928"
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
    
    func fromAmountEdited(theTextField:UITextField) -> Void {
        let normalizedNumber = self.normalizeText(topTextField.text)
        
        if self.isValid(normalizedNumber) {
            println("from: \(normalizedNumber) cur: \(self.userModel.convertionRate)")
            var num = (normalizedNumber.doubleValue * self.userModel.convertionRate!)
            bottomTextField.text = NSString(format: "%.2f", num)
        } else {
            self.displayErrorMessage()
        }
    }
    
    func toAmountEdited(theTextField:UITextField) -> Void {
        let normalizedNumber = self.normalizeText(bottomTextField.text)
        
        println(theTextField.text)
        
        if self.isValid(normalizedNumber) {
            println("from: \(normalizedNumber) cur: \(self.userModel.convertionRate)")
            var num = normalizedNumber.doubleValue * (1 / self.userModel.convertionRate!)
            
            self.topTextField.text = NSString(format: "%.2f", num)
        } else {
            self.displayErrorMessage()
        }
    }
    
    func createTextField() -> UITextField{
        var textField = UITextField()
        
        textField.delegate = self
        textField.setTranslatesAutoresizingMaskIntoConstraints(false)
        textField.borderStyle = UITextBorderStyle.RoundedRect
        textField.placeholder = "USD"
        textField.keyboardType = UIKeyboardType.DecimalPad
        textField.returnKeyType = UIReturnKeyType.Done

        return textField
    }

    
}
