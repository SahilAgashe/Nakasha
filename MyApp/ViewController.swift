//
//  ViewController.swift
//  MyApp
//
//  Created by SAHIL AMRUT AGASHE on 12/12/23.
//

import UIKit
import MapKit

class ViewController: UIViewController {
    
    // MARK: - Properties
    private var locationManager: CLLocationManager?
    private var places: [PlaceAnnotation] = []
    
    private lazy var mapView: MKMapView = {
        let map = MKMapView()
        map.delegate = self
        map.translatesAutoresizingMaskIntoConstraints = false
        map.showsUserLocation = true
        return map
    }()
    
    private lazy var searchTextField: UITextField = {
        let searchTF = UITextField()
        searchTF.translatesAutoresizingMaskIntoConstraints = false
        searchTF.layer.cornerRadius = 10
        searchTF.clipsToBounds = true
        searchTF.backgroundColor = .systemBackground
        searchTF.placeholder = "Search"
        searchTF.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: 0))
        searchTF.leftViewMode = .always
        searchTF.returnKeyType = .go
        searchTF.delegate = self
        return searchTF
    }()

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        locationManager = CLLocationManager()
        locationManager?.delegate = self
        
        locationManager?.requestWhenInUseAuthorization()
        locationManager?.requestAlwaysAuthorization()
        locationManager?.requestLocation()
        
        setupUI()
    }
    
    // MARK: - Private Helpers
    private func setupUI() {
        view.backgroundColor = .cyan
        
        view.addSubview(searchTextField)
        view.addSubview(mapView)
        view.bringSubviewToFront(searchTextField)
        
        NSLayoutConstraint.activate([
            // mapView
            mapView.widthAnchor.constraint(equalTo: view.widthAnchor),
            mapView.heightAnchor.constraint(equalTo: view.heightAnchor),
            mapView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            mapView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            
            // searchTextField
            searchTextField.heightAnchor.constraint(equalToConstant: 44),
            searchTextField.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            searchTextField.widthAnchor.constraint(equalToConstant: view.bounds.size.width / 1.2),
            searchTextField.topAnchor.constraint(equalTo: view.topAnchor, constant: 60)
        ])
        
        //        // Adding annotations to my places
        //        mapView.addAnnotations([Bhandara, Tumsar, Nagpur, Gondia, Wardha, Chandrapur, Yavatmal, Nanded, Indore, Aurangabad, Hyderabad])
        //
        //        let region = MKCoordinateRegion(center: Nagpur.coordinate, latitudinalMeters: 1000000, longitudinalMeters: 1000000)
        //        mapView.setRegion(region, animated: true)
    }
    
    private func checkLocationAuthorization() {
        guard let locationManager = locationManager,
              let location = locationManager.location else { return }
        
        switch locationManager.authorizationStatus {
        case .authorizedAlways, .authorizedWhenInUse:
            let region = MKCoordinateRegion(center: location.coordinate, latitudinalMeters: 750, longitudinalMeters: 750)
            print("DEBUG: location is \(dump(location)), and coordinate is \(location.coordinate)")
            mapView.setRegion(region, animated: true)
        case .notDetermined:
            print("DEBUG: notDetermined locationManager authorizationStatus")
        case .restricted:
            print("DEBUG: restricted locationManager authorizationStatus")
        case .denied:
            print("denied")
        @unknown default:
            print("DEBUG: @unknown default locationManager authorizationStatus")
        }
    }
    
    private func presentPlacesSheet(places: [PlaceAnnotation]) {
        
        guard let locationManager = locationManager,
              let userLocation = locationManager.location else { return }
        
        let placesTVC = PlacesTableViewController(userLocation: userLocation, places: places)
        placesTVC.modalPresentationStyle = .pageSheet
        
        if let sheet = placesTVC.sheetPresentationController {
            sheet.prefersGrabberVisible = true
            sheet.detents = [.medium(), .large()]
            present(placesTVC, animated: true)
        }
    }

    private func findNearbyPlaces(by query: String) {
        
        // clear all annotations
        mapView.removeAnnotations(mapView.annotations)
        
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = query
        request.region = mapView.region
        
        let search = MKLocalSearch(request: request)
        search.start { [weak self] (response: MKLocalSearch.Response?, error: Error?) in
            guard let response = response, error == nil else {
                return
            }
            
            self?.places = response.mapItems.map(PlaceAnnotation.init)
            self?.places.forEach { (place : PlaceAnnotation) in
                self?.mapView.addAnnotation(place)
            }
            
            if let places = self?.places {
                self?.presentPlacesSheet(places: places)
            }
            
            print("DEBUG: MKLocalSearch.Response is \(response.mapItems)")
        }
    }
    
}

// MARK: - MKMapViewDelegate
extension ViewController: MKMapViewDelegate {
    
    func mapView(_ mapView: MKMapView, didSelect annotation: MKAnnotation) {
        print("DEBUG: MKMapView didSelect annotation called.....")
        
        // clear all selections if there are
        clearAllSelections()
        
        guard let selectionAnnotation = annotation as? PlaceAnnotation else { return }
        let placeAnnotation = self.places.first { $0.id == selectionAnnotation.id }
        placeAnnotation?.isSelected = true
        
        presentPlacesSheet(places: self.places)
    }
    
    private func clearAllSelections() {
        self.places = self.places.map({ place in
            place.isSelected = false
            return place
        })
    }
}

// MARK: - CLLocationManagerDelegate
extension ViewController: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        print("DEBUG: locationManagerDidChangeAuthorization called.....")
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        print("DEBUG: locationManager didUpdateLocations called.....")
        checkLocationAuthorization()
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("DEBUG: locationManager didFailWithError ===> \(error)")
    }
}

// MARK: - UITextFieldDelegate
extension ViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        print("DEBUG: textFieldShouldReturn called...")
        
        let text = textField.text ?? ""
        if !text.isEmpty {
            textField.resignFirstResponder()
            // find nearby places
            findNearbyPlaces(by: text)
        }
        
        return true
    }
}
