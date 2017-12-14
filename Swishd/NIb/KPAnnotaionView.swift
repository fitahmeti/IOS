//
//  KPAnnotaionView.swift
//  Swishd
//
//
//

import Foundation
import MapKit

class KPAnnotaionView: MKAnnotationView {
    
    // MARK: Outlets
    @IBOutlet var horizontalConstraints: [NSLayoutConstraint]?
    @IBOutlet var verticalConstraints: [NSLayoutConstraint]?
    @IBOutlet var lblTitle: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        constraintUpdate()
        self.layer.anchorPoint = CGPoint(x: 0.5, y: 1.0)
    }
    
    override var reuseIdentifier: String?{
        return "mapPin"
    }
    
    class func createObjectFromNib() -> KPAnnotaionView {
        let obj = Bundle.main.loadNibNamed("KPAnnotaionView", owner: nil, options: nil)![0] as! KPAnnotaionView
        obj.frame = CGRect(x: 0, y: 0, width: 50 * _widthRatio, height: 53 * _widthRatio)
        return obj
    }
    
    func constraintUpdate() {
        if let hConts = horizontalConstraints {
            for const in hConts {
                let v1 = const.constant
                let v2 = v1 * _widthRatio
                const.constant = v2
            }
        }
        if let vConst = verticalConstraints {
            for const in vConst {
                let v1 = const.constant
                let v2 = v1 * _heighRatio
                const.constant = v2
            }
        }
    }
}
