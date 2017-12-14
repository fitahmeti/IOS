

import UIKit

class NotificationSection: NSObject{
    var title: String!
    var arrNotificationSetting: [NotificationSetting] = []
    
    init(title: String, arrNotificationSetting: [NotificationSetting]) {
        self.title = title
        self.arrNotificationSetting = arrNotificationSetting
    }
}

class NotificationSetting: NSObject{
    
    var id: String
    var type: NotiType
    var subType: String
    var status: Bool
    
    init(dict: NSDictionary) {
        id = dict.getStringValue(key: "_id")
        type = NotiType(rawValue: dict.getStringValue(key: "sType"))!
        subType = dict.getStringValue(key: "sSettingName")
        status = dict.getBooleanValue(key: "eStatus")
    }
}
