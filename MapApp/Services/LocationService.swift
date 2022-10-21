//
//  LocationService.swift
//  MapApp
//
//  Created by Kateryna Avramenko on 21.10.22.
//

import Foundation
import CoreLocation

struct LocationRepr {
    let title: String
    let coordinates: CLLocationCoordinate2D?
}

class LocationService {
    static let shared = LocationService()
    
    let manager = CLLocationManager()
    
    var lastFoundLocations = [LocationRepr]()
    
    public func requestLocation() {
        manager.requestWhenInUseAuthorization()
        manager.startUpdatingLocation()
    }
    
    public func findLocation(with query: String, completionHandler: @escaping  (([LocationRepr]) -> Void)) {
        let geoCoder = CLGeocoder()
        
        geoCoder.geocodeAddressString(query) { places, error in
            guard let places = places, error == nil else {
                completionHandler([])
                return
            }
            
            let models: [LocationRepr] = places.compactMap({ place in
                
                var name = ""
                
                if let locationName = place.name {
                    name += locationName
                }
                
                if let adminRegion = place.administrativeArea {
                    name += ", \(adminRegion)"
                }
                
                if let locality = place.locality{
                    name += ", \(locality)"
                }
                
                if let country = place.country{
                    name += ", \(country)"
                }
                
                print(place)
                
                let result = LocationRepr(title: name, coordinates: place.location?.coordinate)
                
                return result
            })
            
            self.lastFoundLocations = models
            completionHandler(models)
        }
    }
}
