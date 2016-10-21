//
//  OfflineEntry.swift
//  picnic
//
//  Created by Knut Nygaard on 5/2/15.
//  Copyright (c) 2015 Knut Nygaard. All rights reserved.
//

import Foundation

class OfflineEntry : NSObject, NSCoding{
    var timeStamp:Date!
    var unit_from:String!
    var unit_to:String!
    var value:Double!
    
    init(timeStamp:Date, unit_from:String, unit_to:String, value:Double){
        self.timeStamp = timeStamp
        self.unit_from = unit_from
        self.unit_to = unit_to
        self.value = value
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(timeStamp, forKey: "timestamp")
        aCoder.encode(unit_from, forKey: "unit_from")
        aCoder.encode(unit_to, forKey: "unit_to")
        aCoder.encode(value, forKey: "value")
    }
    
    required init(coder aDecoder: NSCoder) {
        self.timeStamp = aDecoder.decodeObject(forKey: "timestamp") as! Date
        self.unit_from = aDecoder.decodeObject(forKey: "unit_from") as! String
        self.unit_to = aDecoder.decodeObject(forKey: "unit_to") as! String
        self.value = aDecoder.decodeObject(forKey: "value") as! Double
    }
}
