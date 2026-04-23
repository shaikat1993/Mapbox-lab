//
//  DashboardViewModel.swift
//  MapboxVelocity
//
//  Created by Shaikat on 4/10/26.
//

import Combine

protocol DashboardViewModelProtocol: AnyObject {
    var cards: [DashboardCardModel] { get }
    var cardsPublisher: AnyPublisher<[DashboardCardModel], Never> { get }
    func loadCards()
}

final class DashboardViewModel: DashboardViewModelProtocol {
    // MARK: - Protocol conformance
    @Published private(set) var cards: [DashboardCardModel] = []
    
    var cardsPublisher: AnyPublisher<[DashboardCardModel], Never> {
        $cards.eraseToAnyPublisher()
    }
        
    func loadCards() {
        let liveRide: DashboardCardModel = DashboardCardModel(icon: "ride_icon",
                                                              title: "Live Ride",
                                                              subTitle: "Here is a mock LIve Ride animation", backgroundImage: "live_ride",
                                                              destination: .mapTab)
        
        let markers: DashboardCardModel = DashboardCardModel(icon: "marker_icon",
                                                             title: "Marker Management",
                                                             subTitle: "Here we can update or change the marker in the Map",
                                                             backgroundImage: "markers",
                                                             destination: .markersTab)
        
        let settings: DashboardCardModel = DashboardCardModel(icon: "settings_icon",
                                                              title: "Settings",
                                                              subTitle: "Here we can change the Map Style", backgroundImage: "settings", destination: .settingsTab)
        cards = [liveRide,
                 markers,
                 settings]
    }
}
