//
//  DependencyContainer.swift
//  MapboxVelocity
//
//  Created by Shaikat on 4/3/26.
//

import Foundation

final class DependencyContainer {
    //MARK: services
    private(set) lazy var mapService: MapServiceProtocol = MapService()
    private(set) lazy var locationService: LocationServiceProtocol = LocationService()
    private(set) lazy var designSystem: DesignSystemProviding = VelocityDesignSystem()
    
    //MARK: view controllers (eager — created once, reused)
    private(set) lazy var mapViewController: MapViewController = MapViewController(
        mapService: mapService,
        locationService: locationService
    )

    //MARK: factories
    func makeTabBarController() -> TabBarController {
        TabBarController(container: self)
    }

    func makeMapViewController() -> MapViewController {
        mapViewController
    }

    func makeSettingsViewController() -> SettingsViewController {
        let vc = AppStoryboard.settings.viewController(SettingsViewController.self)
        vc.configure(mapService: mapService)
        return vc
    }
}
