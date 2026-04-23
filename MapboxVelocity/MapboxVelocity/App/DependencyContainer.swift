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
    
    //MARK: factories
    func makeTabBarController() -> TabBarController {
        TabBarController(container: self)
    }
    
    func makeMapViewController() -> MapViewController {
        MapViewController(mapService: mapService,
                          locationService: locationService)
    }
}
