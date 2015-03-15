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

    var pointLabel:UILabel!
    var homeLabel:UILabel!
    
    var homeIsAtTop = false;

    // -- App Elements -- //
    var userModel = UserModel()
    var locationManager = LocationManager()
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
        
        pointLabel = UILabel()
        pointLabel.setTranslatesAutoresizingMaskIntoConstraints(false)
        pointLabel.font = UIFont(name: "FontAwesome", size: 30)
        pointLabel.text = "\u{f124}"
        
        homeLabel = UILabel()
        homeLabel.setTranslatesAutoresizingMaskIntoConstraints(false)
        homeLabel.font = UIFont(name: "FontAwesome", size: 30)
        homeLabel.text = "\u{f015}"
        
        swapButton = createSwapButton()
        
        view.addSubview(topCountryLabel)
        view.addSubview(topTextField)
        view.addSubview(swapButton)
        view.addSubview(bottomCountryLabel)
        view.addSubview(bottomTextField)
        view.addSubview(pointLabel)
        view.addSubview(homeLabel)
        
        let views: [NSObject : AnyObject] = ["topCountryLabel":topCountryLabel, "bottomCountryLabel":bottomCountryLabel,
            "topTextField":topTextField, "bottomTextField":bottomTextField, "swapButton":swapButton, "point":pointLabel, "home":homeLabel]
        
        self.setupGUIBasedOnScreenSize(views)
    }
    
   
    
    func setupGUIBasedOnScreenSize(views: [NSObject:AnyObject]){
        let screenHeight = view.frame.height
        
        switch screenHeight {
            case 480: setupForiPhoneFour(views)
            case 568: setupForiPhoneFive(views)
            case 667: setupForiPhoneSix(views)
            case 736: setupForiPhoneSix(views)
            case 1024: setupForiPadTwo(views)
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
    
    func setupForiPadTwo(views: [NSObject:AnyObject]){
        let textFieldFontSize = 30 as CGFloat
        let swapButtonFontSize = 55 as CGFloat
        let countryLabelFontSize = 20 as CGFloat
        
        
        self.topTextField.font = UIFont(name: "Verdana", size: textFieldFontSize)
        self.swapButton.titleLabel!.font = UIFont(name: "FontAwesome", size: swapButtonFontSize)
        self.bottomTextField.font = UIFont(name: "Verdana", size: textFieldFontSize)
        self.topCountryLabel.font = UIFont(name: "Verdana", size: countryLabelFontSize)
        self.bottomCountryLabel.font = UIFont(name: "Verdana", size: countryLabelFontSize)
        
        let constraintsModel = ConverterConstraintsModel(
            textFieldHeight: 100,
            topTextFieldMarginTop: 140,
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
        
        let homeConstraint = NSLayoutConstraint.constraintsWithVisualFormat("V:[topCountryLabel]-27-[point]", options: NSLayoutFormatOptions(0), metrics: nil, views: views)
        let pointConstraint = NSLayoutConstraint.constraintsWithVisualFormat("V:[bottomCountryLabel]-27-[home]", options: NSLayoutFormatOptions(0), metrics: nil, views: views)
        
        visualFormat = String(format: "H:|-%d-[topCountryLabel]",
            constraintsModel.distanceFromEdge)
        
        let topContryLabelLeftConst = NSLayoutConstraint.constraintsWithVisualFormat(
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
    
        visualFormat = String(format: "H:|-%d-[point(28)]-8-[topTextField]-%d-|",
            constraintsModel.distanceFromEdge,
            constraintsModel.distanceFromEdge)
        
        let topTextFieldWidthConst = NSLayoutConstraint.constraintsWithVisualFormat(
            visualFormat, options: NSLayoutFormatOptions(0), metrics: nil, views: views)
        
        visualFormat = String(format: "H:|-%d-[home(28)]-8-[bottomTextField]-%d-|",
            constraintsModel.distanceFromEdge,
            constraintsModel.distanceFromEdge)
        
        let bottomTextFieldWidthConst = NSLayoutConstraint.constraintsWithVisualFormat(
            visualFormat, options: NSLayoutFormatOptions(0), metrics: nil, views: views)
        
        self.view.addConstraints(verticalLayout)
        self.view.addConstraints(topCountrylabelSpaceToTextField)
        self.view.addConstraints(topContryLabelLeftConst)
        self.view.addConstraints(topTextFieldWidthConst)
        self.view.addConstraint(swapButtonHorizontalAlign)
        self.view.addConstraints(bottomContryLabelLeftConst)
        self.view.addConstraints(bottomCountrylabelbottomConst)
        self.view.addConstraints(bottomTextFieldWidthConst)
        self.view.addConstraints(pointConstraint)
        self.view.addConstraints(homeConstraint)

    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        self.updateUserHomeLocale()
        
        locationManager.getUserCurrentLocale()
            .onSuccess { locale in
                println("got success")
                self.updateUserCurrentLocale(locale)
                self.fetchCurrency()}
            .onFailure { error in
                println("got failure getting current locale")
                self.displayFailedToCurrentLocation()
                self.updateUserCurrentLocale(NSLocale(localeIdentifier: "en_GB"))
                self.fetchCurrency()
        }
    }
    
    func fetchCurrency() {
        ConvertsionRateManager().getConvertionRate(self.userModel)
                .onSuccess { conv in
                    self.userModel.setConvertionRate(conv) }
                .onFailure { error in
                    println("failed to get conv rate")
                    self.displayFailedToResolveCurrencyError()
                    self.userModel.setConvertionRate(1.0)}
    }
    
    func getConvertionRate(homeCurrency:String, currentCurrency:String) -> Future<Double> {
        
        let promisee = Promise<Double>()
        
        let url = NSURL(string: "http://rate-exchange.appspot.com/currency?from=\(currentCurrency)&to=\(homeCurrency)" )
        
        let request = NSURLRequest(URL: url!)
        NSURLConnection.sendAsynchronousRequest(request, queue: NSOperationQueue.mainQueue()) {(response, data, error) in
            
            println(response)
            var castedResponse = response as NSHTTPURLResponse
            if error != nil {
                promisee.failure(NSError(domain: "CurrencyApiError", code: 503, userInfo: nil))
            } else {
                if(castedResponse.statusCode == 200){
                    var boardsDictionary: NSDictionary = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.MutableContainers, error: nil) as NSDictionary

                    var conversionRate : Double = boardsDictionary.objectForKey("rate") as Double;
                    promisee.success(conversionRate)
                } else {
                    promisee.failure(NSError(domain: "CurrencyApiError", code: 503, userInfo: nil))
                }
                
                
                
            }
        }
        return promisee.future
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func swapButtonPressed(sender:UIButton!){
        
        self.userModel.swap()

        var tempLabelText:NSString = self.homeLabel.text!
        self.homeLabel.text = self.pointLabel.text
        self.pointLabel.text = tempLabelText
    }
    
    func updateUserCurrentLocale(locale:NSLocale){
        
        if((userDefaults.stringForKey("from_country")) != nil && userDefaults.stringForKey("from_country") != ""){
            
            var filteredList = NSLocale.availableLocaleIdentifiers().filter { ($0 as String) == self.userDefaults.stringForKey("from_country") &&  self.userDefaults.stringForKey("from_country")!.contains("_")}

            if(filteredList.count > 0) {
                let locale = NSLocale(localeIdentifier: (filteredList.first as String))
                self.userModel.setCurrentLocale(locale)
            } else {
                self.displayFailedToParseOverride()
            }
            return
        }
        self.userModel.setCurrentLocale(locale)
    }
    
    func updateUserHomeLocale() {

        if((userDefaults.stringForKey("to_country")) != nil && userDefaults.stringForKey("to_country") != ""){
            
            var filteredList = NSLocale.availableLocaleIdentifiers().filter { ($0 as String) == self.userDefaults.stringForKey("to_country") &&  self.userDefaults.stringForKey("to_country")!.contains("_")}
            
            
            if(filteredList.count > 0) {
                self.userModel.setHomeLocale(NSLocale(localeIdentifier: userDefaults.stringForKey("to_country")!))
            } else {
                self.displayFailedToParseOverride()
            }
            return
        }
        let locale:NSLocale = locationManager.getUserHomeLocale()
        self.userModel.setHomeLocale(locale)
    }
    
    func setToCountyText(){
        var userLanguage = NSLocale.preferredLanguages().description
        
        var userLanguageLocale = NSLocale(localeIdentifier: NSLocale.localeIdentifierFromComponents(NSDictionary(object: userLanguage, forKey: NSLocaleLanguageCode)))
        
        let locale:NSLocale = self.userModel.homeLocale!
        let countryCode:String = locale.objectForKey(NSLocaleCountryCode) as String
        var country: String = userLanguageLocale.displayNameForKey(NSLocaleCountryCode, value: countryCode)!
        bottomCountryLabel.text = country
    }
    
    func setFromCountryText() {
        
        var userLanguage = NSLocale.preferredLanguages().description
        
        var userLanguageLocale = NSLocale(localeIdentifier: NSLocale.localeIdentifierFromComponents(NSDictionary(object: userLanguage, forKey: NSLocaleLanguageCode)))
        
        let locale:NSLocale = self.userModel.currentLocale!
        let countryCode:String = locale.objectForKey(NSLocaleCountryCode) as String
        var country: String = userLanguageLocale.displayNameForKey(NSLocaleCountryCode, value: countryCode)!
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
        var alert2 = UIAlertController(title: "Error", message: "Unable to access current convertionrate. Please check your internet connection and try again later.", preferredStyle: UIAlertControllerStyle.Alert)
        alert2.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: nil))
        self.presentViewController(alert2, animated: true, completion: nil)
    }
    
    func displayFailedToCurrentLocation(){
        var alert = UIAlertController(title: "Error", message: "Unable to verify your location. Please make sure that the app is allowed to use GPS under general settings, and that your GPS works.", preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: nil))
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    func displayFailedToParseOverride(){
        var alert = UIAlertController(title: "Error", message: "Error in format of override locale. Should be on format: ab_CD", preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: nil))
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
            if (homeIsAtTop) {
                userModel.setHomeAmount(normalizedNumber.doubleValue)
            } else {
                userModel.setCurrentAmount(normalizedNumber.doubleValue)
            }
        } else {
            self.displayErrorMessage()
        }
    }
    
    func toAmountEdited(theTextField:UITextField) -> Void {
        let normalizedNumber = self.normalizeText(bottomTextField.text)
        if self.isValid(normalizedNumber) {
            if (homeIsAtTop) {
                userModel.setCurrentAmount(normalizedNumber.doubleValue)
            } else {
                userModel.setHomeAmount(normalizedNumber.doubleValue)
            }
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
        textField.textAlignment = NSTextAlignment.Center
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
    
    func homeAmountChanged() {
        if(homeIsAtTop) {
            if (!topTextField.isFirstResponder()) {
                self.topTextField.text = NSString(format: "%.2f", userModel.homeAmount)
            }
        } else {
            if (!bottomTextField.isFirstResponder()) {
                self.bottomTextField.text = NSString(format: "%.2f", userModel.homeAmount)
            }
        }
    }
    
    func currentAmountChanged() {
        if (homeIsAtTop) {
            if (!bottomTextField.isFirstResponder()) {
                self.bottomTextField.text = NSString(format: "%.2f", userModel.currentAmount)
            }
        } else {
            if (!topTextField.isFirstResponder()) {
                self.topTextField.text = NSString(format: "%f", userModel.currentAmount)
            }
        }
    }
    
}

extension String {
    
    func contains(find: String) -> Bool{
        return self.rangeOfString(find) != nil
    }
}