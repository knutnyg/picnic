//
//  MenuViewController.swift
//  picnic
//
//  Created by Knut Nygaard on 4/7/15.
//  Copyright (c) 2015 Knut Nygaard. All rights reserved.
//

import Foundation
import UIKit
import BButton
import StoreKit

class MenuViewController : UIViewController, SKPaymentTransactionObserver{
    
    var gpsButton:BButton!
    var countrySetup:BButton!
    var instructionAutomaticLabel:UILabel!
    var instructionManualLabel:UILabel!
    var userModel:UserModel!
    var delegate:ConverterViewController!
    var backButton:UIButton!
    var aboutButton:UIButton!
    var pointButton:BButton!
    var houseButton:BButton!
    var removeAdsButton:BButton!
    var removeAdsProduct:SKProduct?
    
    var backButtonItem:UIBarButtonItem!
    var aboutButtonItem:UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupNavigationBar()

        self.view.backgroundColor = UIColor.white
        NotificationCenter.default.addObserver(self, selector: "backButtonPressed:", name: NSNotification.Name(rawValue: "backPressed"), object: nil)
        NotificationCenter.default.addObserver(self, selector: "setupComplete:", name: NSNotification.Name(rawValue: "setupComplete"), object: nil)

        instructionAutomaticLabel = createLabel("Let Picnic guess where you are:")
        instructionManualLabel = createLabel("or you decide:")

        gpsButton = createBButton(" Automatic setup")
        gpsButton.addTarget(self, action: #selector(MenuViewController.autoSetupPressed(_:)), for: UIControlEvents.touchUpInside)
        
        pointButton = createBButton(" Set location")
        pointButton.addAwesomeIcon(FAIcon.FALocationArrow, beforeTitle: true)
        pointButton.addTarget(self, action: #selector(MenuViewController.pointPressed(_:)), for: UIControlEvents.touchUpInside)

        houseButton = createBButton(" Set home")
        houseButton.addAwesomeIcon(FAIcon.FAHome, beforeTitle: true)
        houseButton.addTarget(self, action: #selector(MenuViewController.housePressed(_:)), for: UIControlEvents.touchUpInside)
        
        removeAdsButton = createBButton("Temp")
        removeAdsButton.isHidden = true
        
        if !userModel.skipAds {
            if let product = userModel.removeAdProduct {
                removeAdsButton.isHidden = false
                removeAdsButton.setType(BButtonType.inverse)
                removeAdsButton.titleLabel!.font = UIFont.boldSystemFont(ofSize: 15)
                removeAdsButton.addTarget(self, action: #selector(MenuViewController.removeAdsPressed(_:)), for: UIControlEvents.touchUpInside)
                
                let formatter = NumberFormatter()
                formatter.numberStyle = NumberFormatter.Style.currency
                formatter.locale = product.priceLocale
                
                removeAdsButton.setTitle("Remove Ads: \(formatter.string(from: product.price)!)", for: UIControlState())
            }
        }
    
        setActiveButtonStyle()
        
        view.addSubview(instructionAutomaticLabel)
        view.addSubview(instructionManualLabel)
        view.addSubview(gpsButton)
        view.addSubview(pointButton)
        view.addSubview(houseButton)
        view.addSubview(removeAdsButton)
        
        let views = ["gps":gpsButton, "instructionsAuto":instructionAutomaticLabel, "instructionsManual":instructionManualLabel, "pointButton":pointButton, "houseButton":houseButton, "removeAdsButton":removeAdsButton] as [String : Any]
        
        let screenHeight = view.bounds.height
        let marginTop = Int((screenHeight - 24 - 160) / 2) - 66
        
        self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-\(marginTop)-[instructionsAuto]-[gps(40)]-40-[instructionsManual]-[pointButton(40)]-18-[houseButton(40)]-51-[removeAdsButton(45)]", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: views))
        self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-[instructionsAuto]-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: views))
        self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-[instructionsAuto]-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: views))
        
        view.addConstraint(NSLayoutConstraint(item: houseButton.titleLabel!, attribute: NSLayoutAttribute.width, relatedBy: NSLayoutRelation.equal, toItem: nil, attribute: NSLayoutAttribute.notAnAttribute, multiplier: 1, constant: 115))
        view.addConstraint(NSLayoutConstraint(item: pointButton.titleLabel!, attribute: NSLayoutAttribute.width, relatedBy: NSLayoutRelation.equal, toItem: nil, attribute: NSLayoutAttribute.notAnAttribute, multiplier: 1, constant: 115))
        view.addConstraint(NSLayoutConstraint(item: instructionManualLabel, attribute: NSLayoutAttribute.centerX, relatedBy: NSLayoutRelation.equal, toItem: self.view, attribute: NSLayoutAttribute.centerX, multiplier: 1, constant: 0))
        view.addConstraint(NSLayoutConstraint(item: gpsButton, attribute: NSLayoutAttribute.width, relatedBy: NSLayoutRelation.equal, toItem: nil, attribute: NSLayoutAttribute.notAnAttribute, multiplier: 1, constant: 180))
        view.addConstraint(NSLayoutConstraint(item: gpsButton, attribute: NSLayoutAttribute.centerX, relatedBy: NSLayoutRelation.equal, toItem: self.view, attribute: NSLayoutAttribute.centerX, multiplier: 1, constant: 0))
        view.addConstraint(NSLayoutConstraint(item: pointButton, attribute: NSLayoutAttribute.centerX, relatedBy: NSLayoutRelation.equal, toItem: self.view, attribute: NSLayoutAttribute.centerX, multiplier: 1, constant: 0))
        view.addConstraint(NSLayoutConstraint(item: pointButton, attribute: NSLayoutAttribute.width, relatedBy: NSLayoutRelation.equal, toItem: nil, attribute: NSLayoutAttribute.notAnAttribute, multiplier: 1, constant: 145))
        view.addConstraint(NSLayoutConstraint(item: houseButton, attribute: NSLayoutAttribute.centerX, relatedBy: NSLayoutRelation.equal, toItem: self.view, attribute: NSLayoutAttribute.centerX, multiplier: 1, constant: 0))
        view.addConstraint(NSLayoutConstraint(item: houseButton, attribute: NSLayoutAttribute.width, relatedBy: NSLayoutRelation.equal, toItem: nil, attribute: NSLayoutAttribute.notAnAttribute, multiplier: 1, constant: 145))
        view.addConstraint(NSLayoutConstraint(item: removeAdsButton, attribute: NSLayoutAttribute.centerX, relatedBy: NSLayoutRelation.equal, toItem: self.view, attribute: NSLayoutAttribute.centerX, multiplier: 1, constant: 0))
        view.addConstraint(NSLayoutConstraint(item: removeAdsButton, attribute: NSLayoutAttribute.width, relatedBy: NSLayoutRelation.equal, toItem: nil, attribute: NSLayoutAttribute.notAnAttribute, multiplier: 1, constant: 200))

        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        SKPaymentQueue.default().add(self)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        SKPaymentQueue.default().remove(self)
    }
    
    func createReloadButton() -> UIButton{
        let button = UIButton(type: UIButtonType.system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Reload", for: UIControlState())
        button.titleLabel!.font = UIFont(name:"Helvetica", size:30)
        return button
    }
    
    func parseResult(_ dict:Dictionary<String, Dictionary<String,String>>) -> [String:OfflineEntry]{
        var resultDict:[String:OfflineEntry] = [:]
    
        for key in dict.keys {
            let value = (dict[key]!["value"]! as NSString).doubleValue
            let from = dict[key]!["unit_from"]!
            let to = dict[key]!["unit_to"]!
            let timestamp = dict[key]!["timestamp"]!
            
            resultDict[key] = OfflineEntry(timeStamp: dateFromUTCString(timestamp), unit_from: from, unit_to: to, value: value)
        }
        return resultDict
    }
    
    func setupNavigationBar() {

        let font = UIFont(name: "Verdana", size: 22)!
        let attributes: [String:AnyObject] = [NSFontAttributeName: font, NSForegroundColorAttributeName: UIColor.white]
        navigationItem.title = "Menu"
        navigationController?.navigationBar.titleTextAttributes = attributes

        let verticalOffset = 3 as CGFloat;
        navigationController?.navigationBar.setTitleVerticalPositionAdjustment(verticalOffset, for: UIBarMetrics.default)

        backButton = createfontAwesomeButton("\u{f060}")
        backButton.addTarget(self, action: #selector(MenuViewController.back(_:)), for: UIControlEvents.touchUpInside)
        backButtonItem = UIBarButtonItem(customView: backButton)
        navigationItem.leftBarButtonItem = backButtonItem
        
        aboutButton = createfontAwesomeButton("\u{f128}")
        aboutButton.addTarget(self, action: #selector(MenuViewController.about(_:)), for: UIControlEvents.touchUpInside)
        aboutButtonItem = UIBarButtonItem(customView: aboutButton)
        navigationItem.rightBarButtonItem = aboutButtonItem
        
    }
    
    func back(_: UIEvent) {
        navigationController?.popViewController(animated: true)
    }
    
    func about(_:UIEvent) {
        let alertController = UIAlertController(title: "About Picnic", message: "Exchange rate data is provided by various sources with public-facing APIs. Data is refreshed approximately every 24h. \n\nRates are never 100% accurate and should never be relied on for serious financial decisions.", preferredStyle: UIAlertControllerStyle.alert)
        alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.default, handler: nil))
        self.present(alertController, animated: true, completion: nil)
    }
    
    func setupButtonPressed(_ sender:UIButton!){
        let vc = CountrySelectorViewController(userModel: self.userModel, selectorType: CountrySelectorType.home_COUNTRY)
        vc.delegate = self
        navigationController?.pushViewController(vc, animated: true)
    }
    
    func autoSetupPressed(_ sender:UIButton!){
        userModel.overrideGPSLocale = nil
        userModel.overrideLogicalLocale = nil
        navigationController?.popViewController(animated: true)
    }
    
    func pointPressed(_ sender:UIButton){
        let vc = CountrySelectorViewController(userModel: userModel, selectorType: CountrySelectorType.gps)
        navigationController?.pushViewController(vc, animated: true)
    }
    
    func housePressed(_ sender:UIButton){
        let vc = CountrySelectorViewController(userModel: userModel, selectorType: CountrySelectorType.home_COUNTRY)
        navigationController?.pushViewController(vc, animated: true)
    }
    
    func createBButton(_ title:String) -> BButton{
        let button = BButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle(title, for: UIControlState())
        button.setType(BButtonType.info)

        return button
    }
    
    func setActiveButtonStyle() {
        
        if userModel.overrideGPSLocale != nil {
            pointButton.setType(BButtonType.success)
        }
        
        if userModel.overrideLogicalLocale != nil {
            houseButton.setType(BButtonType.success)
        }
        
        if !userModel.isManualSetupActive() {
            gpsButton.setType(BButtonType.success)
            gpsButton.addAwesomeIcon(FAIcon.FACheck, beforeTitle: true)
        }
    }
    


    /* ----   Remove Ads   ----  */
    
    func removeAdsPressed(_ sender:UIButton){
        if let product = userModel.removeAdProduct {
            let payment = SKPayment(product: product)
            SKPaymentQueue.default().add(payment)
        }
    }
    
    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]){
        for transaction in transactions {
            let trans = transaction
            switch trans.transactionState {
            case .purchased:
                unlockFeature()
                SKPaymentQueue.default().finishTransaction(trans)
            case .failed:
                SKPaymentQueue.default().finishTransaction(trans)
            default:
                break
            }
        }
    }
    
    func unlockFeature(){
        userModel.skipAds = true
    }
    
    /* ----   Initializers   ----  */
    
    init(userModel:UserModel) {
        super.init(nibName: nil, bundle: nil)
        self.userModel = userModel
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
