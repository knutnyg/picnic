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
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "refreshButtonPressed:", name: "refreshPressed", object: nil)
        
        topCountryLabel = UILabel()
        topCountryLabel.setTranslatesAutoresizingMaskIntoConstraints(false)
        
        topTextField = createTextField()
        topTextField.addTarget(self, action: Selector("fromAmountEdited:"), forControlEvents: UIControlEvents.EditingChanged)
        
        bottomCountryLabel = UILabel()
        bottomCountryLabel.setTranslatesAutoresizingMaskIntoConstraints(false)

        bottomTextField = createTextField()
        bottomTextField.addTarget(self, action: Selector("toAmountEdited:"), forControlEvents: UIControlEvents.EditingChanged)
        
        swapButton = createSwapButton()
        
        view.addSubview(topCountryLabel)
        view.addSubview(topTextField)
        view.addSubview(swapButton)
        view.addSubview(bottomCountryLabel)
        view.addSubview(bottomTextField)
        
        let views: [NSObject : AnyObject] = ["topCountryLabel":topCountryLabel, "bottomCountryLabel":bottomCountryLabel,
            "topTextField":topTextField, "bottomTextField":bottomTextField, "swapButton":swapButton]
        
        self.setupGUIBasedOnScreenSize(views)
    }
    
   
    
    func setupGUIBasedOnScreenSize(views: [NSObject:AnyObject]){
        let screenHeight = view.frame.height
        
        switch screenHeight {
            case 480: setupForiPhoneFour(views)
            case 568: setupForiPhoneFive(views)
            case 667: setupForiPhoneSix(views)
            case 736: setupForiPhoneSix(views)
            default: println("default")
        }
    }
    
    func setupForiPhoneFour(views: [NSObject:AnyObject]){

        let textFieldFontSize = 22 as CGFloat
        let swapButtonFontSize = 40 as CGFloat
        
        let constraintsModel = ConverterConstraintsModel(
            textFieldHeight: 46,
            topTextFieldMarginTop: 25,
            swapButtonMarginTopAndBottom: 20,
            countryLabelDistanceFromTextField: 2,
            distanceFromEdge: 8
        )
        
        self.topTextField.font = UIFont(name: "Verdana", size: 23)
        self.bottomTextField.font = UIFont(name: "Verdana", size: textFieldFontSize)
        self.swapButton.titleLabel!.font = UIFont(name: "FontAwesome", size: swapButtonFontSize)
        
        setConstraintsForiPhone(views, constraintsModel: constraintsModel)
    }
    
    func setupForiPhoneFive(views: [NSObject:AnyObject]){
        let textFieldFontSize = 22 as CGFloat
        let swapButtonFontSize = 55 as CGFloat
        
        self.topTextField.font = UIFont(name: "Verdana", size: textFieldFontSize)
        self.swapButton.titleLabel!.font = UIFont(name: "FontAwesome", size: swapButtonFontSize)
        self.bottomTextField.font = UIFont(name: "Verdana", size: textFieldFontSize)
        
        let constraintsModel = ConverterConstraintsModel(
            textFieldHeight: 70,
            topTextFieldMarginTop: 23,
            swapButtonMarginTopAndBottom: 26,
            countryLabelDistanceFromTextField: 2,
            distanceFromEdge: 8
        )
        
        setConstraintsForiPhone(views, constraintsModel: constraintsModel)
    }
    
    func setupForiPhoneSix(views: [NSObject:AnyObject]){
        let textFieldFontSize = 22 as CGFloat
        let swapButtonFontSize = 55 as CGFloat
        
        self.topTextField.font = UIFont(name: "Verdana", size: textFieldFontSize)
        self.swapButton.titleLabel!.font = UIFont(name: "FontAwesome", size: swapButtonFontSize)
        self.bottomTextField.font = UIFont(name: "Verdana", size: textFieldFontSize)
        
        let constraintsModel = ConverterConstraintsModel(
            textFieldHeight: 80,
            topTextFieldMarginTop: 94,
            swapButtonMarginTopAndBottom: 30,
            countryLabelDistanceFromTextField: 2,
            distanceFromEdge: 8
        )
        
        setConstraintsForiPhone(views, constraintsModel: constraintsModel)
    }
    
    func setConstraintsForiPhone(views: [NSObject:AnyObject], constraintsModel:ConverterConstraintsModel){
        
        var visualFormat = String(format: "V:|-%d-[topTextField(%d)]-%d-[swapButton]-%d-[bottomTextField(%d)]",
            constraintsModel.topTextFieldMarginTop,
            constraintsModel.textFieldHeight,
            constraintsModel.swapButtonMarginTopAndBottom,
            constraintsModel.swapButtonMarginTopAndBottom,
            constraintsModel.textFieldHeight)
        
        let verticalLayout = NSLayoutConstraint.constraintsWithVisualFormat(
            visualFormat, options: NSLayoutFormatOptions(0), metrics: nil, views: views)
        
        visualFormat = String(format: "V:[topCountryLabel]-%d-[topTextField]",
            constraintsModel.countryLabelDistanceFromTextField)
        
        let topCountrylabelSpaceToTextField = NSLayoutConstraint.constraintsWithVisualFormat(
            visualFormat, options: NSLayoutFormatOptions(0), metrics: nil, views: views)
        
        visualFormat = String(format: "H:|-%d-[topCountryLabel]",
            constraintsModel.distanceFromEdge)
        
        let topContryLabelLeftConst = NSLayoutConstraint.constraintsWithVisualFormat(
            visualFormat, options: NSLayoutFormatOptions(0), metrics: nil, views: views)
        
        visualFormat = String(format: "H:|-%d-[topTextField]-%d-|",
            constraintsModel.distanceFromEdge,
            constraintsModel.distanceFromEdge)
        
        let topTextFieldWidthConst = NSLayoutConstraint.constraintsWithVisualFormat(
            visualFormat, options: NSLayoutFormatOptions(0), metrics: nil, views: views)
        
        visualFormat = String(format: "H:|-%d-[swapButton]-%d-|",
            constraintsModel.distanceFromEdge,
            constraintsModel.distanceFromEdge)
        
        let swapButtonWidthConst = NSLayoutConstraint.constraintsWithVisualFormat(
            visualFormat, options: NSLayoutFormatOptions(0), metrics: nil, views: views)
        
        let swapButtonHorizontalAlign = NSLayoutConstraint(item: swapButton, attribute: NSLayoutAttribute.CenterX, relatedBy: .Equal, toItem: self.view, attribute: .CenterX, multiplier: 1, constant: 0)
        
        visualFormat = String(format: "H:|-%d-[bottomCountryLabel]",
            constraintsModel.distanceFromEdge)
        
        let bottomContryLabelLeftConst = NSLayoutConstraint.constraintsWithVisualFormat(
            visualFormat, options: NSLayoutFormatOptions(0), metrics: nil, views: views)
        
        visualFormat = String(format: "V:[bottomCountryLabel]-%d-[bottomTextField]",
            constraintsModel.countryLabelDistanceFromTextField)
        
        let bottomCountrylabelbottomConst = NSLayoutConstraint.constraintsWithVisualFormat(
            visualFormat, options: NSLayoutFormatOptions(0), metrics: nil, views: views)
    
        visualFormat = String(format: "H:|-%d-[bottomTextField]-%d-|",
            constraintsModel.distanceFromEdge,
            constraintsModel.distanceFromEdge)
        
        let bottomTextFieldWidthConst = NSLayoutConstraint.constraintsWithVisualFormat(
            visualFormat, options: NSLayoutFormatOptions(0), metrics: nil, views: views)
        
        self.view.addConstraints(verticalLayout)
        self.view.addConstraints(topCountrylabelSpaceToTextField)
        self.view.addConstraints(topContryLabelLeftConst)
        self.view.addConstraints(topTextFieldWidthConst)
        self.view.addConstraint(swapButtonHorizontalAlign)
//        self.view.addConstraints(swapButtonHeightConst)
        self.view.addConstraints(bottomContryLabelLeftConst)
        self.view.addConstraints(bottomCountrylabelbottomConst)
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
            
            var castedResponse = response as NSHTTPURLResponse
            if error != nil {
                promise.failure(error!)
            } else {
                var boardsDictionary: NSDictionary = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.MutableContainers, error: nil) as NSDictionary

                if(castedResponse.statusCode == 200){
                    var conversionRate : Double = boardsDictionary.objectForKey("rate") as Double;
                    promise.success(conversionRate)
                } else {
                    promise.failure(error!)
                }
                
                
                
            }
        }
        return promise.future
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func swapButtonPressed(sender:UIButton!){
        
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
    
    func displayFailedToResolveCurrencyError(){
        var alert = UIAlertController(title: "Error", message: "Unable to access current convertionrate. Please check your internet connection and try again later.", preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: "", style: UIAlertActionStyle.Default, handler: nil))
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    func displayFailedToCurrentLocation(){
        var alert = UIAlertController(title: "Error", message: "Unable to verify your location. Please make sure that the app is allowed to use GPS under general settings, and that your GPS works.", preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: "", style: UIAlertActionStyle.Default, handler: nil))
        self.presentViewController(alert, animated: true, completion: nil)
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
    
    func createSwapButton() -> UIButton{
        var swapButton = UIButton()
        swapButton.setTranslatesAutoresizingMaskIntoConstraints(false)
        swapButton.setTitle("\u{f0ec}", forState: .Normal)
        swapButton.setTitleColor(UIColor.blackColor(), forState: .Normal)
        swapButton.setTitleColor(UIColor.whiteColor(), forState: .Highlighted)
        swapButton.transform = CGAffineTransformMakeRotation(3.14/2)
        swapButton.addTarget(self, action: "swapButtonPressed:", forControlEvents: UIControlEvents.TouchUpInside)
        
        return swapButton
    }
    
    func refreshButtonPressed(notification: NSNotification){
        self.updateUserHomeLocale()
        
        locationManager.getUserCurrentLocale()
            .onSuccess { locale in
                self.updateUserCurrentLocale(locale)
                self.fetchCurrency()}
            .onFailure { error in
                self.displayFailedToCurrentLocation()
        }
    }

    
}
