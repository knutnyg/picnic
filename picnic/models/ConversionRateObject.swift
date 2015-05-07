//
//  ConversionRateObject.swift
//  picnic
//
//  Created by Knut Nygaard on 5/5/15.
//  Copyright (c) 2015 Knut Nygaard. All rights reserved.
//

import Foundation

class ConversionRateObject {
    var value:Double!
    var timestamp:NSDate!
    
    init(value:Double, timestamp:NSDate){
        self.value = value
        self.timestamp = timestamp
    }
}