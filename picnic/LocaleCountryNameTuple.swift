//
//  LocaleCountryNameTuple.swift
//  picnic
//
//  Created by Knut Nygaard on 29/03/15.
//  Copyright (c) 2015 Knut Nygaard. All rights reserved.
//

import Foundation

class LocaleCountryNameTuple {
    let locale:NSLocale!
    let countryName:String!
    
    init(locale:NSLocale){
        self.locale = locale
        self.countryName = LocaleUtils.createCountryNameFromLocale(locale)
    }
}