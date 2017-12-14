import UIKit

extension UIColor {
    
    class func colorWithGray(gray: Int) -> UIColor {
      return UIColor(red: CGFloat(gray) / 255.0, green: CGFloat(gray) / 255.0, blue: CGFloat(gray) / 255.0, alpha: 1.0)
    }
    
    class func colorWithRGB(r: Int, g: Int, b: Int) -> UIColor {
        return UIColor(red: CGFloat(r) / 255.0, green: CGFloat(g) / 255.0, blue: CGFloat(b) / 255.0, alpha: 1.0)
    }

    class func colorWithHexa(hex:Int) -> UIColor{
        let components = (
            R: CGFloat((hex >> 16) & 0xff) / 255,
            G: CGFloat((hex >> 08) & 0xff) / 255,
            B: CGFloat((hex >> 00) & 0xff) / 255
        )
        return UIColor(red: components.R, green: components.G, blue: components.B, alpha: 1.0)
    }
    
    class func hexStringToUIColor (hexStr: String) -> UIColor {
        var cString:String = hexStr.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        
        if (cString.hasPrefix("#")) {
            cString.remove(at: cString.startIndex)
        }
        
        if ((cString.count) != 6) {
            return UIColor.gray
        }
    
        var rgbValue:UInt32 = 0
        Scanner(string: cString).scanHexInt32(&rgbValue)
        
        return UIColor(
            red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
            alpha: CGFloat(1.0)
        )
    }
    
    // MARK: Theme Colours
    class func swdRedColor() -> UIColor {
        return UIColor.red
    }
    
    class func swdThemeBlurColor() -> UIColor {
        return UIColor.hexStringToUIColor(hexStr: "0584C9")
    }
    
    class func swdThemeRedColor() -> UIColor {
        return UIColor.hexStringToUIColor(hexStr: "E1513D")
    }
    
    class func swdBlueColor() -> UIColor {
        return UIColor.hexStringToUIColor(hexStr: "0585CA")
    }
    
    class func swdSuccessPopUp() -> UIColor {
        return UIColor.gray
    }
}
