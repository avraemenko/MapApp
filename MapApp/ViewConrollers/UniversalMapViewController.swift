//
//  UniversalMapViewController.swift
//  MapApp
//
//  Created by Kateryna Avramenko on 21.10.22.
//

import UIKit
import MapKit
import GoogleMaps

final class UniversalMapViewController: UIViewController {
    
    private var mapService = UniversalMapService()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        view.insertSubview(mapService.container, at: 0)
        mapService.container.frame = view.bounds
        mapService.container.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        mapService.delegate = self
    }
    
    @IBAction func mapSwitch(_ sender: UISwitch) {
        mapService.switchProvider(to: sender.isOn ? GMSMapView.self : MKMapView.self)
    }
    @IBAction func mapTypeSwitch(_ sender: UISegmentedControl) {
        mapService.switchMapType(to: .init(rawValue: sender.selectedSegmentIndex) ?? .normal)
    }
    

}

extension UniversalMapViewController :
    UniversalMapServiceDelegate {
    
    func mapView(_ mapView: UniversalMapProvider, didLongPressAt coordinate: CLLocationCoordinate2D){
        mapService.addPin(with: "\(Date())", to: coordinate)
    }
    
}
