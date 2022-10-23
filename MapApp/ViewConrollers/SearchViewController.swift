//
//  SearchViewController.swift
//  MapApp
//
//  Created by Kateryna Avramenko on 21.10.22.
//

import UIKit
import CoreLocation

protocol SearchViewControllerDelegate: AnyObject {
    func search(_ vc: SearchViewController, didSelectLocationWith location: LocationRepr)
}

class SearchViewController: UIViewController {
    
    public weak var delegate: SearchViewControllerDelegate?
    
    private let label: UILabel = {
        let label = UILabel()
        label.text = "Where to go?"
        label.font = .systemFont(ofSize: 24, weight: .semibold)
        return label
    }()
    
    private let field: UITextField = {
        let field = UITextField()
        field.placeholder = "Enter destination"
        field.layer.cornerRadius = 9
        field.backgroundColor = .tertiarySystemBackground
        field.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: 50))
        field.leftViewMode = .always
        return field
    }()
    
    private let representingField: UITextField = {
        let field = UITextField()
        field.placeholder = "Your result"
        field.layer.cornerRadius = 9
        field.backgroundColor = .tertiarySystemBackground
        field.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: 50))
        field.leftViewMode = .always
        field.isEnabled = false
        return field
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addSubview(label)
        view.addSubview(field)
        view.addSubview(representingField)
        field.delegate = self
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        label.sizeToFit()
        label.frame = CGRect(x: 10, y: 10, width: label.frame.size.width, height: label.frame.size.height)
        field.frame = CGRect(x: 10, y: 20 + label.frame.size.height, width: view.frame.size.width - 20, height: 50)
        representingField.frame = CGRect(x: 10, y: label.frame.size.height + field.frame.size.height + 20, width: view.frame.size.width - 20, height: 50)
    }

}

extension SearchViewController: UITextFieldDelegate {
    
    func textFieldDidChangeSelection(_ textField: UITextField) {
        if let text = field.text, !text.isEmpty {
            LocationService.shared.findLocation(with: text) { [weak self] places in
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5){
                    print("places count is \(places.count)")
                    if places.count < 5 {
                        self?.representingField.text = places.first?.title ?? ""
                    } else {
                        self?.representingField.text = "Clarify your destination"
                    }
                }
            }
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        field.resignFirstResponder()
        guard let location = LocationService.shared.lastFoundLocations.first else { return true }
        delegate?.search(self, didSelectLocationWith: location)
        return true
    }
    
}
