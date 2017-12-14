

import UIKit

class AdvanceJournyCell: ConstrainedTableViewCell{

    @IBOutlet var btnAnytime: UIButton!
    @IBOutlet var btnevryDay: UIButton!
    @IBOutlet var btnDate: UIButton!
    @IBOutlet var swSwishPoint: UISwitch!
    @IBOutlet var vweveryDay: UIView!
    
    @IBOutlet var btnMonday: UIButton!
    @IBOutlet var btnTuesday: UIButton!
    @IBOutlet var btnWenday: UIButton!
    @IBOutlet var btnThursday: UIButton!
    @IBOutlet var btnFriday: UIButton!
    @IBOutlet var btnSaturday: UIButton!
    @IBOutlet var btnSunday: UIButton!
    
    weak var parent: AdvanceSearchVC!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func resetShadow(){
        if parent.isEveryDay{
            let rect = CGRect(x: 0, y: 0, width: vweveryDay.frame.size.width, height: 176 * _widthRatio)
            vweveryDay.layer.shadowPath = UIBezierPath(rect: rect).cgPath
        }else{
            let rect = CGRect(x: 0, y: 0, width: vweveryDay.frame.size.width, height: 130 * _widthRatio)
            vweveryDay.layer.shadowPath = UIBezierPath(rect: rect).cgPath
        }
    }
    
    func prepareUI(){
        btnDate.backgroundColor = UIColor.clear
        btnDate.isSelected = false
        btnevryDay.backgroundColor = parent.isEveryDay ? UIColor.swdThemeRedColor() : UIColor.clear
        btnevryDay.isSelected = parent.isEveryDay
        btnAnytime.backgroundColor = parent.advanceData.isAnytime ? UIColor.swdThemeRedColor() : UIColor.clear
        btnAnytime.isSelected = parent.advanceData.isAnytime
        
        if parent.advanceData.specificDate != nil{
            btnDate.setTitle(Date.getLocalString(from: parent.advanceData.specificDate, format: "EEE dd MMM"), for: .normal)
            btnDate.backgroundColor = UIColor.swdThemeRedColor()
            btnDate.isSelected = true
        }else{
            btnDate.setTitle("Specific Date", for: .normal)
        }
        
        if !parent.advanceData.everyDay.isEmpty{
            btnevryDay.isSelected = true
            parent.isEveryDay = true
            btnevryDay.backgroundColor =  UIColor.swdThemeRedColor()
        }
        
        if parent.advanceData.everyDay.contains(.all){
            btnMonday.isSelected = true
            btnTuesday.isSelected = true
            btnWenday.isSelected = true
            btnThursday.isSelected = true
            btnFriday.isSelected = true
            btnSaturday.isSelected = true
            btnSunday.isSelected = true
        }else{
            btnMonday.isSelected = parent.advanceData.everyDay.contains(.monday)
            btnTuesday.isSelected = parent.advanceData.everyDay.contains(.tuesday)
            btnWenday.isSelected = parent.advanceData.everyDay.contains(.wednesDay)
            btnThursday.isSelected = parent.advanceData.everyDay.contains(.thursday)
            btnFriday.isSelected = parent.advanceData.everyDay.contains(.friday)
            btnSaturday.isSelected = parent.advanceData.everyDay.contains(.saturday)
            btnSunday.isSelected = parent.advanceData.everyDay.contains(.sunday)
        }
    }
}

class AdvanceSearchVC: ParentViewController {
    
    ///Variables
    var advanceData = Search()
    var isEveryDay: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        prepareUI()
        // Do any additional setup after loading the view.
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        tableView.reloadData()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "daysPickerSegue"{
            let vc = segue.destination as! DaysPickerVC
            vc.advanceData = advanceData
        }
    }
}

// MARK: - UI And Utility Related
extension AdvanceSearchVC{
    
    func prepareUI()  {
        self.view.backgroundColor = UIColor.hexStringToUIColor(hexStr: "EFEFEF")
        tableView.contentInset  = UIEdgeInsets(top: 5 * _widthRatio, left: 0, bottom: 10 * _widthRatio, right: 0)
    }
    
    func resetUI(){
        let cell = tableView.cellForRow(at: IndexPath(row: 0, section: 0)) as! AdvanceJournyCell
        cell.resetShadow()
        tableView.reloadData()
    }
    
    func getSelectedDays(day: String){
        let selectedDay = Day(str: day)
        if advanceData.everyDay.contains(selectedDay){
            advanceData.everyDay.remove(object: selectedDay)
        }else{
            advanceData.everyDay.append(selectedDay)
        }
        tableView.reloadData()
    }
}


//MARK:- Button Action
extension AdvanceSearchVC{

    @IBAction func btnDaysAction(_ sender : UIButton){
        advanceData.isAnytime = false
        advanceData.specificDate = nil
        isEveryDay = !isEveryDay
        resetUI()
    }
    
    @IBAction func btnSelectDayAction(_ sender: UIButton){

        switch sender.tag {
        case 0:
            getSelectedDays(day: "Monday")
        case 1:
            getSelectedDays(day: "Tuesday")
        case 2:
            getSelectedDays(day: "Wedenesday")
        case 3:
            getSelectedDays(day: "Thursday")
        case 4:
            getSelectedDays(day: "Friday")
        case 5:
            getSelectedDays(day: "Saturday")
        case 6:
            getSelectedDays(day: "Sunday")
        default:
            kprint(items: "All Days")
        }
    }
    
    @IBAction func btnanytimeAction(_ sender : UIButton){
        advanceData.isAnytime = !advanceData.isAnytime
        advanceData.everyDay.removeAll()
        self.isEveryDay = false
        resetUI()
        advanceData.specificDate = nil
    }
    
    @IBAction func btnDateAction(_ sender : UIButton){
        let picker = SWDatePicker.instantiateSwdDatePickerViewFromNib(withView: self.view)
        picker.datePicker.minimumDate = Date()
        if let _ = self.advanceData.specificDate{
            picker.datePicker.setDate(advanceData.specificDate!, animated: true)
        }
        picker.datePicker.datePickerMode = .date
        picker.selectionBlock = {[unowned self](date) -> () in
            let strDate = Date.getLocalString(from: date)
            let specificDate = Date.getDateFromLocalFormat(from: strDate)
            self.advanceData.specificDate = specificDate
            self.advanceData.everyDay.removeAll()
            self.isEveryDay = false
            self.resetUI()
            self.advanceData.isAnytime = false
        }
    }
    
    @IBAction func isSwishPointChanged(_ sender: UISwitch){
        advanceData.isSwishPoint = !advanceData.isSwishPoint
    }
    
    @IBAction func btnDoneAction(_ sender : UIButton){
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func btnClearAction(_ sender : UIButton){
        advanceData.everyDay.removeAll()
        advanceData.specificDate = nil
        advanceData.isAnytime = false
        advanceData.isSwishPoint = false
        tableView.reloadData()
    }
}

// MARK: - TableView Method
extension AdvanceSearchVC{
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row == 0{
            return isEveryDay ? 196 * _widthRatio : 150 * _widthRatio
        }else if indexPath.row == 1{
            return 120 * _widthRatio
        }else{
            return 70 * _widthRatio
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return CGFloat.leastNonzeroMagnitude
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.row == 0{
            let cell = tableView.dequeueReusableCell(withIdentifier: "journeyCell") as! AdvanceJournyCell
            cell.parent = self
            cell.prepareUI()
            return cell
        }else if indexPath.row == 1{
            let cell = tableView.dequeueReusableCell(withIdentifier: "switchCell") as! AdvanceJournyCell
            cell.swSwishPoint.isOn = advanceData.isSwishPoint
            return cell
        }else{
            let cell = tableView.dequeueReusableCell(withIdentifier: "doneCell") as! ConstrainedTableViewCell
            return cell
        }
    }
}
