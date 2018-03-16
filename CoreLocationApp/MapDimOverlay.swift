//
//  MapDimOverlay.swift
//  CoreLocationApp
//
//  Created by jojoestar on 3/15/18.
//  Copyright © 2018 jojoestar. All rights reserved.
//

import MapKit
import CoreLocation

open class DimOverlay : NSObject, MKOverlay {
    var dimOverlayCoordinates : CLLocationCoordinate2D = kCLLocationCoordinate2DInvalid
    var _mapView : MKMapView?
    
    public init(mapView : MKMapView) {
        dimOverlayCoordinates = mapView.centerCoordinate
    }
    
    open var coordinate: CLLocationCoordinate2D {
        return dimOverlayCoordinates
    }
    
    open var boundingMapRect: MKMapRect {
        return MKMapRectWorld
    }
}
