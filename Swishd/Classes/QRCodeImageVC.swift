//
//  QRCodeImageVC.swift
//  Swishd
//
//
//

import UIKit

class QRCodeImageVC: ParentViewController {
    
    // IBOutlets
    @IBOutlet var imgCode: UIImageView!
    @IBOutlet var lblCode: UILabel!
    
    // Variables
    var code: QRCode!

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
    
    func prepareUI(){
        self.view.backgroundColor = UIColor.hexStringToUIColor(hexStr: "EFEFEF")
        imgCode.kf.setImage(with: code.codeUrl)
        lblCode.text = code.code
    }

}

