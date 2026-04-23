//
//  TabBarController.swift
//  MapboxVelocity
//
//  Created by Shaikat on 4/9/26.
//

import UIKit

protocol AppTabBarNavigating: AnyObject {
    func navigate(to destination: CardDestination)
}

class TabBarController: UITabBarController {
    private let container: DependencyContainer
    
    init(container: DependencyContainer) {
        self.container = container
        super.init(nibName: nil,
                   bundle: nil)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("Use init(container:)")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //setupAppearance()
        setupTabs()
    }

    private func setupTabs() {
        let dashboardNav = makeNav(AppStoryboard
                            .dashboard
                            .viewController(DashboardViewController.self),
                                   title: "Dashboard",
                                   image: "list.dash")
        let mapNav       = makeNav(container.makeMapViewController(),
                                   title: "Map",
                                   image: "map")
        
        let markersNav = makeNav(AppStoryboard
                        .markers
                        .viewController(MarkersViewController.self),
                                 title: "Markers",
                                 image: "mappin.and.ellipse")
        let settingsVC = container.makeSettingsViewController()
        let settingsNav = makeNav(settingsVC,
                                  title: "Settings",
                                  image: "gearshape")
        viewControllers = [dashboardNav,
                           mapNav,
                           markersNav,
                           settingsNav]
    }
    
    private func makeNav(_ root: UIViewController,
                         title: String,
                         image: String) -> UINavigationController {
        root.tabBarItem = UITabBarItem(
            title: title,
            image: UIImage(systemName: image),
            selectedImage: UIImage(systemName: image + ".fill")
        )
        return UINavigationController(rootViewController: root)
    }
}

extension TabBarController: AppTabBarNavigating {
    func navigate(to destination: CardDestination) {
        guard let vcs = viewControllers else { return }
        let index = vcs.firstIndex {
            guard let nav = $0 as? UINavigationController else { return false }
            switch destination {
            case .mapTab:      return nav.topViewController is MapViewController
            case .markersTab:  return nav.topViewController is MarkersViewController
            case .settingsTab: return nav.topViewController is SettingsViewController
            }
        }
        selectedIndex = index ?? 0
    }
}
