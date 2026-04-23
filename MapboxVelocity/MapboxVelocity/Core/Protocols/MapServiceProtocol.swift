//
//  MapServiceProtocol.swift
//  MapboxVelocity
//
//  Created by Shaikat on 4/17/26.
//

import MapboxMaps
import CoreLocation

protocol MapServiceProtocol: AnyObject {
    var styleURI: StyleURI { get }
    var initialCamera: CameraOptions { get }
}


