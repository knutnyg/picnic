//
//  CountryTableViewController.swift
//  picnic
//
//  Created by Jan Tore Stølsvik on 15/03/15.
//  Copyright (c) 2015 Knut Nygaard. All rights reserved.
//

import UIKit

class CountryTableViewController: UITableViewController {
    
    var locale:Locale?
    var country:NSString?
    var selectorType:CountrySelectorType!
    var localeCountryNameTupleList:[LocaleCountryNameTuple]!
    var rawCountryNameList:[LocaleCountryNameTuple]?
    var userModel:UserModel!
    
    var hasScrolled = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: "reuseIdentifier")
        
        self.localeCountryNameTupleList = createCountryNameList()
        
        switch selectorType! {
        case .gps:
            locale = userModel.currentLocale as Locale?
        case .home_COUNTRY:
            locale = userModel.homeLocale as Locale?
        }
    }

    func scrollToCurrentLocaleIfSet() {
        if let loc = self.locale {
            let calculatedLocaleCountryName = LocaleUtils.createCountryNameFromLocale(loc)
            
            var counter = 0
            for tuple in localeCountryNameTupleList {
                if  tuple.countryName == calculatedLocaleCountryName {
                    self.tableView.scrollToRow(at: IndexPath(row: counter, section: 0), at: UITableViewScrollPosition.middle, animated: false)
                }
                counter += 1
            }
        }
    }
    
    func createCountryNameList() -> [LocaleCountryNameTuple]{
        
        //Returning stored value to prevent redoing static work
        if self.rawCountryNameList != nil {
            return self.rawCountryNameList!
        }
        
        var localeCountryNameTupleList:[LocaleCountryNameTuple] = []
        
        let currencies = readFileAsString("supported_currencies",ofType:"txt")
//        var currencyList = split(currencies!) {$0 == "\n"}
        let currencyList = currencies.map({$0 + "\n"})
        
        //finn alle land
        let rawCountryList = Locale.isoRegionCodes

        //lag locale objecter
        let rawLocaleList:[Locale] = rawCountryList.map({countryCode in LocaleUtils.createLocaleFromCountryCode(countryCode as NSString)})

        //filtrer land der currency finnes i støttet liste
        let filteredList = rawLocaleList.filter({locale in
            return (currencyList?.contains((locale as NSLocale).object(forKey: NSLocale.Key.currencyCode) as! String))!
                })
        
        for locale in filteredList {
            localeCountryNameTupleList += [LocaleUtils.createLocaleCountryNameTuple(locale, language: userModel.languageLocale)]
        }
        
        let result = localeCountryNameTupleList.sorted { $0.countryName.localizedCaseInsensitiveCompare($1.countryName) ==  ComparisonResult.orderedAscending }
        self.rawCountryNameList = result
        return result
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.localeCountryNameTupleList.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)
        cell.accessoryType = UITableViewCellAccessoryType.none

        let countryName = localeCountryNameTupleList[(indexPath as NSIndexPath).row].countryName
        
        cell.textLabel?.text = countryName
        
        if let locale = self.locale {
            if let logicalLocaleCountryName = LocaleUtils.createCountryNameFromLocale(locale){
                if logicalLocaleCountryName == countryName {
                    cell.accessoryType = UITableViewCellAccessoryType.checkmark
                }
            }
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedCell = self.tableView.cellForRow(at: indexPath)
        
        let cellCount = self.tableView.numberOfRows(inSection: 0)
        for i in 0...cellCount {
            let cell = self.tableView.cellForRow(at: IndexPath(row: i, section: 0))
            cell?.accessoryType = UITableViewCellAccessoryType.none
        }
        
        selectedCell!.accessoryType = UITableViewCellAccessoryType.checkmark
        
        switch selectorType! {
        case .home_COUNTRY:
            userModel.overrideLogicalLocale = localeCountryNameTupleList[(indexPath as NSIndexPath).row].locale
            break
        case .gps:
            userModel.overrideGPSLocale = localeCountryNameTupleList[(indexPath as NSIndexPath).row].locale
            break
        }
        navigationController?.popToRootViewController(animated: true)
    }

    func setCountryArray(_ localeCountryNameTuple:[LocaleCountryNameTuple]) {
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
    
    init(userModel:UserModel, selectorType:CountrySelectorType) {
        super.init(nibName: nil, bundle: nil)
        self.userModel = userModel
        self.selectorType = selectorType
    }
    
    override init(style: UITableViewStyle) {
        super.init(style: style)
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
