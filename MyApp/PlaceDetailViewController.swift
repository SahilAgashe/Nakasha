//
//  PlaceDetailViewController.swift
//  MyApp
//
//  Created by SAHIL AMRUT AGASHE on 14/12/23.
//

import UIKit

class PlaceDetailViewController: UIViewController {
    
    // MARK: - Properties
    private let place: PlaceAnnotation
    
    private lazy var nameLabel: UILabel = {
        let lbl = UILabel()
        lbl.translatesAutoresizingMaskIntoConstraints = false
        lbl.numberOfLines = 0
        lbl.lineBreakMode = .byWordWrapping
        lbl.textAlignment = .left
        lbl.font = .preferredFont(forTextStyle: .title1)
        return lbl
    }()
    
    private lazy var addressLabel: UILabel = {
        let lbl = UILabel()
        lbl.translatesAutoresizingMaskIntoConstraints = false
        lbl.textAlignment = .left
        lbl.font = .preferredFont(forTextStyle: .body)
        lbl.alpha = 0.4
        return lbl
    }()
    
    private lazy var directionButton: UIButton = {
        let config = UIButton.Configuration.bordered()
        let button = UIButton(configuration: config)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Direction", for: .normal)
        button.addTarget(self, action: #selector(directionButtonTapped), for: .touchUpInside)
        return button
    }()
    
    private lazy var callButton: UIButton = {
        let config = UIButton.Configuration.bordered()
        let button = UIButton(configuration: config)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Call", for: .normal)
        button.addTarget(self, action: #selector(callButtonTapped), for: .touchUpInside)
        return button
    }()
    
    // MARK: - Initializers
    init(place: PlaceAnnotation) {
        self.place = place
        super.init(nibName: nil, bundle: nil)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Selectors
    @objc private func directionButtonTapped() {
        let coordinate = place.location.coordinate
        guard let url = URL(string: "https://maps.apple.com/?daddr=\(coordinate.latitude), \(coordinate.longitude)") else {
            print("DEBUG: Given Url is invalid!")
            return
        }
        
        UIApplication.shared.open(url)
    }
    
    @objc private func callButtonTapped() {
        
        // place.phone = +(512)-435-2345 , but we need in format => 5124352345
        guard let url = URL(string: "tel://\(place.phone.formatPhoneForCall)") else { return }
        UIApplication.shared.open(url)
    }
    
    // MARK: - Helpers
    private func setupUI() {
        view.backgroundColor = .systemBackground
        
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.alignment = .leading
        stackView.axis = .vertical
        stackView.spacing = UIStackView.spacingUseSystem
        stackView.isLayoutMarginsRelativeArrangement = true
        stackView.directionalLayoutMargins = NSDirectionalEdgeInsets(top: 20, leading: 20, bottom: 20, trailing: 20)
        stackView.addArrangedSubview(nameLabel)
        stackView.addArrangedSubview(addressLabel)
        
        nameLabel.text = place.name
        nameLabel.widthAnchor.constraint(equalToConstant: view.bounds.width - 20).isActive = true
        
        addressLabel.text = place.address
        
        let contactStackView = UIStackView()
        contactStackView.translatesAutoresizingMaskIntoConstraints = false
        contactStackView.axis = .horizontal
        contactStackView.spacing = UIStackView.spacingUseSystem
        contactStackView.addArrangedSubview(directionButton)
        contactStackView.addArrangedSubview(callButton)
        
        stackView.addArrangedSubview(contactStackView)
        view.addSubview(stackView)
        
    }
}
