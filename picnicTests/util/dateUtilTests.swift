//
// Created by Knut Nygaard on 11/11/2016.
// Copyright (c) 2016 Knut Nygaard. All rights reserved.
//

import Foundation
import XCTest

class dateUtilTests : XCTestCase {

    func testParserZulutidKorrekt(){
        let date = dateFromUTCString("2016-11-11T16:45:09Z")

        let dateformatter = DateFormatter()
        dateformatter.dateFormat = "HH:mm"
        dateformatter.timeZone = TimeZone(identifier: "UTC")

        XCTAssertEqual(dateformatter.string(from: date), "16:45")
    }
}
