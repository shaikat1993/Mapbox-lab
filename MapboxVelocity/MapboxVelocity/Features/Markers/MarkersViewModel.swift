//
//  MarkersViewModel.swift
//  MapboxVelocity
//
//  Created by Shaikat on 4/23/26.
//

import Combine
import Foundation

final class MarkersViewModel {

    @Published private(set) var config: MarkerConfig

    private let defaults: UserDefaults

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        self.config = MarkerConfig.load(from: defaults)
    }

    func updateLabel(_ label: String) {
        config.label = label
    }

    func updateShape(_ shape: MarkerShape) {
        config.shape = shape
        config.customImageData = nil
    }

    func updateColor(_ color: MarkerColor) {
        config.color = color
        config.customImageData = nil
    }

    func updateCustomImage(_ data: Data?) {
        config.customImageData = data
    }

    func save() {
        config.save(to: defaults)
    }
}
