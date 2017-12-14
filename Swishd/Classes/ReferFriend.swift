
import UIKit

class ReferCell: ConstrainedTableViewCell, UITextFieldDelegate{

    @IBOutlet weak var tfEmail: UITextField!
    @IBOutlet weak var btnAdd: UIButton!
    weak var parent: ReferFriend!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func prepareUI(){
        tfEmail.keyboardType = .emailAddress
        tfEmail.tintColor = UIColor.swdThemeBlurColor()
        tfEmail.returnKeyType = .done
        btnAdd.isHidden = true
        if self.tag == parent.arrOfEmail.count - 1{
            btnAdd.isHidden = false
        }
    }
}

// MARK: - Textfield Delegate
extension ReferCell{

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        return true
    }
    
    @IBAction func textChanged(_ sender : UITextField){
        parent.arrOfEmail[self.tag] = sender.text!
    }
}

class ReferFriend: ParentViewController {
    
    /// Variables
    var arrOfEmail = [String]()

    override func viewDidLoad() {
        super.viewDidLoad()
        prepareUI()
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
}

// MARK: - UI And Utility Related
extension ReferFriend{
    
    func prepareUI()  {
        self.view.backgroundColor = UIColor.hexStringToUIColor(hexStr: "EFEFEF")
        tableView.contentInset = UIEdgeInsets(top: 5 * _widthRatio, left: 0, bottom: 10 * _widthRatio, right: 0)
        arrOfEmail.append("")
    }
}

// MARK: - Button Action
extension ReferFriend{
    
    @IBAction func btnAddAction(_ sender: UIButton){
        if (arrOfEmail.last?.isValidEmailAddress())!{
            arrOfEmail.append("")
        }else{
            _ = ValidationToast.showStatusMessage(message: kInvalidEmail,yCord: _topMsgBarConstant, inView: self.view)
        }
        tableView.reloadData()
    }
    
    @IBAction func btnInviteAction(_ sender: UIButton){
        if (arrOfEmail.last?.isValidEmailAddress())!{
            inviteFriend()
        }else{
             _ = ValidationToast.showStatusMessage(message: kInvalidEmail,yCord: _topMsgBarConstant, inView: self.view)
        }
    }
}

// MARK: - TableView Method
extension ReferFriend{

   override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrOfEmail.count + 2
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if  indexPath.row == 0{
            return 50 * _widthRatio
        }else{
            return 90 * _widthRatio
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == 0{
            let cell = tableView.dequeueReusableCell(withIdentifier: "referCell") as! ReferCell
            return cell
        }else if indexPath.row == arrOfEmail.count + 1 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "inviteCell") as! ReferCell
            return cell
        }else{
            let cell = tableView.dequeueReusableCell(withIdentifier: "emailCell") as! ReferCell
            cell.tag = indexPath.row - 1
            cell.parent = self
            cell.prepareUI()
            return cell
        }
    }
}

// MARK: - Webcall Methods
extension ReferFriend{

    func inviteFriend(){
        let dict: [String: Any] = ["invite": arrOfEmail]        
        self.showCentralSpinner()
        KPWebCall.call.referFriend(param: dict){ (json, status) in
            self.hideCentralSpinner()
            if status == 200{
                if let _ = json as? NSDictionary{
                    self.navigationController?.popViewController(animated: true)
                }
            }else{
                self.showError(data: json,yPos: _topMsgBarConstant)
            }
        }
    }
}
