//
//  KPTabBarVC.swift
//  Swishd
//
//

import UIKit

class KPTabBarVC: UITabBarController {

    /// IBOutlets
    @IBOutlet var tabbarView: UIView!
    @IBOutlet var btnSearch: UIButton!
    @IBOutlet var btnProfile: UIButton!
    @IBOutlet var btnSend: UIButton!
    
    /// View Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        addCustomTabBar()
        setSelectedTab(idx: 0)
        _appDelegator.tabBarLoaded?()
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

// MARK: - UI Related
extension KPTabBarVC{
    
    // Add TabBar custom view in tabbar.
    fileprivate func addCustomTabBar() {
        Bundle.main.loadNibNamed("TabBarView", owner: self, options: nil)
        tabbarView.frame = CGRect(x: 0, y: 0, width: _screenSize.width, height: tabbarView.frame.size.height);
        tabBar.addSubview(tabbarView)
        tabBar.layoutIfNeeded()
    }
    
    func setSelectedTab(idx: Int) {
        btnSend.tintColor = UIColor.white
        btnSearch.tintColor = UIColor.white
        btnProfile.tintColor = UIColor.white
        selectedIndex = idx
        if idx == 0{
            btnSearch.tintColor = UIColor.hexStringToUIColor(hexStr: "0583C9")//lightGray
        }else if idx == 1{
            btnProfile.tintColor = UIColor.hexStringToUIColor(hexStr: "0583C9")
        }else{
            btnSend.tintColor = UIColor.hexStringToUIColor(hexStr: "0583C9")
        }
    }
}

// MARK: - Button Actions
extension KPTabBarVC{

    @IBAction func btnTabChangeTap(_ sender: UIButton){
        setSelectedTab(idx: sender.tag)
    }
}
