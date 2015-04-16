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

    // -- App Elements -- //
    var userModel:UserModel!
    var locationManager:LocationManager!

    let userDefaults = NSUserDefaults.standardUserDefaults();
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        userModel.addObserver(self)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "refreshButtonPressed:", name: "refreshPressed", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "setupComplete:", name: "setupComplete", object: nil)
        
        locationManager = LocationManager(userModel: self.userModel)
        topCountryLabel = UILabel()
        topCountryLabel.setTranslatesAutoresizingMaskIntoConstraints(false)
        
        topTextField = createTextField()
        topTextField.addTarget(self, action: Selector("topAmountEdited:"), forControlEvents: UIControlEvents.EditingChanged)
        
        bottomCountryLabel = UILabel()
        bottomCountryLabel.setTranslatesAutoresizingMaskIntoConstraints(false)

        bottomTextField = createTextField()
        bottomTextField.addTarget(self, action: Selector("bottomAmountEdited:"), forControlEvents: UIControlEvents.EditingChanged)
        
        topLabel = createFALabel("\u{f124}")
        bottomLabel = createFALabel("\u{f015}")
        
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
        
        self.setConstraints(views)
    }
    
    
    func withUserModel(userModel:UserModel) -> ConverterViewController{
        self.userModel = userModel
        return self
    }
    
    func setConstraints(views: [NSObject:AnyObject]){

        var screenSize = Double(view.bounds.height)
        var textFieldHeight = Int(screenSize * 0.10)
        var topTextFieldMarginTop = Int(screenSize * 0.14)
        var swapButtonMarginTopAndBottom = Int(screenSize * 0.045)
        var countryLabelDistanceFromTextField = Int(screenSize * 0.003)
        var distanceFromEdge = Int(screenSize * 0.01)
        
        var textFieldFontSize = CGFloat(screenSize * 0.033)
        var swapButtonFontSize = CGFloat(screenSize * 0.082)
        var iconFontSize = CGFloat(screenSize * 0.045)
        
        self.topTextField.font = UIFont(name: "Verdana", size: textFieldFontSize)
        self.swapButton.titleLabel!.font = UIFont(name: "FontAwesome", size: swapButtonFontSize)
        self.bottomTextField.font = UIFont(name: "Verdana", size: textFieldFontSize)
        self.topLabel.font = UIFont(name: "FontAwesome", size: iconFontSize)
        self.bottomLabel.font = UIFont(name: "FontAwesome", size: iconFontSize)
        
        var visualFormat = String(format: "V:[topTextField(%d)]-%d-[swapButton]-%d-[bottomTextField(%d)]-0-|",
            textFieldHeight,
            swapButtonMarginTopAndBottom,
            swapButtonMarginTopAndBottom,
            textFieldHeight)
        
        let verticalLayout = NSLayoutConstraint.constraintsWithVisualFormat(
            visualFormat, options: NSLayoutFormatOptions(0), metrics: nil, views: views)
        
        visualFormat = String(format: "V:[topCountryLabel]-%d-[topTextField]",
            countryLabelDistanceFromTextField)
        
        let topCountrylabelSpaceToTextField = NSLayoutConstraint.constraintsWithVisualFormat(
            visualFormat, options: NSLayoutFormatOptions(0), metrics: nil, views: views)
        
        view.addConstraint(NSLayoutConstraint(item: topLabel, attribute: NSLayoutAttribute.CenterY, relatedBy: .Equal, toItem: topTextField, attribute: .CenterY, multiplier: 1, constant: 0))
        view.addConstraint(NSLayoutConstraint(item: bottomLabel, attribute: NSLayoutAttribute.CenterY, relatedBy: .Equal, toItem: bottomTextField, attribute: .CenterY, multiplier: 1, constant: 0))
        
        view.addConstraint(NSLayoutConstraint(item: topCountryLabel, attribute: NSLayoutAttribute.Left, relatedBy: .Equal, toItem: topTextField, attribute: NSLayoutAttribute.Left, multiplier: 1, constant: 0))
        
        visualFormat = String(format: "H:|-%d-[swapButton]-%d-|",
            distanceFromEdge,
            distanceFromEdge)
        
        let swapButtonWidthConst = NSLayoutConstraint.constraintsWithVisualFormat(
            visualFormat, options: NSLayoutFormatOptions(0), metrics: nil, views: views)
        
        let swapButtonHorizontalAlign = NSLayoutConstraint(item: swapButton, attribute: NSLayoutAttribute.CenterX, relatedBy: .Equal, toItem: self.view, attribute: .CenterX, multiplier: 1, constant: 0)
    
        view.addConstraint(NSLayoutConstraint(item: bottomCountryLabel, attribute: NSLayoutAttribute.Left, relatedBy: .Equal, toItem: bottomTextField, attribute: NSLayoutAttribute.Left, multiplier: 1, constant: 0))
        
        visualFormat = String(format: "V:[bottomCountryLabel]-%d-[bottomTextField]",
            countryLabelDistanceFromTextField)
        
        let bottomCountrylabelbottomConst = NSLayoutConstraint.constraintsWithVisualFormat(
            visualFormat, options: NSLayoutFormatOptions(0), metrics: nil, views: views)
        
        let size: CGSize = bottomLabel.text!.sizeWithAttributes([NSFontAttributeName: bottomLabel.font])
        var labelWidth = size.width + CGFloat(2*distanceFromEdge)
        
        visualFormat = String(format: "H:|-%d-[topIcon(\(size.width))]-%d-[topTextField]-\(labelWidth)-|",
            distanceFromEdge,distanceFromEdge)
        
        let topTextFieldWidthConst = NSLayoutConstraint.constraintsWithVisualFormat(
            visualFormat, options: NSLayoutFormatOptions(0), metrics: nil, views: views)
        
        visualFormat = String(format: "H:|-%d-[bottomIcon(\(size.width))]-%d-[bottomTextField]-\(labelWidth)-|",
            distanceFromEdge,distanceFromEdge)
        
        let bottomTextFieldWidthConst = NSLayoutConstraint.constraintsWithVisualFormat(
            visualFormat, options: NSLayoutFormatOptions(0), metrics: nil, views: views)
        
        self.view.addConstraints(verticalLayout)
        self.view.addConstraints(topCountrylabelSpaceToTextField)
        self.view.addConstraints(topTextFieldWidthConst)
        self.view.addConstraint(swapButtonHorizontalAlign)
        self.view.addConstraints(bottomCountrylabelbottomConst)
        self.view.addConstraints(bottomTextFieldWidthConst)
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        refreshData()
        topTextField.text = ""
        bottomTextField.text = ""
    }
    
    func refreshData(){
        self.updateUserHomeLocale()
        
        locationManager.getUserCurrentLocale(true)
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
    
    func swapButtonPressed(sender:UIButton!){
        self.view.endEditing(true)
        userModel.updateCurrentAmount(nil)
        userModel.updateHomeAmount(nil)
    }
    
    func updateUserCurrentLocale(locale:NSLocale){
        self.userModel.updateCurrentLocale(locale)
    }
    
    func updateUserHomeLocale() {
        let locale:NSLocale = locationManager.getUserHomeLocale(true)
        self.userModel.updateHomeLocale(locale)
    }
    
    func setBottomCountryText(){
        var userLanguage = NSLocale.preferredLanguages().description
        
        var userLanguageLocale = NSLocale(localeIdentifier: NSLocale.localeIdentifierFromComponents(NSDictionary(object: userLanguage, forKey: NSLocaleLanguageCode) as [NSObject : AnyObject]))
        if let locale = self.userModel.homeLocale {
            let countryCode:String = locale.objectForKey(NSLocaleCountryCode) as! String
            var country: String = userLanguageLocale.displayNameForKey(NSLocaleCountryCode, value: countryCode)!
            bottomCountryLabel.text = country
        }
    }
    
    func setTopCountryText() {
        
        var userLanguage = NSLocale.preferredLanguages().description
        
        var userLanguageLocale = NSLocale(localeIdentifier: NSLocale.localeIdentifierFromComponents(NSDictionary(object: userLanguage, forKey: NSLocaleLanguageCode) as [NSObject : AnyObject]))
        
        if let locale = userModel.currentLocale {
            let countryCode:String = locale.objectForKey(NSLocaleCountryCode) as! String
            var country: String = userLanguageLocale.displayNameForKey(NSLocaleCountryCode, value: countryCode)!
            topCountryLabel.text = country
        }
    }
    
    func setBottomCurrencyLabel() {
        if let locale = userModel.homeLocale {
            bottomTextField.placeholder = locale.objectForKey(NSLocaleCurrencyCode) as? String
        }

    }

    func setTopCurrencyLabel() {
        if let loc = userModel.currentLocale {
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
            if normalizedNumber == "" {
                userModel.updateCurrentAmount(nil)
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
            if normalizedNumber == "" {
                userModel.updateHomeAmount(nil)
            } else {
                userModel.updateHomeAmount(normalizedNumber.doubleValue)
            }
        } else {
            self.displayErrorMessage()
        }
    }
    
    func setupComplete(notification:NSNotification){
        clearTextFields()
    }
    
    func clearTextFields() {
        self.topTextField.text = ""
        self.bottomTextField.text = ""
    }
    
    func createFALabel(unicode:String) -> UILabel{
        var screenSize = view.bounds.height
        var label = UILabel()
        label.setTranslatesAutoresizingMaskIntoConstraints(false)
        label.text = unicode
        label.textAlignment = NSTextAlignment.Center
        return label
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
        var text = ""
        if let amount = userModel.homeAmount {
            text = String(format: "%.2f", amount)
        }
        if(!bottomTextField.isFirstResponder()){
            bottomTextField.text = text
        }
    }
    
    func refreshButtonPressed(notification:NSNotification){
        refreshData()
    }
    
    func currentAmountChanged() {
        var text = ""
        if let amount = userModel.currentAmount {
            text = String(format: "%.2f", amount)
        }
        if(!topTextField.isFirstResponder()){
            topTextField.text = text
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