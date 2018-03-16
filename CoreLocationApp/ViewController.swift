//
//  ViewController.swift
//  CoreLocationApp
//
//  Created by jojoestar on 3/15/18.
//  Copyright © 2018 jojoestar. All rights reserved.
//

import UIKit
import CoreLocation
import MapKit
import AVFoundation


class ViewController: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate{
    
    @IBOutlet weak var dragonballLabel: UILabel!
    @IBOutlet weak var map: MKMapView!
    var locationManager = CLLocationManager()
    var dragonball: [String?] = []
    var audioPlayer:AVAudioPlayer!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.locationManager.requestWhenInUseAuthorization()
        
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.startUpdatingLocation()
        }
        
        map.delegate = self
        map.mapType = .standard
        map.isZoomEnabled = true
        map.isScrollEnabled = true
        if let coor = map.userLocation.location?.coordinate{
            map.setCenter(coor, animated: true)
            
        }
        map.tintColor = UIColor.red
        random(locationManager)
        playSound()
        addDimOverlay()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    func random(_ manager: CLLocationManager){
        let firstloc:CLLocationCoordinate2D = manager.location!.coordinate
        let span = MKCoordinateSpanMake(0.002, 0.002)
        let region = MKCoordinateRegion(center: firstloc, span: span)
        map.setRegion(region, animated: false)
        func generateRandomCoordinates(min: UInt32, max: UInt32)-> CLLocationCoordinate2D {
            //Get the Current Location's longitude and latitude
            let currentLong = firstloc.longitude
            let currentLat = firstloc.latitude
            
            //1 KiloMeter = 0.00900900900901° So, 1 Meter = 0.00900900900901 / 1000
            let meterCord = 0.00900900900901 / 1000
            
            //Generate random Meters between the maximum and minimum Meters
            let randomMeters = UInt(arc4random_uniform(max) + min)
            
            //then Generating Random numbers for different Methods
            let randomPM = arc4random_uniform(6)
            
            //Then we convert the distance in meters to coordinates by Multiplying number of meters with 1 Meter Coordinate
            let metersCordN = meterCord * Double(randomMeters)
            
            //here we generate the last Coordinates
            if randomPM == 0 {
                return CLLocationCoordinate2D(latitude: currentLat + metersCordN, longitude: currentLong + metersCordN)
            }else if randomPM == 1 {
                return CLLocationCoordinate2D(latitude: currentLat - metersCordN, longitude: currentLong - metersCordN)
            }else if randomPM == 2 {
                return CLLocationCoordinate2D(latitude: currentLat + metersCordN, longitude: currentLong - metersCordN)
            }else if randomPM == 3 {
                return CLLocationCoordinate2D(latitude: currentLat - metersCordN, longitude: currentLong + metersCordN)
            }else if randomPM == 4 {
                return CLLocationCoordinate2D(latitude: currentLat, longitude: currentLong - metersCordN)
            }else {
                return CLLocationCoordinate2D(latitude: currentLat - metersCordN, longitude: currentLong)
            }
            
        }
        for i in 1 ..< 8{
            let annotation = MKPointAnnotation()
            annotation.coordinate = generateRandomCoordinates(min: 20, max: 70) //this will be the maximum and minimum distance of the annotation from the current Location (Meters)
            annotation.title = "Dragon Ball \(i)"
            annotation.subtitle = "\(i)*"
            map.addAnnotation(annotation)
        }
    }
    func updateLabel(){
        var string = ""
        for ball in dragonball{
            string += " \(ball!), "
        }
        dragonballLabel.text = "Dragon Balls:" + string
        if dragonball.count == 7 {
            print("in function")
            let alert = UIAlertController(title: "You found all the Dragon Balls!", message: "Make a wish!", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Play Again", style: .default, handler: {action in self.resetgame()}))
            self.present(alert, animated: true)
        }
    }
    func resetgame(){
        dragonballLabel.text = "Dragonballs:"
        dragonball = []
        random(locationManager)
        playSound()
    }
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {

        let locValue:CLLocationCoordinate2D = manager.location!.coordinate
        map.mapType = MKMapType.standard
        let meters = (0.00900900900901 / 1000) * 10
        for annotation in map.annotations{
            if !(annotation.isMember(of: MKUserLocation.self)){
                if (locValue.longitude <= annotation.coordinate.longitude + meters && locValue.longitude >= annotation.coordinate.longitude - meters && locValue.latitude <= annotation.coordinate.latitude + meters && locValue.latitude >= annotation.coordinate.latitude - meters){
                    let alert = UIAlertController(title: "Found a Dragon Ball!", message: "\(annotation.title!!)", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "Continue", style: .default, handler: nil))
                    self.present(alert, animated: true)
                    dragonball.append(annotation.subtitle!!)
                    map.removeAnnotation(annotation)
                    playSound()
                    }
            }
        }
        updateLabel()
    }

    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if annotation is MKUserLocation { return nil }
        
        let identifier = "CustomAnnotation"
        
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier)
        
        if annotationView == nil {
            annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: identifier)
            annotationView!.canShowCallout = true
            
            let pinImage = UIImage(named: "dragonball1.jpg")
            let size = CGSize(width: 25, height: 25)
            UIGraphicsBeginImageContext(size)
            pinImage?.draw(in: CGRect(x:0, y:0, width:size.width, height:size.height))
            let resizedImage = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            
            annotationView?.image = resizedImage
            
            // go ahead and use forced unwrapping and you'll be notified if it can't be found; alternatively, use `guard` statement to accomplish the same thing and show a custom error message
        } else {
            annotationView!.annotation = annotation
        }
        
        return annotationView
    }
    func playSound() {
        
        let audioFilePath = Bundle.main.path(forResource: "El Radar del Dragon 1", ofType: "mp3")
        
        if audioFilePath != nil {
            
            let audioFileUrl = NSURL.fileURL(withPath: audioFilePath!)
            do{
                audioPlayer = try AVAudioPlayer(contentsOf: audioFileUrl)
                audioPlayer.play()
            }
            catch{
                print("audio file cannot play")
            }
        }
        else {
            print("audio file is not found")
        }
    }
    func addDimOverlay() {
        let dimOverlay : DimOverlay = DimOverlay(mapView: map)
        map.add(dimOverlay)
    }
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer{
        if overlay is DimOverlay {
            return DimOverlayRenderer(overlay: overlay, dimAlpha: 0.7, color: UIColor(red: 0/255, green: 81/255, blue: 16/255, alpha: 1.0))
        }
        return MKOverlayRenderer(overlay: overlay)
    }
}

