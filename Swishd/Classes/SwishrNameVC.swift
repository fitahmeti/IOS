
import UIKit
import Alamofire

class SwishrNameCell: ConstrainedTableViewCell{
    @IBOutlet weak var lblUsername: UILabel!
}

class SwishrNameVC: ParentViewController, UITextFieldDelegate {
    
    @IBOutlet weak var tfUsername: UITextField!
    var reciver: RecipientData!
    var isfromPick: Bool = false
    var dataTask: DataRequest?
    var searchdSwishers: [OtherUser]!
    
    override func viewDidLoad() {
        super.viewDidLoad()
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

// MARK: - TExtfield Delegate
extension SwishrNameVC{
    
    @IBAction func textChanged(_ sender: UITextField) {
        if (sender.text?.trimmedString().isEmpty)!{
            searchdSwishers = []
            if let task = dataTask{
                task.cancel()
            }
            tableView.reloadData()
        }else{
            getSwishrUsername(str: sender.text!)
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        view.endEditing(true)
        return true
    }
}

// MARK: - Webcall Method
extension SwishrNameVC{
    
    func getSwishrUsername(str: String){
        if let task = dataTask{
            task.cancel()
        }
        dataTask = KPWebCall.call.getSwishrUsername(param: ["vSearch": str]){ (json, status) in
            if status == 200{
                if let swishrList = (json as? NSDictionary)?["items"] as? [NSDictionary]{
                    self.searchdSwishers = []
                    for swishr in swishrList{
                        self.searchdSwishers.append(OtherUser(dict: swishr))
                    }
                    self.tableView.reloadData()
                }
            }
        }
    }
}

// MARK: - Tableview method
extension SwishrNameVC{
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchdSwishers != nil ? searchdSwishers.count : 0
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "swishernameCell") as! SwishrNameCell
        cell.lblUsername.text = searchdSwishers[indexPath.row].userName
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
            if isfromPick{
                reciver.pickSwishrName = searchdSwishers[indexPath.row].userName
                reciver.pickSwishrEmail = searchdSwishers[indexPath.row].email
                reciver.pickUserFname = nil
                reciver.pickUserLname = nil
                reciver.pickUserEmail = nil
                reciver.pickUserMobile = nil
                reciver.isAppPickUser = true
            }else{
                reciver.dropSwishrName = searchdSwishers[indexPath.row].userName
                reciver.dropSwishrEmail = searchdSwishers[indexPath.row].email
                reciver.dropUserFname = nil
                reciver.dropUserLname = nil
                reciver.dropUserEmail = nil
                reciver.dropUserMobile = nil
                reciver.isAppDropUser = true
            }
            navigationController?.popViewController(animated: true)
    }
}
