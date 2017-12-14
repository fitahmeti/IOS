

import Foundation
import UIKit

class ScanData {
    let id: String
    let code: String
    var type: CodeType = CodeType.unknown
    let job: Job!
    
    init(dict: NSDictionary) {
        id = dict.getStringValue(key: "_id")
        code = dict.getStringValue(key: "sScanCode")
        type = CodeType(str: dict.getStringValue(key: "sType"))
        
        if let jobDict = dict["job"] as? NSDictionary{
            job = Job(dict: jobDict)
        }else{
            job = nil
        }
    }
    
    func validateCode() -> (Bool, String) {
        if job.isSentByMe{
            return (false, "You are not a swishr or collection point of this job.")
        }else{
            if job.isSwishByMe && job.status == .active && job.pickOffice == nil && type == CodeType.directPickUp{
                return (true, "Are you sure you want to pickup \(job.jobTitle) from sender")
            }else if job.isSwishByMe && job.status == .inProgress && job.dropOffice == nil && type == CodeType.directDeliver{
                return (true, "Are you sure you want to deliver \(job.jobTitle) to receiver?")
            }else if _user.isCollectionPoint && job.status == .active && type == CodeType.dropToPickOffice{
                return (true, "Are you sure you want to receive \(job.jobTitle) at collection point?")
            }else if _user.isCollectionPoint && job.status == .active && type == CodeType.receiveFromPickOffice{
                return (true, "Are you sure you want to deliver \(job.jobTitle) to swishr \(job.swishr!.userName)?")
            }else if _user.isCollectionPoint && job.status == .inProgress && type == CodeType.dropToDelOffice{
                return (true, "Are you sure you want to deliver \(job.jobTitle) to collection point?")
            }else if _user.isCollectionPoint && job.status == .inProgress && type == CodeType.receiveFromDelOffice{
                return (true, "Are you sure you want to deliver \(job.jobTitle) to receiver?")
            }else{
                return (false, "Invalid code or job state.")
            }
        }
//        return(false, "")
    }
}
