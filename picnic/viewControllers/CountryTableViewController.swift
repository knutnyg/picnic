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
    var panelConnection:PanelConnection!
    var localeCountryNameTupleList:[LocaleCountryNameTuple]!
    var rawCountryNameList:[LocaleCountryNameTuple]?
    
    var hasScrolled = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "reuseIdentifier")
        
        self.localeCountryNameTupleList = createCountryNameList()
    }
    
    
    func scrollToCurrentLocaleIfSet() {
        if let loc = self.locale {
            var calculatedLocaleCountryName = LocaleUtils.createCountryNameFromLocale(loc)
            
            var counter = 0
            for tuple in localeCountryNameTupleList {
                if  tuple.countryName == calculatedLocaleCountryName {
                    self.tableView.scrollToRowAtIndexPath(NSIndexPath(forRow: counter, inSection: 0), atScrollPosition: UITableViewScrollPosition.Middle, animated: false)
                }
                counter++
            }
        }
    }
    
    func createCountryNameList() -> [LocaleCountryNameTuple]{
        
        //Returning stored value to prevent redoing static work
        if self.rawCountryNameList != nil {
            return self.rawCountryNameList!
        }
        
        var localeCountryNameTupleList:[LocaleCountryNameTuple] = []
        
        let countryCodeList = NSLocale.ISOCountryCodes() as [String]
        var countryLocaleList = countryCodeList.map({countryCode in LocaleUtils.createLocaleFromCountryCode(countryCode)})
        
        for locale in countryLocaleList {
            localeCountryNameTupleList += [LocaleCountryNameTuple(locale: locale)]
        }
        
        let result = localeCountryNameTupleList.sorted { $0.countryName.localizedCaseInsensitiveCompare($1.countryName) ==  NSComparisonResult.OrderedAscending }
        self.rawCountryNameList = result
        return result
    }

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.localeCountryNameTupleList.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCellWithIdentifier("reuseIdentifier", forIndexPath: indexPath) as UITableViewCell
        cell.accessoryType = UITableViewCellAccessoryType.None

        let countryName = localeCountryNameTupleList[indexPath.row].countryName
        
        cell.textLabel?.text = countryName
        
        if let locale = self.locale {
            if let logicalLocaleCountryName = LocaleUtils.createCountryNameFromLocale(locale){
                if logicalLocaleCountryName == countryName {
                    cell.accessoryType = UITableViewCellAccessoryType.Checkmark
                }
            }
        }
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        var selectedCell = self.tableView.cellForRowAtIndexPath(indexPath)
        
        
        //Clear marks
        var cellCount = self.tableView.numberOfRowsInSection(0)
        for i in 0...cellCount {
            var cell = self.tableView.cellForRowAtIndexPath(NSIndexPath(forRow: i, inSection: 0))
            cell?.accessoryType = UITableViewCellAccessoryType.None
        }
        
        //Add new mark
        selectedCell!.accessoryType = UITableViewCellAccessoryType.Checkmark
        
        //Tell overservers of change
        switch panelConnection! {
            case .GPS:
            NSNotificationCenter.defaultCenter().postNotificationName("overrideGPSLocaleChanged", object: localeCountryNameTupleList[indexPath.row].locale)
            break
        case .Logical:
            NSNotificationCenter.defaultCenter().postNotificationName("overrideLogicalLocaleChanged", object: localeCountryNameTupleList[indexPath.row].locale)
            break
        }
    }

    func setCountryArray(localeCountryNameTuple:[LocaleCountryNameTuple]) {
        self.localeCountryNameTupleList = localeCountryNameTuple
        self.tableView.reloadData()
    }
    
    override func viewDidLayoutSubviews() {
        if(!hasScrolled) {
          scrollToCurrentLocaleIfSet()
            hasScrolled = true
        }
    }
    
    /* ----   Initializers   ---- */
    
    init(locale: NSLocale?, panelConnection:PanelConnection) {
        super.init()
        self.locale = locale
        self.panelConnection = panelConnection
    }
    
    override init(style: UITableViewStyle) {
        super.init(style: style)
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
