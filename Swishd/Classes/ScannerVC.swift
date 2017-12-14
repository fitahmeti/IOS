import UIKit

class ScannerVC: ParentViewController {

    /// IBOutlets
    @IBOutlet var viewPreview: UIView!
    @IBOutlet var viewScan: UIView!
    
    // Variables
    var scanner: MTBBarcodeScanner!
    var overlayViews:[String: Any] = [:]
    var completion: ((String) -> ())!
    var textChage:((String) ->())?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        prepareUI()
        scanner = MTBBarcodeScanner(previewView: viewPreview)
        scanner.allowTapToFocus = true
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        checkCameraAccess()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle{
        return .lightContent
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


// MARK: - PrepareUI
extension ScannerVC{
    func prepareUI()  {
        self.lblTitle?.text = "Scan Code"
    }
}

// MARK: - Button Actions
extension ScannerVC {
    
    @IBAction func btnCloseTap(_ sender: UIButton) {
        stopScanning(resultStr: nil)
    }
    
    @IBAction func btnEnterCodeTap(_ sender: UIButton) {
        let alert = UIAlertController(title: _appName, message: "Enter your code", preferredStyle: UIAlertControllerStyle.alert)
        alert.addTextField(configurationHandler: nil)
        let textField = alert.textFields![0]
        let ok = UIAlertAction(title: "Submit", style: UIAlertActionStyle.default) { [unowned self](action) in
            self.completion(textField.text!.trimmedString())
            self.scanner.stopScanning()
            self.dismiss(animated: true, completion: nil)
        }
        
        ok.isEnabled = false
        textField.addTarget(self, action: #selector(self.textChage(sender:)), for: UIControlEvents.editingChanged)

        textChage = {(text) in ()
            if text.count == 8{
                ok.isEnabled = true
            }else{
                ok.isEnabled = false
            }
        }
        
        let cancel = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler: nil)
        alert.addAction(ok)
        alert.addAction(cancel)
        self.present(alert, animated: true, completion: nil)
    }
    
    @objc func textChage(sender: UITextField) {
        textChage?(sender.text!.trimmedString())
    }
}

// MARK: - Scanner
extension ScannerVC{

    func checkCameraAccess(){
        if MTBBarcodeScanner.cameraIsPresent(){
            if MTBBarcodeScanner.scanningIsProhibited(){
                MTBBarcodeScanner.requestCameraPermission { (access) in
                    if access{
                        self.startScanning()
                    }else{
                        self.showNoPermissionAlert()
                    }
                }
            }else{
                self.startScanning()
            }
        }
    }
    
    func startScanning(){
        scanner.didStartScanningBlock = {
            kprint(items: "start scanning")
        }
        
        scanner.didTapToFocusBlock = { point in
            kprint(items: point)
//            self.scanner.toggleTorch()
        }
        
        var error : NSError?
        scanner.startScanning(resultBlock: { (codes) in
            self.drawOverlaysOnCodes(codes: codes!)
            
            var str = ""
            for code in codes!{
                str = (code as! AVMetadataMachineReadableCodeObject).stringValue!
            }
            
            self.scanner.freezeCapture()
            let queue = DispatchQueue.main
            queue.asyncAfter(deadline: .now() + 1.0 , execute: {
                self.stopScanning(resultStr: str)
            })
            
        }, error: &error)
        
        
        if let _ = error {
            kprint(items: error!.localizedDescription)
        }
        scanner.scanRect = viewScan.frame
    }
    
    func stopScanning(resultStr: String?) {
        scanner.stopScanning()
        for (key,_) in overlayViews{
            (overlayViews[key] as! UIView).removeFromSuperview()
        }
        if let str = resultStr{
            completion(str)
        }
        self.dismiss(animated: true, completion: nil)
    }
    
    func showNoPermissionAlert(){
        let msg: String!
        if MTBBarcodeScanner.scanningIsProhibited(){
            msg = kCameraAccessMsg
        }else if !MTBBarcodeScanner.cameraIsPresent(){
            msg = kCameraNotAvailable
        }else{
            msg = kUnknowedErrorFound
        }
        
        let alert = UIAlertController(title: kCameraAccessTitle, message: msg, preferredStyle: UIAlertControllerStyle.alert)
        let settings = UIAlertAction(title: "Settings", style: UIAlertActionStyle.default) { (action) in
            UIApplication.shared.openURL(URL(string: UIApplicationOpenSettingsURLString)!)
        }
        
        let cancel = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler: nil)
        alert.addAction(settings)
        alert.addAction(cancel)
        self.present(alert, animated: true, completion: nil)
    }
}


extension ScannerVC{
    
    func drawOverlaysOnCodes(codes: [Any]){
        // Get all of the captured code strings
        var codeStrings: [String] = []
        for ele in codes{
            let code = ele as! AVMetadataMachineReadableCodeObject
            if (code.stringValue != nil){
                codeStrings.append(code.stringValue!)
            }
        }
        
        // Remove any code overlays no longer on the screen
        for key in overlayViews.keys{
            if !codeStrings.contains(key){
                (overlayViews[key] as! UIView).removeFromSuperview()
                overlayViews.removeValue(forKey: key)
            }
        }
        
        for ele in codes{
            let code = ele as! AVMetadataMachineReadableCodeObject
            let view: UIView!
            let codeString = code.stringValue
            
            if let _ = codeString{
                if (overlayViews[codeString!] != nil){
                    // The overlay is already on the screen
                    view = overlayViews[codeString!] as! UIView!
                    
                    // Move it to the new location
                    view.frame = code.bounds;
                }else{
                
                    // First time seeing this code
                    let isValidCode = self.isValidCodeString(codeString: codeString!)

                    // Create an overlay
                    let overlayView = self.overlayForCodeString(codeString: codeString!, bounds: code.bounds, valid: isValidCode)
                    overlayViews[codeString!] = overlayView
                    viewPreview.addSubview(overlayView)
                }
            }
        }
    }
    
    func isValidCodeString(codeString: String) -> Bool {
        return codeString.count == 8
    }
    
    func overlayForCodeString(codeString: String, bounds: CGRect, valid: Bool) -> UIView {
        let viewColor = valid ? UIColor.green : UIColor.red
        let view = UIView(frame: bounds)
        let label = UILabel(frame: view.bounds)
        
        // Configure the view
        view.layer.borderWidth = 5.0;
        view.backgroundColor = viewColor.withAlphaComponent(0.75)
        view.layer.borderColor = viewColor.cgColor;
        
        // Configure the label
        label.font = UIFont.boldSystemFont(ofSize: 12)
        label.text = codeString;
        label.textColor = UIColor.black
        label.textAlignment = .center;
        label.numberOfLines = 0;
        
        // Add the label to the view
//        view.addSubview(label)
        return view;
    }
}
