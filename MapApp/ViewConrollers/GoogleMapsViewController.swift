//
//  GoogleMapsViewController.swift
//  MapApp
//
//  Created by Kateryna Avramenko on 20.10.22.
//

import UIKit
import MapKit
import GoogleMaps

final class GoogleMapsViewController: UIViewController {
    
    private weak var mapView: GMSMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addMap()
        
    }
    
    private func addMap() {
        let mapView = GMSMapView(frame: view.bounds)
        mapView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(mapView)
        self.mapView = mapView
    }
    
    private func drawRoute(with array: NSArray ){
        array.forEach { route in
            let routeOverviewPolyline = (route as? NSDictionary)?.value(forKey:"overview_polyline") as? NSDictionary
            if let points = routeOverviewPolyline?.object(forKey: "points") as? String {
                let path = GMSPath(fromEncodedPath: points)
                let polyline = GMSPolyline(path: path)
                polyline.strokeWidth = 5
                polyline.strokeColor = .red
                polyline.map = self.mapView
            }
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.first else {
            return
        }
        let coordinate = location.coordinate
        let camera = GMSCameraPosition(latitude: coordinate.latitude, longitude: coordinate.longitude, zoom: 6.0)
        let mapView = GMSMapView.map(withFrame: view.frame, camera: camera)
        view.addSubview(mapView)
        let marker = GMSMarker()
        marker.position = CLLocationCoordinate2D(latitude: coordinate.latitude, longitude: coordinate.longitude)
        marker.title = "Sydney"
        marker.snippet = "Australia"
        marker.map = mapView
    }
    

    private func requestDirections(from fromLocation: CLLocationCoordinate2D, to toLocation: CLLocationCoordinate2D) {
        let fromLocation = "\(fromLocation.latitude), \(fromLocation.longitude)"
        let toLocation = "\(toLocation.latitude), \(toLocation.longitude)"
        
        let urlString = "https://maps.googleapis.com/maps/api/directions/json?origin=\(fromLocation)&destination=\(toLocation)&mode=driving&key=AIzaSyDlki3979VdZHmtYdYidqqdC0A9TGsLK5w"
        guard let url = URL(string: urlString) else { return }
        Task {
            let (data, _) = try await URLSession.shared.data(from: url)
            if let json = try JSONSerialization.jsonObject(with: data) as? [String : Any], let array = json["routes"] as? NSArray {
                drawRoute(with: array)
            }
        }
    }
    
}

extension GoogleMapsViewController: GMSMapViewDelegate {
    func mapView(_ mapView: GMSMapView, didLongPressAt coordinate: CLLocationCoordinate2D) {
        mapView.clear()
        
        let marker = GMSMarker(position: coordinate)
        marker.title = "\(Date())"
        marker.appearAnimation = .pop
        
        marker.map = mapView
        
        if let userLocation = mapView.myLocation?.coordinate {
            requestDirections(from: coordinate, to: userLocation)
        }
    }
    
}
