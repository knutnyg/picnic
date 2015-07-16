//
//  OfflineEntry.swift
//  picnic
//
//  Created by Knut Nygaard on 5/2/15.
//  Copyright (c) 2015 Knut Nygaard. All rights reserved.
//

import Foundation

class OfflineEntry : NSObject, NSCoding{
    var timeStamp:NSDate!
    var unit_from:String!
    var unit_to:String!
    var value:Double!
    
    init(timeStamp:NSDate, unit_from:String, unit_to:String, value:Double){
        self.timeStamp = timeStamp
        self.unit_from = unit_from
        self.unit_to = unit_to
        self.value = value
    }
    
    func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(timeStamp, forKey: "timestamp")
        aCoder.encodeObject(unit_from, forKey: "unit_from")
        aCoder.encodeObject(unit_to, forKey: "unit_to")
        aCoder.encodeObject(value, forKey: "value")
    }
    
    required init?(coder aDecoder: NSCoder) {
        self.timeStamp = aDecoder.decodeObjectForKey("timestamp") as! NSDate
        self.unit_from = aDecoder.decodeObjectForKey("unit_from") as! String
        self.unit_to = aDecoder.decodeObjectForKey("unit_to") as! String
        self.value = aDecoder.decodeObjectForKey("value") as! Double
    }
}
