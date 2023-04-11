//
//  UniversalMapProtocol.swift
//  MapApp
//
//  Created by Kateryna Avramenko on 21.10.22.
//

import MapKit
#if canImport(GoogleMaps)
import GoogleMaps
#endif

protocol UniversalMapProvider {
    
    var universalMapConfiguration: UniversalMapService.Configuration { get set }
    var needLongPressGesture: Bool { get }
    
    init()
    
    func addPin(with title: String, to coordinate: CLLocationCoordinate2D)
    
    func locateDevice(at coordinate: CLLocationCoordinate2D)
    
    func requestDirections(from fromCoordinate: CLLocationCoordinate2D, to toCoordinate: CLLocationCoordinate2D)
    
}

extension MKMapView: UniversalMapProvider {
    
    func drawRoute(with directions: MKRoute) {
        self.removeOverlays(self.overlays)
        self.addOverlay(directions.polyline, level: .aboveRoads)
        let rect = directions.polyline.boundingMapRect
        self.setRegion(MKCoordinateRegion(rect), animated: true)
    }
    
    
    func requestDirections(from fromCoordinate: CLLocationCoordinate2D, to toCoordinate: CLLocationCoordinate2D) {
        let sourcePlaceMark = MKPlacemark(coordinate: fromCoordinate)
        let destinationPlaceMark = MKPlacemark(coordinate: toCoordinate)
        
        let sourceMarkItem = MKMapItem(placemark: sourcePlaceMark)
        let destinationMarkItem = MKMapItem(placemark: destinationPlaceMark)
        
        let directionRequest = MKDirections.Request()
        directionRequest.source = sourceMarkItem
        directionRequest.destination = destinationMarkItem
        directionRequest.transportType = .automobile
        
        let direction = MKDirections(request: directionRequest)
        
        direction.calculate { [weak self] responce, error in
            if let responce = responce, error == nil {
                self?.drawRoute(with: responce.routes[0])
            }
        }
        
    }
    
    
    var needLongPressGesture: Bool { true }
    
    var universalMapConfiguration: UniversalMapService.Configuration {
        get {
            .init(mapType:
                    self.mapType == .standard || self.mapType == .mutedStandard ? .normal :
                    self.mapType == .hybrid || self.mapType == .hybridFlyover ? .hybrid :
                    .satellite
            )
        }
        set {
            switch newValue.mapType {
            case .normal: self.mapType = .standard
            case .satellite: self.mapType = .satellite
            case .hybrid: self.mapType = .hybrid
            }
        }
    }
    
    func addPin(with title: String, to coordinate: CLLocationCoordinate2D) {
        annotations.forEach { annotation in
            if !(annotation is MKUserLocation) {
                removeAnnotation(annotation)
            }
        }
        
        let annotation = MKPointAnnotation()
        annotation.title = title
        annotation.coordinate = coordinate
        
        addAnnotation(annotation)
        setCenter(coordinate, animated: true)
    }
    
    func locateDevice(at coordinate: CLLocationCoordinate2D) {
        annotations.forEach { annotation in
            if annotation is MKUserLocation {
                removeAnnotation(annotation)
            }
        }
        addAnnotation(userLocation)
        setCenter(coordinate, animated: true)
    }
    
}

#if canImport(GoogleMaps)
extension GMSMapView: UniversalMapProvider {
    
    func drawRoute(with array: NSArray) {
      // self.clear()
        array.forEach { route in
            let routeOverviewPolyline = (route as? NSDictionary)?.value(forKey:"overview_polyline") as? NSDictionary
            if let points = routeOverviewPolyline?.object(forKey: "points") as? String {
                let path = GMSPath(fromEncodedPath: points)
                let polyline = GMSPolyline(path: path)
                polyline.strokeWidth = 5
                polyline.strokeColor = .red
                polyline.map = self
            }
        }
    }
    
    
    var needLongPressGesture: Bool { false }
    
    var universalMapConfiguration: UniversalMapService.Configuration {
        get {
            .init(mapType:
                    self.mapType == .normal ? .normal :
                    self.mapType == .hybrid ? .hybrid :
                    .satellite
            )
        }
        set {
            switch newValue.mapType {
            case .normal: self.mapType = .normal
            case .satellite: self.mapType = .satellite
            case .hybrid: self.mapType = .hybrid
            }
        }
    }
    
    func addPin(with title: String, to coordinate: CLLocationCoordinate2D) {
        let location = GMSCameraPosition.camera(withLatitude: coordinate.latitude, longitude: coordinate.longitude, zoom: 6.0)
       
        let marker = GMSMarker(position: coordinate)
        marker.title = title
        marker.map = self
        self.selectedMarker = marker
        camera = location
    }
    
    func locateDevice(at coordinate: CLLocationCoordinate2D) {
        let location = GMSCameraPosition.camera(withLatitude: coordinate.latitude, longitude: coordinate.longitude, zoom: 6.0)
        camera = location
    }
    
    func requestDirections(from fromLocation: CLLocationCoordinate2D, to toLocationn: CLLocationCoordinate2D) {
        self.clear()
        let fromLocation = "\(fromLocation.latitude),\(fromLocation.longitude)"
        let toLocation = "\(toLocationn.latitude),\(toLocationn.longitude)"
        addPin(with: toLocation, to: toLocationn)
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
#endif

