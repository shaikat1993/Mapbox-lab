//
//  AppStoryboard.swift
//  MapboxVelocity
//
//  Created by Shaikat on 4/9/26.
//

import UIKit

enum AppStoryboard: String {
    case map      = "Map"
    case dashboard = "Dashboard"
    case markers   = "Markers"
    case settings  = "Settings"

    var instance: UIStoryboard {
        UIStoryboard(name: rawValue,
                     bundle: .main)
    }

    func viewController<T: UIViewController>(_ type: T.Type) -> T {
        let id = String(describing: type)
        guard let vc = instance.instantiateViewController(withIdentifier: id) as? T else {
            fatalError("No view controller with identifier '\(id)' in \(rawValue).storyboard")
        }
        return vc
    }
}
