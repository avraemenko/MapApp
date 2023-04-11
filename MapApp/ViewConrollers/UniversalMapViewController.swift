//
//  UniversalMapViewController.swift
//  MapApp
//
//  Created by Kateryna Avramenko on 21.10.22.
//

import UIKit
import MapKit
import GoogleMaps
import FloatingPanel

final class UniversalMapViewController: UIViewController {
    
    @IBOutlet private weak var searchTextField: UITextField!
    private var mapService = UniversalMapService()
    
    override func viewDidLoad(){
        super.viewDidLoad()
        LocationService.shared.requestLocation()
      
        
        view.insertSubview(mapService.container, at: 0)
        mapService.container.frame = view.bounds
        mapService.container.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        
        if LocationService.shared.manager.authorizationStatus == .authorizedAlways ||
            LocationService.shared.manager.authorizationStatus == .authorizedWhenInUse {
            let coordinates = LocationService.shared.manager.location?.coordinate
            mapService.locateDevice(at: coordinates!)
        }
        mapService.delegate = self
    
        let panel = FloatingPanelController()
        let searchVC = SearchViewController()
        searchVC.delegate = self
        panel.set(contentViewController: searchVC)
        panel.addPanel(toParent: self)
       
    }
    
    @IBAction func mapSwitch(_ sender: UISwitch) {
        mapService.switchProvider(to: sender.isOn ? GMSMapView.self : MKMapView.self)
       
    }
    @IBAction func mapTypeSwitch(_ sender: UISegmentedControl) {
        mapService.switchMapType(to: .init(rawValue: sender.selectedSegmentIndex) ?? .normal)
    }
    
    @IBAction func locateDevice(_ sender: UIButton) {
        let alert = UIAlertController(title: "Alert", message: "Your location is not enabled", preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.default, handler: nil))
        guard let coordinates = LocationService.shared.manager.location?.coordinate else {
            self.present(alert, animated: true, completion: nil)
            return
        }
        mapService.locateDevice(at: coordinates)
    }
    
}

extension UniversalMapViewController: UniversalMapServiceDelegate {
    
    func mapView(_ mapView: UniversalMapProvider, didLongPressAt coordinate: CLLocationCoordinate2D){
        mapService.addPin(with: "\(Date())", to: coordinate)
    }
    
}

extension UniversalMapViewController: SearchViewControllerDelegate {
    func search(_ vc: SearchViewController, didSelectLocationWith location: LocationRepr) {
       
        guard let coordinates = location.coordinates else { return }
        mapService.addPin(with: location.title, to: coordinates)
        if let locationFrom = LocationService.shared.manager.location?.coordinate {
            mapService.mapView.requestDirections(from: locationFrom, to: coordinates)
        } else {
            let alert = UIAlertController(title: "Alert", message: "Your location is not enabled for directions.", preferredStyle: UIAlertController.Style.alert)
            alert.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
        
    }
  
    
}
