

import Foundation
import UIKit
import CoreData

class ItemSize: NSManagedObject, ParentManagedObject{
    
    @NSManaged var id: String
    @NSManaged var title: String
    @NSManaged var desc: String
    @NSManaged var image: String
    @NSManaged var seq: Int32
    
    override var hashValue: Int{
        return id.hashValue
    }
    
    var imgUrl: URL?{
        return URL(string: "\(_baseUrlFile)\(image)")
    }
    
    func initWith(dict: NSDictionary) {
        id = dict.getStringValue(key: "_id")
        title = dict.getStringValue(key: "sSizeTitle").trimmedString()
        desc = dict.getStringValue(key: "sSizeDescription").trimmedString()
        image = dict.getStringValue(key: "sOriginalSizePicture")
        if let _ = dict["sSort"] as? NSNumber{
            seq = dict.getInt32Value(key: "sSort")
        }
    }
}
