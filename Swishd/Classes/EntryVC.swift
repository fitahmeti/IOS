

import UIKit
import LinkedinSwift

class WalkThroughCell: ConstrainedCollectionViewCell {
    @IBOutlet var imgView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
}

class EntryVC: SocialViewController {
    
    /// IBOutlet
    @IBOutlet var pageControl: UIPageControl!
    @IBOutlet var lblHeader: UILabel!
    @IBOutlet var lblDesc: UILabel!
    
    /// View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        prepareUI()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func connectToFacebook() {
        connectToFacebookForLoginReg()
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
extension EntryVC {

    func prepareUI() {
        self.view.backgroundColor = UIColor.hexStringToUIColor(hexStr: "EFEFEF")
    }
}

// MARK: - Button Actions
extension EntryVC {

    @IBAction func btnLoginTap(_ sender: UIButton) {
        self.performSegue(withIdentifier: "loginSegue", sender: nil)
    }
    
    @IBAction func btnSignUpTap(_ sender: UIButton) {
        self.performSegue(withIdentifier: "signUpSegue", sender: nil)
    }
    
    @IBAction func loginFbTap(_ sender: UIButton) {
        self.connectToFacebook()
    }
    
    @IBAction func loginGooleTap(_ sender: UIButton) {
        self.loginRegUserWithGoogle()
    }
}

// MARK: - UICollectionViewDelegateFlowLayout, UICollectionViewDataSource
extension EntryVC: UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 4
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! WalkThroughCell
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize{
        return collectionView.frame.size
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let pageWidth = scrollView.frame.width
        let page = (scrollView.contentOffset.x + pageWidth / 2)/pageWidth
        pageControl.currentPage = page.intValue!
    }
}
