//
//  MapDimOverlayRender.swift
//  CoreLocationApp
//
//  Created by jojoestar on 3/15/18.
//  Copyright © 2018 jojoestar. All rights reserved.
//

import MapKit
import CoreLocation

open class DimOverlayRenderer : MKOverlayRenderer {
    
    open var overlayColor : UIColor = .black
    
    public override init(overlay: MKOverlay) {
        super.init(overlay: overlay)
        alpha = 0.2
    }
    
    public init(overlay: MKOverlay, dimAlpha : CGFloat, color : UIColor) {
        super.init(overlay: overlay)
        alpha = dimAlpha
        overlayColor = color
    }
    
    open override func draw(_ mapRect: MKMapRect, zoomScale: MKZoomScale, in context: CGContext) {
        context.setFillColor(self.overlayColor.cgColor);
        context.fill(rect(for: MKMapRectWorld))
}
}
