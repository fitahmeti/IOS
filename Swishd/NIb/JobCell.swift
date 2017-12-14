import UIKit

enum JobCellType {
    case search
    case sender
    case swishr
    case searchResult
    case senderHistory
    case swishrHistory
}

class JobCell: ConstrainedTableViewCell {

    @IBOutlet var imgSize: UIImageView!
    @IBOutlet var lblSize: UILabel!
    @IBOutlet var lblName: UILabel!
    @IBOutlet var lblPrice: UILabel!
    @IBOutlet var lblPickDate: UILabel!
    @IBOutlet var lblDropDate: UILabel!
    @IBOutlet var lblPickAddress: UILabel!
    @IBOutlet var lblDropAddress: UILabel!
    @IBOutlet var lblPickTime: UILabel!
    @IBOutlet var lblDropTime: UILabel!
    @IBOutlet var btnShare: UIButton!
    
    @IBOutlet var lblStatus: UILabel!
    @IBOutlet var imgStatus: UIImageView!
    
    var parent: ProfileVC!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func prepareUIForSwishList(job: Job) {
        
        imgSize.kf.setImage(with: job.itemSize.imgUrl, completionHandler: { (img, error, catchType, url) in
            if let _ = img{
                self.imgSize.image = img?.withRenderingMode(UIImageRenderingMode.alwaysTemplate)
            }
        })
        imgSize.tintColor = UIColor.hexStringToUIColor(hexStr: "A0A0A0")
        lblSize.text = job.itemSize.title
        lblName.text = job.jobTitle
        lblPrice.text = "£\(job.recommandPrice)"
        lblPickDate.text = job.pickDateStr
        lblDropDate.text = job.dropDateStr
        lblPickAddress.text = job.pickAddress
        lblDropAddress.text = job.dropAddress
        lblPickTime.text = job.pickTimeStr
        lblDropTime.text = job.dropTimeStr
    }
    
    func prepareUIforJob(job: Job, type: JobCellType) {
        imgSize.kf.setImage(with: job.itemSize.imgUrl)
        lblSize.text = job.itemSize.title
        lblName.text = job.jobTitle
        lblPrice.text = "£\(job.recommandPrice)"
        lblPickDate.text = job.pickDateStr
        lblDropDate.text = job.dropDateStr
        lblPickAddress.text = job.pickAddress
        lblDropAddress.text = job.dropAddress
        lblPickTime.text = job.pickTimeStr
        lblDropTime.text = job.dropTimeStr
        
        if type == .swishrHistory || type == .senderHistory{
            lblStatus.text = job.status.rawValue.uppercased()
            btnShare.isHidden = true
            imgStatus.image = job.status == .completed ? UIImage(named: "ic_completed") : UIImage(named: "ic_inComplete")
        }
    }
}
