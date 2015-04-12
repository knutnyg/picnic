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

    var topLabel:UILabel!
    var bottomLabel:UILabel!
    
    var homeIsAtTop = false;

    // -- App Elements -- //
    var userModel:UserModel!
    var locationManager:LocationManager!

    let userDefaults = NSUserDefaults.standardUserDefaults();
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        userModel.addObserver(self)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "refreshButtonPressed:", name: "refreshPressed", object: nil)
        
        locationManager = LocationManager(userModel: self.userModel)
        topCountryLabel = UILabel()
        topCountryLabel.setTranslatesAutoresizingMaskIntoConstraints(false)
        
        topTextField = createTextField()
        topTextField.addTarget(self, action: Selector("topAmountEdited:"), forControlEvents: UIControlEvents.EditingChanged)
        
        bottomCountryLabel = UILabel()
        bottomCountryLabel.setTranslatesAutoresizingMaskIntoConstraints(false)

        bottomTextField = createTextField()
        bottomTextField.addTarget(self, action: Selector("bottomAmountEdited:"), forControlEvents: UIControlEvents.EditingChanged)
        
        topLabel = UILabel()
        topLabel.setTranslatesAutoresizingMaskIntoConstraints(false)
        topLabel.font = UIFont(name: "FontAwesome", size: 30)
        topLabel.text = "\u{f124}"
        
        bottomLabel = UILabel()
        bottomLabel.setTranslatesAutoresizingMaskIntoConstraints(false)
        bottomLabel.font = UIFont(name: "FontAwesome", size: 30)
        bottomLabel.text = "\u{f015}"
        
        swapButton = createSwapButton()
        
        view.addSubview(topCountryLabel)
        view.addSubview(topTextField)
        view.addSubview(swapButton)
        view.addSubview(bottomCountryLabel)
        view.addSubview(bottomTextField)
        view.addSubview(topLabel)
        view.addSubview(bottomLabel)
        
        let views: [NSObject : AnyObject] = ["topCountryLabel":topCountryLabel, "bottomCountryLabel":bottomCountryLabel,
            "topTextField":topTextField, "bottomTextField":bottomTextField, "swapButton":swapButton, "topIcon":topLabel, "bottomIcon":bottomLabel]
        
        self.setupGUIBasedOnScreenSize(views)
    }
    
    func withUserModel(userModel:UserModel) -> ConverterViewController{
        self.userModel = userModel
        return self
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
            textFieldHeight: 43,
            topTextFieldMarginTop: 31,
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
            textFieldHeight: 65,
            topTextFieldMarginTop: 33,
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
        
        view.addConstraint(NSLayoutConstraint(item: topLabel, attribute: NSLayoutAttribute.CenterY, relatedBy: .Equal, toItem: topTextField, attribute: .CenterY, multiplier: 1, constant: 0))
        view.addConstraint(NSLayoutConstraint(item: bottomLabel, attribute: NSLayoutAttribute.CenterY, relatedBy: .Equal, toItem: bottomTextField, attribute: .CenterY, multiplier: 1, constant: 0))
        
        
        visualFormat = String(format: "H:|-42-[topCountryLabel]",
            constraintsModel.distanceFromEdge)
        
        let topContryLabelLeftConst = NSLayoutConstraint.constraintsWithVisualFormat(
            visualFormat, options: NSLayoutFormatOptions(0), metrics: nil, views: views)
        
        visualFormat = String(format: "H:|-%d-[swapButton]-%d-|",
            constraintsModel.distanceFromEdge,
            constraintsModel.distanceFromEdge)
        
        let swapButtonWidthConst = NSLayoutConstraint.constraintsWithVisualFormat(
            visualFormat, options: NSLayoutFormatOptions(0), metrics: nil, views: views)
        
        let swapButtonHorizontalAlign = NSLayoutConstraint(item: swapButton, attribute: NSLayoutAttribute.CenterX, relatedBy: .Equal, toItem: self.view, attribute: .CenterX, multiplier: 1, constant: 0)
    
        visualFormat = String(format: "H:|-42-[bottomCountryLabel]",
            constraintsModel.distanceFromEdge)
        
        let bottomContryLabelLeftConst = NSLayoutConstraint.constraintsWithVisualFormat(
            visualFormat, options: NSLayoutFormatOptions(0), metrics: nil, views: views)
        
        visualFormat = String(format: "V:[bottomCountryLabel]-%d-[bottomTextField]",
            constraintsModel.countryLabelDistanceFromTextField)
        
        let bottomCountrylabelbottomConst = NSLayoutConstraint.constraintsWithVisualFormat(
            visualFormat, options: NSLayoutFormatOptions(0), metrics: nil, views: views)
    
        visualFormat = String(format: "H:|-%d-[topIcon(28)]-8-[topTextField]-36-|",
            constraintsModel.distanceFromEdge)
        
        let topTextFieldWidthConst = NSLayoutConstraint.constraintsWithVisualFormat(
            visualFormat, options: NSLayoutFormatOptions(0), metrics: nil, views: views)
        
        visualFormat = String(format: "H:|-%d-[bottomIcon(28)]-8-[bottomTextField]-36-|",
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
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        refreshData()
    }
    
    func refreshData(){
        self.updateUserHomeLocale()
        
        locationManager.getUserCurrentLocale()
            .onSuccess { locale in
                println("got success from GPS:")
                println(LocaleUtils.createCountryNameFromLocale(locale))
                self.updateUserCurrentLocale(locale)
                self.fetchCurrency()
                NSNotificationCenter.defaultCenter().postNotificationName("refreshDone", object: nil)
            }
            
            .onFailure { error in
                self.displayFailedToCurrentLocation()
                self.updateUserCurrentLocale(NSLocale(localeIdentifier: "en_US"))
                self.fetchCurrency()
                NSNotificationCenter.defaultCenter().postNotificationName("refreshDone", object: nil)
        }
        
    }
    
    func fetchCurrency() {
        ConvertsionRateManager().getConvertionRate(self.userModel)
                .onSuccess { conv in
                    self.userModel.updateConvertionRate(conv) }
                .onFailure { error in
                    println("failed to get conv rate")
                    self.displayFailedToResolveCurrencyError()
                    self.userModel.updateConvertionRate(1.0)}
    }
    
    func getConvertionRate(homeCurrency:String, currentCurrency:String) -> Future<Double> {
        
        let promisee = Promise<Double>()
        
        let url = NSURL(string: "http://rate-exchange.appspot.com/currency?from=\(currentCurrency)&to=\(homeCurrency)" )
        
        let request = NSURLRequest(URL: url!)
        NSURLConnection.sendAsynchronousRequest(request, queue: NSOperationQueue.mainQueue()) {(response, data, error) in
            
            println(response)
            var castedResponse = response as! NSHTTPURLResponse
            if error != nil {
                promisee.failure(NSError(domain: "CurrencyApiError", code: 503, userInfo: nil))
            } else {
                if(castedResponse.statusCode == 200){
                    var boardsDictionary: NSDictionary = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.MutableContainers, error: nil) as! NSDictionary

                    var conversionRate : Double = boardsDictionary.objectForKey("rate") as! Double;
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
        
        var tempText = self.bottomLabel.text
        self.bottomLabel.text = self.topLabel.text
        self.topLabel.text = tempText
        
        homeIsAtTop = !homeIsAtTop
        redraw()
        userModel.updateHomeAmount(0)
        
    }
    
    func updateUserCurrentLocale(locale:NSLocale){
        self.userModel.updateCurrentLocale(locale)
    }
    
    func updateUserHomeLocale() {
        println("updating home locale")
        let locale:NSLocale = locationManager.getUserHomeLocale()
        self.userModel.updateHomeLocale(locale)
    }
    
    func setBottomCountryText(){
        var userLanguage = NSLocale.preferredLanguages().description
        
        var userLanguageLocale = NSLocale(localeIdentifier: NSLocale.localeIdentifierFromComponents(NSDictionary(object: userLanguage, forKey: NSLocaleLanguageCode) as [NSObject : AnyObject]))
        var locale:NSLocale?
        if (homeIsAtTop) {
            locale = self.userModel.currentLocale
        } else {
            locale = self.userModel.homeLocale
        }
        if let loc = locale {
            let countryCode:String = loc.objectForKey(NSLocaleCountryCode) as! String
            var country: String = userLanguageLocale.displayNameForKey(NSLocaleCountryCode, value: countryCode)!
            bottomCountryLabel.text = country
        }
    }
    
    func setTopCountryText() {
        
        var userLanguage = NSLocale.preferredLanguages().description
        
        var userLanguageLocale = NSLocale(localeIdentifier: NSLocale.localeIdentifierFromComponents(NSDictionary(object: userLanguage, forKey: NSLocaleLanguageCode) as [NSObject : AnyObject]))
        
        var locale:NSLocale?
        if (homeIsAtTop) {
            locale = self.userModel.homeLocale
        } else {
            locale = self.userModel.currentLocale
        }
        if let loc = locale {
            let countryCode:String = loc.objectForKey(NSLocaleCountryCode) as! String
            var country: String = userLanguageLocale.displayNameForKey(NSLocaleCountryCode, value: countryCode)!
            topCountryLabel.text = country
        }
    }
    
    func setBottomCurrencyLabel() {
        var locale:NSLocale?
        if(homeIsAtTop) {
            locale = userModel.currentLocale
        } else {
            locale = userModel.homeLocale
        }
        if let loc = locale {
            bottomTextField.placeholder = loc.objectForKey(NSLocaleCurrencyCode) as? String
        }

    }

    func setTopCurrencyLabel() {
        var locale:NSLocale?
        if(homeIsAtTop) {
            locale = userModel.homeLocale
        } else {
            locale = userModel.currentLocale
        }
        
        if let loc = locale {
            topTextField.placeholder = loc.objectForKey(NSLocaleCurrencyCode) as? String
        }

    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true;
    }
    
    override func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent) {
        self.view.endEditing(true)
    }
    
    func normalizeText(input:String) -> NSString{
        return input.stringByReplacingOccurrencesOfString(",", withString: ".", options: NSStringCompareOptions.LiteralSearch, range: nil) as NSString
    }
    
    func isValid(input:NSString) -> Bool{
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
    
    func redraw(){
        setTopCountryText()
        setTopCurrencyLabel()
        setBottomCountryText()
        setBottomCurrencyLabel()
    }
    
    func homeLocaleHasChanged() {
        redraw()
    }
    
    func currentLocaleHasChanged() {
        redraw()
    }
    
    func topAmountEdited(theTextField:UITextField) -> Void {
        let normalizedNumber:NSString = self.normalizeText(topTextField.text)
        if self.isValid(normalizedNumber as String) {
            if (homeIsAtTop) {
                userModel.updateHomeAmount(normalizedNumber.doubleValue)
            } else {
                userModel.updateCurrentAmount(normalizedNumber.doubleValue)
            }
        } else {
            self.displayErrorMessage()
        }
    }
    
    func bottomAmountEdited(theTextField:UITextField) -> Void {
        let normalizedNumber:NSString = self.normalizeText(bottomTextField.text)
        if self.isValid(normalizedNumber as String) {
            if (homeIsAtTop) {
                userModel.updateCurrentAmount(normalizedNumber.doubleValue)
            } else {
                userModel.updateHomeAmount(normalizedNumber.doubleValue)
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
    
    func homeAmountChanged() {
        var text = String(format: "%.2f", userModel.homeAmount)
        if (userModel.homeAmount == 0) {
            text = ""
            self.topTextField.text = ""
            self.bottomTextField.text = ""
        }
        if(homeIsAtTop) {
            if (!topTextField.isFirstResponder()) {
                self.topTextField.text = text
            }
        } else {
            if (!bottomTextField.isFirstResponder()) {
                self.bottomTextField.text = text
            }
        }
    }
    
    func refreshButtonPressed(notification:NSNotification){
        refreshData()
    }
    
    func currentAmountChanged() {
        var text = String(format: "%.2f", userModel.currentAmount)
        if (userModel.currentAmount == 0) {
            text = ""
            self.topTextField.text = ""
            self.bottomTextField.text = ""
        }
        if (homeIsAtTop) {
            if (!bottomTextField.isFirstResponder()) {
                self.bottomTextField.text = text
            }
        } else {
            if (!topTextField.isFirstResponder()) {
                self.topTextField.text = text
            }
        }
    }
    
    init(userModel:UserModel) {
        super.init(nibName: nil, bundle: nil)
        self.userModel = userModel
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension String {
    
    func contains(find: String) -> Bool{
        return self.rangeOfString(find) != nil
    }
}

extension UIView {
    func rotate360Degrees(duration: CFTimeInterval = 1.0, completionDelegate: AnyObject? = nil) {
        let rotateAnimation = CABasicAnimation(keyPath: "transform.rotation")
        rotateAnimation.fromValue = 0.0
        rotateAnimation.toValue = CGFloat(M_PI * 2.0)
        rotateAnimation.duration = duration
        
        if let delegate: AnyObject = completionDelegate {
            rotateAnimation.delegate = delegate
        }
        self.layer.addAnimation(rotateAnimation, forKey: nil)
    }
}