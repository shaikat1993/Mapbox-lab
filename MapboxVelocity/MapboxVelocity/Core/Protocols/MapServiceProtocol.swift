//
//  MapServiceProtocol.swift
//  MapboxVelocity
//
//  Created by Shaikat on 4/17/26.
//

import MapboxMaps
import CoreLocation
import Combine

protocol MapServiceProtocol: AnyObject {
    var styleURI: StyleURI { get }
    var initialCamera: CameraOptions { get }
    var selectedStyle: MapStyle { get }
    var styleDidChange: PassthroughSubject<MapStyle, Never> { get }
    var overlayDidChange: PassthroughSubject<(id: String, isEnabled: Bool), Never> { get }
    func updateStyle(_ style: MapStyle)
    func updateOverlay(id: String, isEnabled: Bool)
}


