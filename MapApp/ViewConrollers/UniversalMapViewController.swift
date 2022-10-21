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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        LocationService.shared.requestLocation()
        
        view.insertSubview(mapService.container, at: 0)
        mapService.container.frame = view.bounds
        mapService.container.autoresizingMask = [.flexibleHeight, .flexibleWidth]
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
        guard let coordinates = LocationService.shared.manager.location?.coordinate else { return }
        mapService.locateDevice(at: coordinates)
    }
    
}

extension UniversalMapViewController: UniversalMapServiceDelegate {
    
    func mapView(_ mapView: UniversalMapProvider, didLongPressAt coordinate: CLLocationCoordinate2D){
        mapService.addPin(with: "\(Date())", to: coordinate)
    }
    
}

extension UniversalMapViewController: SearchViewControllerDelegate {
    func search(_ vc: SearchViewController, didSelectLocationWith coordinates: CLLocationCoordinate2D) {
        mapService.locateDevice(at: coordinates)
    }
}
