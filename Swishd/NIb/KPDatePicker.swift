import Foundation
import UIKit

class KPDatePicker: ConstrainedView{
    
    //MARK:- IBActions
    @IBAction func cancelTap(sender: UIButton){
        removeViewWithAnimation()
    }
    
    @IBAction func doneTap(sender: UIButton){
        selectionBlock?(datePicker.date)
        removeViewWithAnimation()
    }
    
    @IBAction func dataPickerValueChange(sender: UIDatePicker){
       //jprint(sender.date)
    }
    
    
    //MARK:- IBOutlets
    @IBOutlet var datePicker: UIDatePicker!
    @IBOutlet var datePickerBottom: NSLayoutConstraint!
    
    //MARK:- Variables
    var selectionBlock:((_ date: Date)->())?
    
    //MARK:- View life cycle
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        let loc = touches.first?.location(in: self)
        if let location = loc{
            if location.y < (_screenSize.height - _datePickerHideConstant){
                removeViewWithAnimation()
            }
        }
    }
    
    //MARK:- Other
    class func instantiateViewFromNib(withView view: UIView) -> KPDatePicker {
        let obj = Bundle.main.loadNibNamed("KPDatePicker", owner: nil, options: nil)![0] as! KPDatePicker
        _appDelegator.window?.addSubview(obj)
        obj.addConstraintToSuperView(lead: 0, trail: 0, top: 0, bottom: 0)
        //Animation
        obj.datePickerBottom.constant = -_datePickerHideConstant
        obj.layoutIfNeeded()
        obj.datePickerBottom.constant = 0
//        obj.datePicker.setValue(UIColor.white, forKey: "textColor")
//        obj.datePicker.setValue(false, forKey: "highlightsToday")
        UIView.animate(withDuration: _pickerAnimationTime, animations: {
            obj.layoutIfNeeded()
        })
        return obj
    }
        
    func removeViewWithAnimation(){
        datePickerBottom.constant = -_datePickerHideConstant
        UIView.animate(withDuration: _pickerAnimationTime, animations: {
                self.layoutIfNeeded()
            }) { (done) in
                self.removeFromSuperview()
        }
    }
}
