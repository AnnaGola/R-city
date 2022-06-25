//
//  MapVC.swift
//  R • city
//
//  Created by anna on 08.06.2022.
//i

import UIKit
import MapKit
import CoreLocation

protocol MapViewControllerDelegare {
    
    func getAdderess(_ newAddress: String?)
}

class MapVC: UIViewController {

    let locationManager = CLLocationManager()
    var regionInMeters = 3000.00
    var placeCoordinate: CLLocationCoordinate2D?
    var directionsArray: [MKDirections] = []
    var mapViewControllerDelegate: MapViewControllerDelegare?
    var place = Place()
    var incomeSegueIdentifier = ""
    let annotationIdentifier = "annotationIdentifier"
    var previousLocation: CLLocation? {
        didSet {
            startTrackingUserLocation()
        }
    }
    
    @IBOutlet weak var getDirectionButton: UIButton!
    @IBOutlet weak var marker: UIImageView!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var currentAddress: UILabel!
    @IBOutlet weak var doneButton: UIButton!
    @IBOutlet weak var distanceAndTimeLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
       
        currentAddress.text = ""
        distanceAndTimeLabel.text = ""
        mapView.delegate = self
        setupMapView()
        checkLocationServices()
    }
   
    @IBAction func centerViewInUserLocation() {
        showUserLocation()
    }
    
    @IBAction func closeVC() {
        dismiss(animated: true)
    }
    
    @IBAction func getDirectionButtonPressed() {
        
        guard let location = locationManager.location?.coordinate else {
            showAlert(title: "Error", message: "Location is not found")
            return
        }
        
        locationManager.startUpdatingLocation()
        previousLocation = (CLLocation(latitude: location.latitude, longitude: location.longitude))
        
        
        guard let request = createDirectionsRequest(from: location) else {
            showAlert(title: "Error", message: "Destination is not found")
            return
        }
        
        let directions = MKDirections(request: request)
        resetMapView(withNew: directions)
        directions.calculate { (response, error) in
            if let error = error {
                print(error)
                return
            }
            
            guard let response = response else {
                self.showAlert(title: "Error", message: "Direction is not available")
                return
            }
            
            for route in response.routes {
                self.mapView.addOverlay(route.polyline)
                self.mapView.setVisibleMapRect(route.polyline.boundingMapRect, animated: true)
                
                let distance = String(format: "%.1f", route.distance / 1000)
                let timeInteral = Int(route.expectedTravelTime / 60)
                
                self.distanceAndTimeLabel.isHidden = false
                self.distanceAndTimeLabel.text = "Walking for \(timeInteral) min    Distance is \(distance) km"
            }
        }
    }
    

   @IBAction func doneButtonPressed() {
        mapViewControllerDelegate?.getAdderess(currentAddress.text)
        dismiss(animated: true)
    }
    
    func setupMapView() {
        
        getDirectionButton.isHidden = true
        
        if incomeSegueIdentifier == "showMap" {
            setupPlacemark()
            marker.isHidden = true
            currentAddress.isHidden = true
            doneButton.isHidden = true
            getDirectionButton.isHidden = false
        }
    }
    
    func resetMapView(withNew directions: MKDirections) {
        
        mapView.removeOverlays(mapView.overlays)
        directionsArray.append(directions)
        let _ = directionsArray.map { $0.cancel() }
        directionsArray.removeAll()
    }

    func setupPlacemark() {
        
        guard let location = place.location else { return }
        
        let geocoder = CLGeocoder()
        geocoder.geocodeAddressString(location) { (placemarks, error) in
            if let error = error {
                print(error)
                return
            }
            guard let placemarks = placemarks else { return }
            let placemark = placemarks.first
            let annotation = MKPointAnnotation()
            annotation.title = self.place.name
            annotation.subtitle = self.place.shortDescription
            
            guard let placemarkLocation = placemark?.location else { return }
            annotation.coordinate = placemarkLocation.coordinate
            self.placeCoordinate = placemarkLocation.coordinate
            
            self.mapView.showAnnotations([annotation], animated: true)
            self.mapView.selectAnnotation(annotation, animated: true)
        }
    }
    
    func setupLocationManager() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
    }
    
    func checkLocationServices() {
        
        if CLLocationManager.locationServicesEnabled() {
            setupLocationManager()
            checkLocationAuthorization()
        } else {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                self.showAlert(title: "Location services are disabled",
                               message: "To enable it go to Settings / Privacy / Location / On")
            }
        }
    }
    
    
    func checkLocationAuthorization() {
        
        let manager = CLLocationManager()
        let status: CLAuthorizationStatus
        
        if #available(iOS 14, *) {
            status = manager.authorizationStatus
        } else {
            status = CLLocationManager.authorizationStatus()
        }
        
        switch status {
        case .authorizedWhenInUse:
            mapView.showsUserLocation = true
            if incomeSegueIdentifier == "getAddress" { showUserLocation() }
            break
        case .denied:
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                self.showAlert(title: "Cannot defind your location",
                               message: "To change it go to Settings / R • city / Location / On")
            }
            break
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        case .restricted:
            let alert = UIAlertController(title: "restricted", message: "cannot define your location", preferredStyle: .alert)
            let stop = UIAlertAction(title: "stop", style: .destructive, handler: nil)
            alert.addAction(stop)
            present(alert, animated: true, completion: nil)
            break
        case .authorizedAlways:
            break
        @unknown default:
            fatalError()
        }
    }
    
    func showUserLocation() {
        
        if let location = locationManager.location?.coordinate {
            let region = MKCoordinateRegion(center: location,
                                            latitudinalMeters: regionInMeters,
                                            longitudinalMeters: regionInMeters)
            mapView.setRegion(region, animated: true)
       }
    }

    func createDirectionsRequest(from coordinate: CLLocationCoordinate2D) -> MKDirections.Request? {
        
        guard let destinationCoordinate = placeCoordinate else { return nil }
        let startingPoint = MKPlacemark(coordinate: coordinate)
        let destinationPoint = MKPlacemark(coordinate: destinationCoordinate)
        
        let request = MKDirections.Request()
        request.source = MKMapItem(placemark: startingPoint)
        request.destination = MKMapItem(placemark: destinationPoint)
        request.transportType = .walking
        request.requestsAlternateRoutes = true
        
        return request
    }
    
    
    func startTrackingUserLocation() {
        
        guard let previousLocation = previousLocation else { return }
        let center = getCenterLocation(for: mapView)
        guard center.distance(from: previousLocation) > 30 else { return }
        self.previousLocation = center
         
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            self.showUserLocation()
        }
        
    }
     
    
    
    func getCenterLocation(for mapView: MKMapView) -> CLLocation {
        
        let latitude = mapView.centerCoordinate.latitude
        let longitude = mapView.centerCoordinate.longitude
        
        return CLLocation(latitude: latitude, longitude: longitude)
    }
   
    
    func showAlert(title: String, message: String) {
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "Okay", style: .default)
        alert.addAction(okAction)
        present(alert, animated: true)
    }
}

extension MapVC: MKMapViewDelegate {
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        guard !(annotation is MKUserLocation) else { return nil }
        
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: "annotationIdentifier") as? MKPinAnnotationView
        if annotationView == nil {
            annotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: "annotationIdentifier")
            annotationView?.canShowCallout = true
        }
        if let imageData = place.imageData {
            let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 45, height: 45))
                 imageView.layer.cornerRadius = 5
                 imageView.clipsToBounds = true
                 imageView.image = UIImage(data: imageData)
            annotationView?.rightCalloutAccessoryView = imageView
        }
        return annotationView
    }
    
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        
        let center = getCenterLocation(for: mapView)
        let geocoder = CLGeocoder()
        
        geocoder.cancelGeocode()
        
        geocoder.reverseGeocodeLocation(center) { (placemarks, error) in
            
            if let error = error {
                print(error)
                return
            }
            guard let placemarks = placemarks else { return }
            let placemark = placemarks.first
            let streetName = placemark?.thoroughfare
            let buildNumber = placemark?.subThoroughfare
            
            DispatchQueue.main.async {
                if streetName != nil && buildNumber != nil {
                    self.currentAddress.text = "\(streetName!), \(buildNumber!)"
                } else if streetName != nil {
                    self.currentAddress.text = "\(streetName!)"
                } else {
                    self.currentAddress.text = ""
                }
            }
        }
    }
    
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        
        let renderer = MKPolylineRenderer(overlay: overlay as! MKPolyline)
        renderer.strokeColor = .tintColor
        return renderer
        
    }
}

extension MapVC: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        checkLocationAuthorization()
    }
}
