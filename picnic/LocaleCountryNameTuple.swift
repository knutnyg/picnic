//
//  LocaleCountryNameTuple.swift
//  picnic
//
//  Created by Knut Nygaard on 29/03/15.
//  Copyright (c) 2015 Knut Nygaard. All rights reserved.
//

import Foundation

class LocaleCountryNameTuple {
    let locale:Locale!
    let countryName:String!
    
    init(locale:Locale, countryName:String){
        self.locale = locale
        self.countryName = countryName
    }
}
