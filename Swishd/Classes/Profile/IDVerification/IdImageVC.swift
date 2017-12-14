

import UIKit

class IdImageVC: ParentViewController {
    
    @IBOutlet weak var imgId : UIImageView!
    @IBOutlet weak var scrollView: UIScrollView!
    var img : URL!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        prepareUI()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override var prefersStatusBarHidden: Bool{
        return true
    }
}

// MARK: - UI releted Method
extension IdImageVC{
    
    func prepareUI(){
        scrollView.delegate = self
        scrollView.minimumZoomScale = 1.0
        scrollView.maximumZoomScale = 4.0
        imgId.kf.setImage(with : img)
    }
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imgId
    }
}

// MARK: - Button Action
extension IdImageVC{
    
    @IBAction func btnDismissAction(_ sender: UIButton){
        self.dismiss(animated: false, completion: nil)
    }
}
