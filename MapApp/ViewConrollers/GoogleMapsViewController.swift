//
//  GoogleMapsViewController.swift
//  MapApp
//
//  Created by Kateryna Avramenko on 20.10.22.
//

import UIKit
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
    
}
