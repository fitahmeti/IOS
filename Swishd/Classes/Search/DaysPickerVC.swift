

import UIKit

class DaysPickerCell: ConstrainedTableViewCell{
    @IBOutlet weak var lblDay : UILabel!
    @IBOutlet weak var imgDone : UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
}

class DaysPickerVC: ParentViewController {
    
    /// Variables
    var advanceData: Search!
    let arrOfDaysStr = ["All","Monday","Tuesday","Wedenesday","Thursday","Friday","Saturday","Sunday"]

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

//MARK: - Button Action
extension DaysPickerVC{

    @IBAction func btnDoneaction(_ sender: UIButton){
        navigationController?.popViewController(animated: true)
    }
}

//MARK:- TableView Method
extension DaysPickerVC{

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrOfDaysStr.count + 1
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row == arrOfDaysStr.count{
            return 70
        }
        return 50
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == arrOfDaysStr.count{
            let cell = tableView.dequeueReusableCell(withIdentifier: "doneCell") as! ConstrainedTableViewCell
            return cell
        }else{
            let cell = tableView.dequeueReusableCell(withIdentifier: "daysCell") as! DaysPickerCell
            let day = arrOfDaysStr[indexPath.row]
            cell.lblDay.text = day
//            cell.imgDone.isHidden = !advanceData.arrOfSelectedDays.contains(day)
            return cell
        }
    }
    
//    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        if indexPath.row != arrOfDaysStr.count{
//            let objDay = arrOfDaysStr[indexPath.row]
//            if indexPath.row == 0{
//                advanceData.arrOfSelectedDays.removeAll()
//                advanceData.arrOfSelectedDays.append(objDay)
//            }else{
//                let objAllDay = arrOfDaysStr[0]
//                advanceData.arrOfSelectedDays.remove(object: objAllDay)
//                if advanceData.arrOfSelectedDays.contains(objDay){
//                    advanceData.arrOfSelectedDays.remove(object: objDay)
//                }else{
//                    advanceData.arrOfSelectedDays.append(objDay)
//                }
//            }
//            tableView.reloadData()
//        }
//    }
}

