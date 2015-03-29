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
    var delegate:TopBannerViewController!=nil
    var moved = false
    
    var topLocale:NSLocale?
    var bottomLocale:NSLocale?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.blueColor()
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "backButtonPressed:", name: "backPressed", object: nil)
        
        topBannerView = TopBannerViewController()
            .withBackButton()
        topBannerView.view.setTranslatesAutoresizingMaskIntoConstraints(false)
        
        topFilterField = createTextField()
        topFilterField.addTarget(self, action: Selector("topFilterTextEdited:"), forControlEvents: UIControlEvents.EditingChanged)
        
        bottomFilterField = createTextField()
        bottomFilterField.addTarget(self, action: Selector("bottomFilterTextEdited:"), forControlEvents: UIControlEvents.EditingChanged)
        bottomFilterField.addTarget(self, action: Selector("moveForKeyboard:"), forControlEvents: UIControlEvents.EditingDidBegin)
        
        homeCountryView = CountryTableViewController(locale: topLocale)
        homeCountryView.view.setTranslatesAutoresizingMaskIntoConstraints(false)
        
        currentCountryView = CountryTableViewController(locale: bottomLocale)
        currentCountryView.view.setTranslatesAutoresizingMaskIntoConstraints(false)
        
        self.addChildViewController(topBannerView)
        self.addChildViewController(homeCountryView)
        self.addChildViewController(currentCountryView)
        view.addSubview(topBannerView.view)
        view.addSubview(topFilterField)
        view.addSubview(homeCountryView.view)
        view.addSubview(bottomFilterField)
        view.addSubview(currentCountryView.view)
        
        let views:[NSObject : AnyObject] = ["topBanner":topBannerView.view, "home":homeCountryView.view, "current":currentCountryView.view,
            "superView":self.view, "topFilter":topFilterField, "bottomFilter":bottomFilterField]
        
        let constraintModel = ParentConstraintsModel(
            bannerHeight: 70,
            keyboardHeight: 216,
            screenHeight: Int(view.frame.height)
        )
        
        var visualFormat = String(format: "V:|-0-[topBanner(%d)]-[topFilter]-[home(%d)]-15-[bottomFilter]-[current(%d)]",
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
        
        view.addConstraints(verticalLayout)
        view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|-[topFilter]-|", options: NSLayoutFormatOptions(0), metrics: nil, views: views))
        view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|-[bottomFilter]-|", options: NSLayoutFormatOptions(0), metrics: nil, views: views))
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
            homeCountryView.setCountryArray(homeCountryView.createCountryNameList())
        } else {
            homeCountryView.setCountryArray(homeCountryView.createCountryNameList().filter{$0.countryName.lowercaseString.contains(theTextField.text.lowercaseString)} )
        }

    }
    
    func bottomFilterTextEdited(theTextField:UITextField) -> Void {
        if(theTextField.text.isEmpty){
            currentCountryView.setCountryArray(homeCountryView.createCountryNameList())
        } else {
            currentCountryView.setCountryArray(homeCountryView.createCountryNameList().filter{$0.countryName.lowercaseString.contains(theTextField.text.lowercaseString)} )
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
    
    func withTopLocale(locale:NSLocale?) -> SettingsViewController {
        self.topLocale = locale
        return self
    }
    
    func withBottomLocale(locale:NSLocale?) -> SettingsViewController {
        self.topLocale = locale
        return self
    }
    
    /* ----   Initializers   ----  */
    
    init(topLocale: NSLocale?, bottomLocale:NSLocale?) {
        super.init()
        self.topLocale = topLocale
        self.bottomLocale = bottomLocale
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    convenience override init() {
        self.init(topLocale: nil, bottomLocale: nil)
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
