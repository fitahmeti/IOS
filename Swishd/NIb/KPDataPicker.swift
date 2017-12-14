
import UIKit

class KPDataPicker: ConstrainedView{
    
    //MARK:- IBActions
    @IBAction func cancelTap(sender: UIButton){
        removeViewWithAnimation()
    }
    
    @IBAction func doneTap(sender: UIButton){
        if arrPickerItems.count > 0{
            self.selectionBlock!(selectedItemFromMultiComp)
        }
        removeViewWithAnimation()
    }
    
    //MARK:- IBOutlets
    @IBOutlet var dataPicker: UIPickerView!
    @IBOutlet var datePickerBottom: NSLayoutConstraint!
   
    //MARK:- Variables
    var selectionBlock: ((_ selectedItem : [String]) -> ())?
    var arrPickerItems: [[String]] = []
    var selectedItemFromMultiComp = [String]()
    
    //MARK:- View life cycle
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        let loc = touches.first?.location(in: self)
        if let location = loc{
            if location.y < (_screenSize.height - _dataPickerHideConstant){
                removeViewWithAnimation()
            }
        }
    }
    
    //MARK:- Other
    class func instantiateViewFromNib(withView view: UIView, arrData: [[String]]) -> KPDataPicker {
        let obj = Bundle.main.loadNibNamed("KPDataPicker", owner: nil, options: nil)![0] as! KPDataPicker
        _appDelegator.window?.addSubview(obj)
        obj.addConstraintToSuperView(lead: 0, trail: 0, top: 0, bottom: 0)
        
        obj.arrPickerItems = arrData
        if(obj.arrPickerItems.count > 0){
            for component in obj.arrPickerItems.enumerated(){
                let str = String(describing: obj.arrPickerItems[component.offset][0])
                obj.selectedItemFromMultiComp.insert(str, at: component.offset)
            }
        }
        obj.dataPicker.reloadAllComponents()
       
        //Animation
        obj.datePickerBottom.constant = -_dataPickerHideConstant
        obj.layoutIfNeeded()
        obj.datePickerBottom.constant = 0
        
        UIView.animate(withDuration: _pickerAnimationTime, animations: { 
            obj.layoutIfNeeded()
        })
        return obj
    }
    
    func removeViewWithAnimation(){
        datePickerBottom.constant = -_dataPickerHideConstant
        UIView.animate(withDuration: _pickerAnimationTime, animations: {
            self.layoutIfNeeded()
        }) { (done) in
            self.removeFromSuperview()
        }
    }
}

// MARK:- picker view delegate
extension KPDataPicker: UIPickerViewDelegate, UIPickerViewDataSource {
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return arrPickerItems[component].count
    }
    
    func pickerView(_ pickerView: UIPickerView, widthForComponent component: Int) -> CGFloat {
        return _screenSize.width
    }
    
    func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        return 40 * _widthRatio
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return arrPickerItems.count
    }
    
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        if let lable = view as? UILabel{
            lable.text = arrPickerItems[component][row]
            return lable
        }else{
            let lable = UILabel(frame: CGRect(x: 0, y: 0, width: _screenSize.width, height: 40 * _widthRatio))
            lable.font = UIFont.systemFont(ofSize: 19 * _widthRatio)
            lable.textAlignment = .center
            lable.textColor = UIColor.black
            lable.text = arrPickerItems[component][row]
            return lable
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        selectedItemFromMultiComp[component] = arrPickerItems[component][row]
    }
}
