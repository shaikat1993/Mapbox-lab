//
//  SettingsViewModel.swift
//  MapboxVelocity
//
//  Created by Shaikat on 4/23/26.
//

import Foundation
import Combine


final class SettingsViewModel {

    @Published private(set) var selectedStyle: MapStyle
    private(set) var overlays: [TechnicalOverlay]

    private let defaults: UserDefaults
    private let mapService: MapServiceProtocol

    init(mapService: MapServiceProtocol, defaults: UserDefaults = .standard) {
        self.mapService = mapService
        self.defaults = defaults

        let savedStyle = defaults.string(forKey: UserDefaultsKeys.Settings.selectedMapStyle)
        selectedStyle = MapStyle.allCases.first { $0.title == savedStyle } ?? .dark

        overlays = TechnicalOverlay.defaults.map { overlay in
            let key = UserDefaultsKeys.Settings.overlayPrefix + overlay.id
            let stored = defaults.object(forKey: key)
            var mutable = overlay
            mutable.isEnabled = stored != nil ? defaults.bool(forKey: key) : overlay.isEnabled
            return mutable
        }
    }

    func selectStyle(_ style: MapStyle) {
        selectedStyle = style
        defaults.set(style.title, forKey: UserDefaultsKeys.Settings.selectedMapStyle)
        mapService.updateStyle(style)
    }

    func toggleOverlay(id: String, isEnabled: Bool) {
        guard let index = overlays.firstIndex(where: { $0.id == id }) else { return }
        overlays[index].isEnabled = isEnabled
        defaults.set(isEnabled, forKey: UserDefaultsKeys.Settings.overlayPrefix + id)
        mapService.updateOverlay(id: id, isEnabled: isEnabled)
    }
}
