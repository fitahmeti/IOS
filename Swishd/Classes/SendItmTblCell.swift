

import UIKit

class SendItmTblCell: ConstrainedTableViewCell {

    @IBOutlet var lblTitle: UILabel!
    @IBOutlet var lblDesc: UILabel!
    @IBOutlet var imgView: UIImageView!
    @IBOutlet var imgTick: UIImageView!
    @IBOutlet var tfTitle: UITextField!
    @IBOutlet var lblSeparator: UIView!
    @IBOutlet var viewShadowTop: NSLayoutConstraint!
    @IBOutlet var viewShadowBottom: NSLayoutConstraint!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
}
