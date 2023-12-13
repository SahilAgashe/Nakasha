//
//  PlacesTableViewController.swift
//  MyApp
//
//  Created by SAHIL AMRUT AGASHE on 14/12/23.
//

import MapKit

class PlacesTableViewController: UITableViewController {
    
    // MARK: - Properties
    var userLocation: CLLocation
    var places: [PlaceAnnotation]
    
    private var indexForSelectedRow: Int? {
        self.places.firstIndex { $0.isSelected == true }
    }
    
    // MARK: - Initializers
    init(userLocation: CLLocation, places: [PlaceAnnotation]) {
        self.userLocation = userLocation
        self.places = places
        super.init(nibName: nil, bundle: nil)
        
        // register cell
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "PlaceCell")
        self.places.swapAt(indexForSelectedRow ?? 0, 0)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Private Helpers
    private func calculateDistance(from: CLLocation, to: CLLocation) -> CLLocationDistance{
        from.distance(from: to)
    }
    
    private func formatDistanceForDisplay(_ distance: CLLocationDistance) -> String {
        let meters = Measurement(value: distance, unit: UnitLength.meters)
        return meters.converted(to: .miles).formatted()
    }
    
    // MARK: - UITableViewDataSource
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return places.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "PlaceCell") else { return UITableViewCell() }
        let place = places[indexPath.row]
        
        // cell configuration
        var contentConfig = cell.defaultContentConfiguration()
        contentConfig.text = place.name
        contentConfig.secondaryText = formatDistanceForDisplay(calculateDistance(from: userLocation, to: place.location))
        
        cell.contentConfiguration = contentConfig
        cell.backgroundColor = place.isSelected ? .lightGray : .clear
        return cell
    }
    
    // MARK: - UITableViewDelegate
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let place = places[indexPath.row]
        let placeDetailVC = PlaceDetailViewController(place: place)
        present(placeDetailVC, animated: true)
    }
    
}
