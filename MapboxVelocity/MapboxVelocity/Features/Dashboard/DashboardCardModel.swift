//
//  DashboardCardModel.swift
//  MapboxVelocity
//
//  Created by Shaikat on 4/10/26.
//

struct DashboardCardModel {
    let icon: String
    let title: String
    let subTitle: String
    let backgroundImage: String
    let destination: CardDestination
}

//destination is what the tab bar will use later when the user taps a card to switch tabs.
enum CardDestination {
    case mapTab
    case markersTab
    case settingsTab
}
