import UIKit
import ReactiveDataSource

enum CellActions: Actionable {
    case Button1(String)
    case Button2(String)
}

enum SelectionActions: Actionable {
    case Push
    case Pop
}

protocol Actions {
    func pushbackAction<T>() -> T -> ()
    func selectionAction<T>() -> T -> ()
}

extension UIViewController: Actions {
    
    func pushbackAction<T>() -> T -> () {
        return { [weak self] value in
            
            guard let value = value as? CellActions else {
                return
            }
            
            switch value {
            case let CellActions.Button1(x):
                self?.displayMessage("Action", message: x)
            case let CellActions.Button2(x):
                self?.displayMessage("Action", message: x)
            }
        }
    }
    
    func selectionAction<T>() -> T -> () {
        return { [weak self] value in
            
            let navController = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("ReactiveCollectionView") as! UINavigationController
            
            guard let value = value as? SelectionActions else {
                return
            }
            
            switch value  {
            case .Push:
                self?.navigationController?.pushViewController(navController.viewControllers[0], animated: true)
            case .Pop:
                self?.navigationController?.presentViewController(navController, animated: true, completion: nil)
            }
        }
    }
}