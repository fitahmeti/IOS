

import Foundation
import UIKit

class MessageFormat {
    
    let id: String
    let msg: String
    let subject: String
    
    init(dict: NSDictionary) {
        id = dict.getStringValue(key: "_id")
        msg = dict.getStringValue(key: "sMessage")
        subject = dict.getStringValue(key: "sSubject")
    }
}
