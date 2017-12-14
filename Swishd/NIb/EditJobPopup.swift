//
//  EditJobPopup.swift


import Foundation

class EditJobPopup: ConstrainedView{
   
    @IBOutlet var vwBackground: UIView!

    //MARK:- IBActions
    
    @IBAction func editTap(sender: UIButton){
        selectionBlock!()
        removeViewWithAnimation()
    }
    
    @IBAction func cancelTap(sender: UIButton){
        removeViewWithAnimation()
    }
    
    //MARK:- Variables
    var selectionBlock:(()->())?
    
    //MARK:- View life cycle
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    //MARK:- Other
    class func instantiateEditJobPopupViewFromNib(withView view: UIView) -> EditJobPopup {
        let obj = Bundle.main.loadNibNamed("EditJobPopup", owner: nil, options: nil)![0] as! EditJobPopup
        _appDelegator.window?.addSubview(obj)
        obj.addConstraintToSuperView(lead: 0, trail: 0, top: 0, bottom: 0)
        //Animation
        obj.layoutIfNeeded()
        obj.vwBackground.alpha = 0
        UIView.animate(withDuration: _pickerAnimationTime, animations: {
            obj.layoutIfNeeded()
            obj.vwBackground.alpha = 1
        })
        return obj
    }
    
    func removeViewWithAnimation(){
        UIView.animate(withDuration: _pickerAnimationTime, animations: {
            self.layoutIfNeeded()
            self.vwBackground.alpha = 0
        }) { (done) in
            self.removeFromSuperview()
        }
    }
}
