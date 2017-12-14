//
//  SWDatePicker.swift

import Foundation

class SWDatePicker: ConstrainedView{
    
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
    
    @IBAction func todayAction(_ sender: UIButton){
        selectionBlock?(Date())
        removeViewWithAnimation()
    }
    
    @IBAction func tomorrowAction(_ sender: UIButton){
        selectionBlock?(Date().getTomorrowDate())
        removeViewWithAnimation()
    }
    
    
    //MARK:- IBOutlets
    @IBOutlet var datePicker: UIDatePicker!
    @IBOutlet var datePickerBottom: NSLayoutConstraint!
    @IBOutlet var vwBackground: UIView!
    
    //MARK:- Variables
    var selectionBlock:((_ date: Date)->())?
    
    //MARK:- View life cycle
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        let loc = touches.first?.location(in: self)
        if let location = loc{
            if location.y < (_screenSize.height - _swdDatePickerhideConstant){
                removeViewWithAnimation()
            }
        }
    }
    
    //MARK:- Other
    class func instantiateSwdDatePickerViewFromNib(withView view: UIView) -> SWDatePicker {
        let obj = Bundle.main.loadNibNamed("SWDatePicker", owner: nil, options: nil)![0] as! SWDatePicker
        view.addSubview(obj)
        obj.addConstraintToSuperView(lead: 0, trail: 0, top: 0, bottom: -49)
        //Animation
        obj.datePickerBottom.constant = -_swdDatePickerhideConstant
        obj.layoutIfNeeded()
        obj.datePickerBottom.constant = 0
        obj.vwBackground.alpha = 0
        UIView.animate(withDuration: _pickerAnimationTime, animations: {
            obj.layoutIfNeeded()
            obj.vwBackground.alpha = 1
        })
        return obj
    }
    
    func removeViewWithAnimation(){
        datePickerBottom.constant = -_swdDatePickerhideConstant
        UIView.animate(withDuration: _pickerAnimationTime, animations: {
            self.layoutIfNeeded()
            self.vwBackground.alpha = 0
        }) { (done) in
            self.removeFromSuperview()
        }
    }
}

