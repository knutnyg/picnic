//
//  SettingsViewController.swift
//  picnic
//
//  Created by Jan Tore Stølsvik on 18/03/15.
//  Copyright (c) 2015 Knut Nygaard. All rights reserved.
//

import UIKit
import Foundation

class SettingsViewController: UIViewController, UITextFieldDelegate {

    var topBannerView:TopBannerViewController!
    var homeCountryView:CountryTableViewController!
    var currentCountryView:CountryTableViewController!
    var topFilterField:UITextField!
    var bottomFilterField:UITextField!
    var topOverrideToggle:UISwitch!
    var bottomOverrideToggle:UISwitch!
    var delegate:TopBannerViewController!=nil
    var userModel:UserModel!
    var moved = false
    
    var topLocale:NSLocale?
    var bottomLocale:NSLocale?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.blueColor()
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "backButtonPressed:", name: "backPressed", object: nil)
        
        topBannerView = TopBannerViewController(userModel: userModel, activeViewController: self)
            .withBackButton()
        topBannerView.view.setTranslatesAutoresizingMaskIntoConstraints(false)
        
        topFilterField = createTextField()
        topFilterField.addTarget(self, action: Selector("topFilterTextEdited:"), forControlEvents: UIControlEvents.EditingChanged)
        
        topOverrideToggle = UISwitch()
        topOverrideToggle.setTranslatesAutoresizingMaskIntoConstraints(false)
        topOverrideToggle.addTarget(self, action: "topToggleChanged:", forControlEvents: .ValueChanged)
        topOverrideToggle.setOn(self.userModel.shouldOverrideGPS, animated: false)

        bottomOverrideToggle = UISwitch()
        bottomOverrideToggle.setTranslatesAutoresizingMaskIntoConstraints(false)
        bottomOverrideToggle.addTarget(self, action: "bottomToggleChanged:", forControlEvents: .ValueChanged)
        bottomOverrideToggle.setOn(self.userModel.shouldOverrideLogical, animated: false)
        
        bottomFilterField = createTextField()
        bottomFilterField.addTarget(self, action: Selector("bottomFilterTextEdited:"), forControlEvents: UIControlEvents.EditingChanged)
        bottomFilterField.addTarget(self, action: Selector("moveForKeyboard:"), forControlEvents: UIControlEvents.EditingDidBegin)

        currentCountryView = CountryTableViewController(locale: topLocale, userModel: userModel, selectorType: CountrySelectorType.GPS)
        currentCountryView.view.setTranslatesAutoresizingMaskIntoConstraints(false)
        
        homeCountryView = CountryTableViewController(locale: bottomLocale, userModel: userModel, selectorType: CountrySelectorType.HOME_COUNTRY)
        homeCountryView.view.setTranslatesAutoresizingMaskIntoConstraints(false)
        
        self.addChildViewController(topBannerView)
        self.addChildViewController(homeCountryView)
        self.addChildViewController(currentCountryView)
        
        view.addSubview(topBannerView.view)
        view.addSubview(topFilterField)
        view.addSubview(topOverrideToggle)
        view.addSubview(homeCountryView.view)
        view.addSubview(bottomFilterField)
        view.addSubview(bottomOverrideToggle)
        view.addSubview(currentCountryView.view)
        
        let views:[NSObject : AnyObject] = ["topBanner":topBannerView.view, "home":homeCountryView.view, "current":currentCountryView.view,
            "superView":self.view, "topFilter":topFilterField, "bottomFilter":bottomFilterField, "topToggle":topOverrideToggle, "bottomToggle":bottomOverrideToggle]
        
        let constraintModel = ParentConstraintsModel(
            bannerHeight: 70,
            keyboardHeight: 216,
            screenHeight: Int(view.frame.height)
        )
        
        var visualFormat = String(format: "V:|-0-[topBanner(%d)]-[topFilter]-[current(%d)]-[bottomFilter]-[home(%d)]",
            constraintModel.bannerHeight,
            200,
            200)
        
        var verticalLayout = NSLayoutConstraint.constraintsWithVisualFormat(
            visualFormat, options: NSLayoutFormatOptions(0), metrics: nil, views: views)
        
        visualFormat = "H:|-0-[topBanner]-0-|"
        
        var topBannerWidthConstraints = NSLayoutConstraint.constraintsWithVisualFormat(
            visualFormat, options: NSLayoutFormatOptions(0), metrics: nil, views: views)
        
        visualFormat = "H:|-0-[home]-0-|"
        
        var homeWidthConstraints = NSLayoutConstraint.constraintsWithVisualFormat(
            visualFormat, options: NSLayoutFormatOptions(0), metrics: nil, views: views)
        
        visualFormat = "H:|-0-[current]-0-|"
        
        var currentWidthConstraints = NSLayoutConstraint.constraintsWithVisualFormat(
            visualFormat, options: NSLayoutFormatOptions(0), metrics: nil, views: views)
        
        view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:[topBanner]-[topToggle]", options: NSLayoutFormatOptions(0), metrics: nil, views: views))
        view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:[current]-[bottomToggle]", options: NSLayoutFormatOptions(0), metrics: nil, views: views))
        
        view.addConstraints(verticalLayout)
        view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|-[topFilter]-[topToggle]-|", options: NSLayoutFormatOptions(0), metrics: nil, views: views))
        view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|-[bottomFilter]-[bottomToggle]-|", options: NSLayoutFormatOptions(0), metrics: nil, views: views))
        view.addConstraints(topBannerWidthConstraints)
        view.addConstraints(homeWidthConstraints)
        view.addConstraints(currentWidthConstraints)
        
    }
    
    override func touchesBegan(touches: NSSet, withEvent event: UIEvent) {
        self.view.endEditing(true)
        if (moved) {
            moveBackAfterKeyboard()
            moved = false
        }
    }
    
    func topFilterTextEdited(theTextField:UITextField) -> Void {
        if(theTextField.text.isEmpty){
            currentCountryView.setCountryArray(currentCountryView.createCountryNameList())
        } else {
            currentCountryView.setCountryArray(currentCountryView.createCountryNameList().filter{$0.countryName.lowercaseString.contains(theTextField.text.lowercaseString)} )
        }

    }
    
    func bottomFilterTextEdited(theTextField:UITextField) -> Void {
        if(theTextField.text.isEmpty){
            homeCountryView.setCountryArray(homeCountryView.createCountryNameList())
        } else {
            homeCountryView.setCountryArray(homeCountryView.createCountryNameList().filter{$0.countryName.lowercaseString.contains(theTextField.text.lowercaseString)} )
        }
        
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        if(moved) {
            moveBackAfterKeyboard()
            moved = false
        }
        textField.resignFirstResponder()
        return true;
    }

    
    func moveForKeyboard(sender: NSNotification) {
        moved = true
        UIView.animateWithDuration(0.3, animations: {self.view.frame.origin.y -= 150})
    }
    func moveBackAfterKeyboard() {
        UIView.animateWithDuration(0.3, animations: {self.view.frame.origin.y += 150})
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func backButtonPressed(notification: NSNotification){
        delegate.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func createTextField() -> UITextField{
        var textField = UITextField()
        
        textField.delegate = self
        textField.setTranslatesAutoresizingMaskIntoConstraints(false)
        textField.borderStyle = UITextBorderStyle.RoundedRect
        textField.placeholder = "Filter"
        textField.autocorrectionType = UITextAutocorrectionType.No
        textField.textAlignment = NSTextAlignment.Center
        textField.keyboardType = UIKeyboardType.Default
        textField.returnKeyType = UIReturnKeyType.Done
        
        return textField
    }
    
    func topToggleChanged(sender:UISwitch!) {
        if sender.on {
            NSNotificationCenter.defaultCenter().postNotificationName("shouldOverrideGPSChanged", object: true)
        } else {
            NSNotificationCenter.defaultCenter().postNotificationName("shouldOverrideGPSChanged", object: false)
        }
    }
    
    func bottomToggleChanged(sender:UISwitch!){
        if sender.on {
            NSNotificationCenter.defaultCenter().postNotificationName("shouldOverrideLogicalChanged", object: true)
        } else {
            NSNotificationCenter.defaultCenter().postNotificationName("shouldOverrideLogicalChanged", object: false)
        }

    }
    
    /* ----   Initializers   ----  */
    
    init(topLocale: NSLocale?, bottomLocale:NSLocale?, userModel:UserModel) {
        super.init()
        self.topLocale = topLocale
        self.bottomLocale = bottomLocale
        self.userModel = userModel
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    convenience override init() {
        self.init(topLocale: nil, bottomLocale: nil, userModel:UserModel())
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
