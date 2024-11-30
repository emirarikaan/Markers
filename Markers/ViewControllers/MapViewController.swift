//
//  ViewController.swift
//  Markers
//
//  Created by Emir Arıkan on 27.11.2024.
//

import UIKit
import MapKit
import CoreLocation

class MapViewController: UIViewController {
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var startTrackingButton: UIButton!
    @IBOutlet weak var stopTrackingButton: UIButton!
    
    private let viewModel = MapViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureViewModel()
        configureMapView()
        setupUserTrackingButton()
        loadSavedMarkers()
        drawRoute()
        
        NotificationCenter.default.addObserver(self, selector: #selector(updateMapRegion), name: .startUpdatingLocation, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(addMarker(notification:)), name: .locationUpdated, object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    private func configureViewModel() {
        viewModel.delegate = self
        viewModel.checkLocationPermission()
    }
    
    private func configureMapView() {
        mapView.delegate = self
        mapView.showsUserLocation = true
    }
    
    private func setupUserTrackingButton() {
        let userTrackingButton = MKUserTrackingButton(mapView: mapView)
        userTrackingButton.backgroundColor = .gray
        userTrackingButton.layer.borderColor = UIColor.gray.cgColor
        userTrackingButton.tintColor = .white
        userTrackingButton.layer.borderWidth = 2
        userTrackingButton.layer.cornerRadius = 12
        userTrackingButton.clipsToBounds = true
        userTrackingButton.translatesAutoresizingMaskIntoConstraints = false
        mapView.addSubview(userTrackingButton)
        
        NSLayoutConstraint.activate([
            userTrackingButton.bottomAnchor.constraint(equalTo: mapView.bottomAnchor, constant: -32),
            userTrackingButton.trailingAnchor.constraint(equalTo: mapView.trailingAnchor, constant: -16),
            userTrackingButton.widthAnchor.constraint(equalToConstant: 44),
            userTrackingButton.heightAnchor.constraint(equalToConstant: 44),
        ])
    }
    
    private func loadSavedMarkers() {
        let annotations = viewModel.loadSavedMarkers()
        mapView.addAnnotations(annotations)
    }
    
    private func drawRoute() {
        mapView.removeOverlays(mapView.overlays)
        if let polyline = viewModel.getPolyline() {
            mapView.addOverlay(polyline)
        }
    }
    
    private func toggleTracking(isTracking: Bool) {
        if isTracking {
            LocationManager.shared.startTracking()
        } else {
            LocationManager.shared.stopTracking()
        }
        mapView.showsUserLocation = isTracking
        startTrackingButton.isHidden = isTracking
        stopTrackingButton.isHidden = !isTracking
    }
    
    @objc private func updateMapRegion() {
        guard let currentCoordinate = LocationManager.shared.currentLocation?.coordinate else { return }
        let region = MKCoordinateRegion(center: currentCoordinate, latitudinalMeters: 300, longitudinalMeters: 300)
        mapView.setRegion(region, animated: true)
    }
    
    @objc private func addMarker(notification: Notification) {
        guard let location = notification.object as? CLLocation else { return }
        viewModel.addMarker(location: location)
    }
    
    @IBAction private func startTrackingAction(_ sender: UIButton) {
        toggleTracking(isTracking: true)
    }
    
    @IBAction private func stopTrackingAction(_ sender: UIButton) {
        toggleTracking(isTracking: false)
    }
    
    @IBAction func resetRouteAction(_ sender: Any) {
        viewModel.clearMarkers()
        mapView.removeOverlays(mapView.overlays)
    }
}

// MARK: - MapViewModelDelegate
extension MapViewController: MapViewModelDelegate {
    func didUpdateMarkers() {
        mapView.removeAnnotations(mapView.annotations)
        loadSavedMarkers()
        drawRoute()
    }
}

// MARK: - MKMapViewDelegate
extension MapViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        if let polyline = overlay as? MKPolyline {
            let renderer = MKPolylineRenderer(polyline: polyline)
            renderer.strokeColor = .blue
            renderer.lineWidth = 4
            return renderer
        }
        return MKOverlayRenderer()
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if annotation is MKUserLocation {
            return nil
        }
        let identifier = "LocationAnnotation"
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier)
        if annotationView == nil {
            annotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: identifier)
            annotationView?.canShowCallout = true
        } else {
            annotationView?.annotation = annotation
        }
        return annotationView
    }
}



