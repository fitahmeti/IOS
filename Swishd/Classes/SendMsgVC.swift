
import UIKit

class SendMsgVC: ParentViewController {

    /// IBOutlets
    @IBOutlet var tvMessge: UITextView!
    @IBOutlet var toolBar: UIToolbar!
    @IBOutlet var lblPlaceholder: UILabel!
    
    /// Variables
    var job: Job!
    
    /// View life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        prepareUI()
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

// MARK: - UI & Utility Related
extension SendMsgVC {

    func prepareUI() {
        tvMessge.text = ""
        tvMessge.delegate = self
        tvMessge.tintColor = UIColor.darkGray
        tvMessge.inputAccessoryView = toolBar
    }
}

// MARK: - Textview Delegate
extension SendMsgVC: UITextViewDelegate{
    
    func textViewDidChange(_ textView: UITextView) {
        if textView.text.isEmpty{
            lblPlaceholder.isHidden = false
        }else{
            lblPlaceholder.isHidden = true
        }
    }
}

// MARK: - Button Actions
extension SendMsgVC {

    @IBAction func toolBarDoneTap(_ sender: UIButton) {
        tvMessge.resignFirstResponder()
    }
    
    @IBAction func btnSendTap(_ sender: UIButton) {
        let str = tvMessge.text.trimmedString()
        if str.isEmpty{
            _ = ValidationToast.showStatusMessage(message: kEnterMessage,yCord: _topMsgBarConstant, inView: self.view)
        }else{
            kprint(items: "Send message")
            sendMessage(msg: str)
        }
    }
}

// MARK: - Web Call Methods
extension SendMsgVC {
    
    func sendMessage(msg: String) {
        let param: [String: Any] = ["sMessage": msg, "sJobId": job.jobId]
        self.showCentralSpinner()
        KPWebCall.call.sendMessage(param: param) { (json, status) in
            self.hideCentralSpinner()
            if status == 200{
                self.navigateToActivity()
            }else{
                self.showError(data: json, yPos: _topMsgBarConstant)
            }
        }
    }
    
    func navigateToActivity()  {
        for vc in self.navigationController!.viewControllers{
            if let actVc = vc as? JobactivityVC{
                actVc.getActivityList()
                navigationController?.popToViewController(actVc, animated: true)
                break
            }
        }
    }
}
