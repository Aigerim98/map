//
//  ViewController.swift
//  MapApp
//
//  Created by Aigerim Abdurakhmanova on 20.06.2022.
//

import UIKit
import CoreData
import MapKit
import CoreLocation

protocol EditLocationDelegate: AnyObject {
    func editLocation(title: String, subtitle: String)
}

class ViewController: UIViewController {

    private var mapView: MKMapView = {
        let mapView = MKMapView()
        mapView.translatesAutoresizingMaskIntoConstraints = false
        return mapView
    }()
    
    private let tableView: UITableView = {
        let tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.isHidden = true
        return tableView
    }()
    
    private let segmentedControl = UISegmentedControl (items: ["Standard","Satellite","Hybrid"])
    private var leftButton = UIButton()
    
    private var previousLocation: CLLocation?
    private let locationManager = CLLocationManager()
    
    private var places = [MKPointAnnotation]()
    private var city: String!
    private var name: String!
    private var index: Int = 0
    private var editLocation: MKAnnotation!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self
        setUpNavigation()
        checkLocationServices()
        setUpConstraints()
        setUpSegmentedControl()
        setUpTable()
        
        let longTapGesture = UILongPressGestureRecognizer(target: self, action: #selector(handleLongTappedGesture(gestureRecognizer:)))
        mapView.addGestureRecognizer(longTapGesture)
        
        //tapObserver()
    }
    
    private func setUpConstraints(){
        view.addSubview(tableView)
        tableView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        tableView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor).isActive = true
        tableView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor).isActive = true
        tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        
        view.addSubview(mapView)
        mapView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        mapView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor).isActive = true
        mapView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor).isActive = true
        mapView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        
        let blurEffect = UIBlurEffect(style: .light)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(blurEffectView)
        blurEffectView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor).isActive = true
        blurEffectView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor).isActive = true
        blurEffectView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        blurEffectView.heightAnchor.constraint(equalToConstant: 70).isActive = true
        
        blurEffectView.contentView.addSubview(segmentedControl)
        segmentedControl.translatesAutoresizingMaskIntoConstraints = false
        segmentedControl.bottomAnchor.constraint(equalTo: blurEffectView.bottomAnchor, constant: -20).isActive = true
        segmentedControl.centerXAnchor.constraint(equalTo: blurEffectView.centerXAnchor).isActive = true
    }
    
//    private func setUpBlurView() {
//        let blurEffect = UIBlurEffect(style: .light)
//        let blurEffectView = UIVisualEffectView(effect: blurEffect)
//        blurEffectView.translatesAutoresizingMaskIntoConstraints = false
//        view.addSubview(blurEffectView)
//    }
    
    private func setUpSegmentedControl() {
        segmentedControl.selectedSegmentIndex = 0
        segmentedControl.addTarget(self, action:  #selector(self.segmentedValueChanged(_:)), for: .valueChanged)
    }
    
    @objc private func segmentedValueChanged(_ sender:UISegmentedControl!){
        switch segmentedControl.selectedSegmentIndex {
        case 0:
            mapView.mapType = .standard
        case 1:
            mapView.mapType = .satellite
        case 2:
            mapView.mapType = .hybrid
        default:
            break
        }
    }
    
    private func setUpTable() {
        tableView.register(TableViewCell.self, forCellReuseIdentifier: "cell")
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    private func setUpNavigation() {
        self.navigationItem.title = self.city
        self.navigationController?.view.backgroundColor = .clear
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.black]
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .organize, target: self, action: #selector(showTable))
        //addBlurEffect()
    }
    
    func addBlurEffect() {
        let bounds = self.navigationController?.navigationBar.bounds
        let visualEffectView = UIVisualEffectView(effect: UIBlurEffect(style: .light))
        visualEffectView.frame = bounds ?? CGRect.zero
        visualEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.navigationController?.navigationBar.addSubview(visualEffectView)
    }
    
    @objc private func showTable() {
        view.sendSubviewToBack(mapView)
        tableView.isHidden.toggle()
    }
    
    @objc private func infoButtonTapped() {
        let vc = EditViewController()
        vc.delegate = self
        vc.location = editLocation
        navigationController?.pushViewController(vc, animated: true)
    }
    
//    private func tapObserver() {
//        let tapGestureRecongnizer = UITapGestureRecognizer(target: self, action: #selector(executeTap))
//        tapGestureRecongnizer.delegate = self
//        view.addGestureRecognizer(tapGestureRecongnizer)
//    }

//    @objc func executeTap(tap: UITapGestureRecognizer) {
//        let point = tap.location(in: self.view)
//        let leftArea = CGRect(x: view.bounds.minX, y: view.bounds.maxY, width: view.bounds.width/2, height: view.bounds.height)
//        print(leftArea)
//        if leftArea.contains(point) {
//            print("left")
//            //changeRegion(direction: "left")
//        } else {
//            print(point)
//            print("right")
//            //changeRegion(direction: "right")
//        }
//    }
    
    func changeRegion (direction: String) {
        if places.isEmpty {return}
        
        if index < 0 {
            index = 0
        } else if index >= places.count {
            index = places.count - 1
        }
        
        if direction == "right" {
            index += 1
        }else if direction == "left"{
            index -= 1
        }
        
        print("index: \(index)")
        print("place: \(places[index].subtitle)")
        mapView.setRegion(MKCoordinateRegion(center: places[index].coordinate, span: MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)), animated: false)
        
    }
    
    func getCity(location: CLLocation, completion: @escaping (String) -> Void) {
        let geoCoder = CLGeocoder()
        
        geoCoder.reverseGeocodeLocation(location) { [weak self] (placemarks, error) in
            guard let self = self else { return }

            if let _ = error {
                //TODO: Show alert informing the user
                return
            }

            guard let placemark = placemarks?.first else {
                //TODO: Show alert informing the use
                return
            }
            guard let city = placemark.subAdministrativeArea else {return}
            completion(city)
        }
    }
    
    @objc func handleLongTappedGesture(gestureRecognizer: UILongPressGestureRecognizer) {
        if gestureRecognizer.state != UIGestureRecognizer.State.ended {
            
            let touchLocation = gestureRecognizer.location(in: mapView)
            let locationCoordinate = mapView.convert(touchLocation, toCoordinateFrom: mapView)
            
            let latitude = locationCoordinate.latitude
            let longitude = locationCoordinate.longitude
            let location = CLLocation(latitude: latitude, longitude: longitude)
           
            let pin = MKPointAnnotation()

            pin.coordinate = locationCoordinate
            
            let dialogMessage = UIAlertController(title: "Add Place", message: "Fill all the fields", preferredStyle: .alert)
            
            dialogMessage.addTextField { textField in
                textField.placeholder = self.city
                textField.text = self.city
            }
            
            dialogMessage.addTextField { textField in
                textField.placeholder = "Address"
            }
            
            let addButton = UIAlertAction(title: "Add", style: .default) { [self] (_) in
                guard let textField = dialogMessage.textFields?[1], let text = textField.text else {return}
                guard let textField = dialogMessage.textFields?[0], let city = textField.text else {return}
                pin.subtitle = text
                pin.title = city
                mapView.addAnnotation(pin)
                places.append(pin)
                tableView.reloadData()
            }
            
            dialogMessage.addAction(addButton)
            self.present(dialogMessage, animated: true, completion: nil)
        }
        
        if gestureRecognizer.state != UIGestureRecognizer.State.began {
            return
        }
    }
    
    func setUpLocationManager() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
    }
    
    func checkLocationServices() {
        if CLLocationManager.locationServicesEnabled(){
            setUpLocationManager()
            checkLocationAuthorization()
        }else {
            //show alert
        }
    }

    func checkLocationAuthorization() {
        switch CLLocationManager.authorizationStatus() {
        case .authorizedWhenInUse:
            startTackingUserLocation()
            break
        case .denied:
            break
        case .restricted:
            locationManager.requestWhenInUseAuthorization()
            break
        case .authorizedAlways:
            break
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
            break
        default:
            locationManager.requestWhenInUseAuthorization()
            break
        }
    }
    
    func getCenterLocation(for mapView: MKMapView) -> CLLocation {
        let lattitude = mapView.centerCoordinate.latitude
        let longitude = mapView.centerCoordinate.longitude
        
        return CLLocation(latitude: lattitude, longitude: longitude)
    }
    
    func startTackingUserLocation() {
        mapView.showsUserLocation = true
        locationManager.startUpdatingLocation()
        previousLocation = getCenterLocation(for: mapView)
    }
    
}

extension ViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        places.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! TableViewCell
        print(places[indexPath.row].subtitle)
        cell.cityLabel.text = places[indexPath.row].title
        cell.titleLabel.text = places[indexPath.row].subtitle
        return cell
    }
}

extension ViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        guard let location = locations.first else { return }
        
        locationManager.stopUpdatingLocation()
        let coordinates = CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
        let span = MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
        let region = MKCoordinateRegion(center: coordinates, span: span)
        
        mapView.setRegion(region, animated: true)
        
        getCity(location: CLLocation(latitude: coordinates.latitude, longitude: coordinates.longitude)) { city in
            self.city = city
        }
        
        let pin = MKPointAnnotation()
        pin.coordinate = coordinates
        pin.title = "My Location"
        
        mapView.addAnnotation(pin)
    }
    
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        checkLocationAuthorization()
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("error")
    }
}

extension ViewController: MKMapViewDelegate {
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        if annotation is MKUserLocation {return nil}

        let reuseId = "pin"
        
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId) as? MKPinAnnotationView
        if pinView == nil {
            
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView!.canShowCallout = true
            pinView!.animatesDrop = true
                
            let calloutButton = UIButton(type: .detailDisclosure)
            calloutButton.addTarget(self, action: #selector(infoButtonTapped), for: .touchUpInside)
            pinView!.rightCalloutAccessoryView = calloutButton
            pinView!.sizeToFit()
        }else {
            pinView!.annotation = annotation
        }
            
        return pinView
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        guard let location = view.annotation else { return }
        editLocation = location
    }
}

extension ViewController: EditLocationDelegate {
    func editLocation(title: String, subtitle: String) {
        if let index = places.firstIndex(of: editLocation as! MKPointAnnotation) {
            places[index].title = title
            places[index].subtitle = subtitle
            tableView.reloadData()
        }
    }
}

extension ViewController: UIGestureRecognizerDelegate {}

//delegate view for annotation, call out, bring subview to front
