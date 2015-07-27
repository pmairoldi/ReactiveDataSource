import UIKit

extension UIViewController {
    
    func displayMessage(title: String?, message: String?){
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.Alert)
        
        let dismiss = UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil)
        
        alert.addAction(dismiss)
        
        self.presentViewController(alert, animated: true, completion: nil)
    }
}