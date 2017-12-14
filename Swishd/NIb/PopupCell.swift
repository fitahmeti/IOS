//
//  PopupCell.swift
//  Swishd
//

import Foundation

class PopupCell: ConstrainedTableViewCell{

    @IBOutlet weak var lblTitle: UILabel!
    var parent: HistroySortView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func prepareUI(){
        lblTitle.textColor = UIColor.hexStringToUIColor(hexStr: "323232")
        lblTitle.font = UIFont.arialRegular(size: 15 * _widthRatio)
        if let idx = parent.selectedIndex{
            if self.tag == idx{
                lblTitle.textColor = UIColor.swdBlueColor()
                lblTitle.font = UIFont.arialBold(size: 15 * _widthRatio)
            }
        }
    }
}
