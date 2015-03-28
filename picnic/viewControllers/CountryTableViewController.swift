//
//  CountryTableViewController.swift
//  picnic
//
//  Created by Jan Tore Stølsvik on 15/03/15.
//  Copyright (c) 2015 Knut Nygaard. All rights reserved.
//

import UIKit

class CountryTableViewController: UITableViewController {
    
    var locale:NSLocale?
    var country:NSString?
    var countryNameList:[String]!
    var rawCountryNameList:[String]?
    
    init(test: NSString?) {
        super.init()
        self.country = test
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "reuseIdentifier")
        
        self.countryNameList = createCountryNameList()
        
        if country == nil {
            country = ""
        }
        
        var homeSettingsString:NSString? = NSUserDefaults.standardUserDefaults().objectForKey(country!) as? NSString
        
        if (homeSettingsString != nil) {
            locale = NSLocale(localeIdentifier: homeSettingsString!)
        }
        
        self.tableView.scrollToRowAtIndexPath(NSIndexPath(forRow: 20, inSection: 0), atScrollPosition: UITableViewScrollPosition.Middle, animated: true)
    }
    
    func createCountryNameList() -> [String]{
        //Returning stored value to prevent redoing static work
        if self.rawCountryNameList != nil {
            return self.rawCountryNameList!
        }
        
        let countryCodeList = NSLocale.ISOCountryCodes() as [String]
        var countryLocaleList = countryCodeList.map({countryCode in self.createLocaleFromCountryCode(countryCode)})
        var countryNames:[String] = countryLocaleList.map({
            locale in
            if let name = self.createCountryNameFromLocale(locale) {
                return name
            }
            return ""
        })
        var result = countryNames.sorted { $0.localizedCaseInsensitiveCompare($1) == NSComparisonResult.OrderedAscending }
        self.rawCountryNameList = result
        return result
    }
    
    func createLocaleFromCountryCode(countryCode:NSString)->NSLocale {
        return NSLocale(localeIdentifier: NSLocale.localeIdentifierFromComponents([NSLocaleCountryCode:countryCode]))
    }
    
    func createCountryNameFromLocale(locale:NSLocale) -> String? {
        let countryCode: String? = locale.objectForKey(NSLocaleCountryCode) as? String
        if let cc = countryCode {
            return locale.displayNameForKey(NSLocaleCountryCode, value: cc)
        }
        return nil
    }

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.countryNameList.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCellWithIdentifier("reuseIdentifier", forIndexPath: indexPath) as UITableViewCell
        cell.accessoryType = UITableViewCellAccessoryType.None
        var countryName:String = countryNameList[indexPath.row]
        
        cell.textLabel?.text = countryName
        
        if let locale = self.locale {
            if let countryName = createCountryNameFromLocale(locale){
                cell.accessoryType = UITableViewCellAccessoryType.Checkmark
            }
        }
        return cell
    }
    
    func setCountryArray(countryNameList:[String]) {
        self.countryNameList = countryNameList
        self.tableView.reloadData()
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override init(style: UITableViewStyle) {
        super.init(style: style)
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    convenience override init() {
        self.init(test: nil)
    }
}
