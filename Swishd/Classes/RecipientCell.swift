
import UIKit

class RecipientCell: ConstrainedTableViewCell, UITextFieldDelegate{
    
    @IBOutlet var lblFromTitle: UILabel!
    @IBOutlet var lblDateTitle: UILabel!
    @IBOutlet var lblpickDropTitle: UILabel!
    @IBOutlet var lblFromTo: UILabel!
    @IBOutlet var lblDate: UILabel!
    @IBOutlet var btnMe: UIButton!
    @IBOutlet var btnElse: UIButton!
    @IBOutlet var lblMe: UILabel!
    @IBOutlet var lblSomeoneElse: UILabel!
    @IBOutlet var imgMe: UIImageView!
    @IBOutlet var imgSomeoneElse: UIImageView!
    @IBOutlet var viewShadowTop: NSLayoutConstraint!
    
    ///Reciver Data
    @IBOutlet var tfSwishrname: UITextField!
    @IBOutlet var tfSWishrEmail: UITextField!
    @IBOutlet var tfFname: UITextField!
    @IBOutlet var tfLname: UITextField!
    @IBOutlet var tfUserEmail: UITextField!
    @IBOutlet var tfUserMobile: UITextField!
    @IBOutlet var btnContact: UIButton!
    @IBOutlet var btnSwishrName: UIButton!

    
    weak var parent: RecipientsVC!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func prepareElseData(){
        btnContact.tag = self.tag
        btnSwishrName.tag = self.tag
        if self.tag == 10{
            tfSwishrname.text = parent.receiver.pickSwishrName
            tfSWishrEmail.text = parent.receiver.pickSwishrEmail
            tfFname.text = parent.receiver.pickUserFname
            tfLname.text = parent.receiver.pickUserLname
            tfUserEmail.text = parent.receiver.pickUserEmail
            tfUserMobile.text = parent.receiver.pickUserMobile
        }else if self.tag == 11{
            tfSwishrname.text = parent.receiver.dropSwishrName
            tfSWishrEmail.text = parent.receiver.dropSwishrEmail
            tfFname.text = parent.receiver.dropUserFname
            tfLname.text = parent.receiver.dropUserLname
            tfUserEmail.text = parent.receiver.dropUserEmail
            tfUserMobile.text = parent.receiver.dropUserMobile
        }
    }
    
    func prepareReciverUI(job: Job, reciver: RecipientData){
        if self.tag == 1{
            lblFromTo.text = job.pickAddress
            lblDate.text = job.pickDateStr
            lblFromTitle.text = "From:"
            lblDateTitle.text = "Collect from:"
            lblpickDropTitle.text = "Pick up by:"
            if reciver.isPickByMe{
                btnMe.isSelected = true
                btnElse.isSelected = false
                imgMe.image = #imageLiteral(resourceName: "ic_check_box_select")
                imgSomeoneElse.image = #imageLiteral(resourceName: "ic_check_box_deSelect")
                lblMe.font = UIFont.arialBold(size: 15 * _widthRatio)
                lblSomeoneElse.font = UIFont.arialRegular(size: 15 * _widthRatio)
            }else{
                btnMe.isSelected = false
                btnElse.isSelected = true
                imgSomeoneElse.image = #imageLiteral(resourceName: "ic_check_box_select")
                imgMe.image = #imageLiteral(resourceName: "ic_check_box_deSelect")
                lblSomeoneElse.font = UIFont.arialBold(size: 15 * _widthRatio)
                lblMe.font = UIFont.arialRegular(size: 15 * _widthRatio)
            }
        }else{
            lblFromTo.text = job.dropAddress
            lblDate.text = job.dropDateStr
            lblFromTitle.text = "To:"
            lblDateTitle.text = "Delivered by:"
            lblpickDropTitle.text = "Received By:"
            if reciver.isReceivedByMe{
                btnMe.isSelected = true
                btnElse.isSelected = false
                imgMe.image = #imageLiteral(resourceName: "ic_check_box_select")
                imgSomeoneElse.image = #imageLiteral(resourceName: "ic_check_box_deSelect")
                lblMe.font = UIFont.arialBold(size: 15 * _widthRatio)
                lblSomeoneElse.font = UIFont.arialRegular(size: 15 * _widthRatio)
            }else{
                btnMe.isSelected = false
                btnElse.isSelected = true
                imgSomeoneElse.image = #imageLiteral(resourceName: "ic_check_box_select")
                imgMe.image = #imageLiteral(resourceName: "ic_check_box_deSelect")
                lblSomeoneElse.font = UIFont.arialBold(size: 15 * _widthRatio)
                lblMe.font = UIFont.arialRegular(size: 15 * _widthRatio)
            }
        }
    }
}


// MARK: - TextFieldDelegate
extension RecipientCell{

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        parent.view.endEditing(true)
        return true
    }
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        
        if !parent.receiver.isPickByMe && self.tag == 10{
            if textField.tag == 1{
                parent.receiver.isAppPickUser = false
                tfSWishrEmail.text = nil
                tfSwishrname.text = nil
            }else{
                parent.receiver.isAppPickUser = true
                tfFname.text = nil
                tfLname.text = nil
                tfUserEmail.text = nil
                tfUserMobile.text = nil
            }
        }else if !parent.receiver.isReceivedByMe && self.tag == 11{
            if textField.tag == 1{
                parent.receiver.isAppDropUser = false
                tfSWishrEmail.text = nil
                tfSwishrname.text = nil
            }else{
                parent.receiver.isAppDropUser = true
                tfFname.text = nil
                tfLname.text = nil
                tfUserEmail.text = nil
                tfUserMobile.text = nil
            }
        }
        return true
    }
    
    @IBAction func txtfieldChanged(_ sender: UITextField){
        if !parent.receiver.isPickByMe && self.tag == 10{
            parent.receiver.pickSwishrName = tfSwishrname.text
            parent.receiver.pickSwishrEmail = tfSWishrEmail.text
            parent.receiver.pickUserFname = tfFname.text
            parent.receiver.pickUserLname = tfLname.text
            parent.receiver.pickUserEmail = tfUserEmail.text
            parent.receiver.pickUserMobile = tfUserMobile.text
            
        }else if !parent.receiver.isReceivedByMe && self.tag == 11{
            parent.receiver.dropSwishrName = tfSwishrname.text
            parent.receiver.dropSwishrEmail = tfSWishrEmail.text
            parent.receiver.dropUserFname = tfFname.text
            parent.receiver.dropUserLname = tfLname.text
            parent.receiver.dropUserEmail = tfUserEmail.text
            parent.receiver.dropUserMobile = tfUserMobile.text
        }
    }
}
