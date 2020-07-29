//
//  TravelLocationsMapViewController.swift
//  VirtualTourist
//
//  Created by Chantal Deguire on 2020-07-23.
//  Copyright © 2020 Udacity. All rights reserved.
//

import UIKit
import MapKit
import CoreData

class TravelLocationsMapViewController: UIViewController {

    @IBOutlet weak var mapView: MKMapView!
    
    
    //MARK: - Variables
    fileprivate let locationManager: CLLocationManager = {
        let manager = CLLocationManager()
        manager.requestWhenInUseAuthorization()
        return manager
    }()
    
    var dataController: DataController!
    
    var pins: [NSManagedObject] = []
    
//MARK: - View Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
            
        setUpMapView()
        
        // Instantiate a long press gesture to the map
        let uiLPGR = UILongPressGestureRecognizer(target: self, action: #selector(addPin(longGesture:)))
        self.mapView.addGestureRecognizer(uiLPGR)
            
        fetchPins()
                
    }
        
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.refresh()
    }
        
    //MARK: - IBActions
        
    private func refresh() {
        self.mapView.removeAnnotations(mapView.annotations)
        self.setUpPins()
    }
        
    //MARK: - Internal Class Functions
    
    //MARK: Setup Methods
    private func setUpMapView() {
        //Set MapView's delegate and properties
        
        self.mapView.delegate = self
        self.mapView.isZoomEnabled = true
        self.mapView.isScrollEnabled = true
        title = "Travel Locations Map"
        
        //mapView.showsUserLocation = true
        mapView.showsCompass = true
        mapView.showsScale = true
        currentLocation()
    }
    
    private func currentLocation() {
       locationManager.delegate = self
       locationManager.desiredAccuracy = kCLLocationAccuracyBest
       if #available(iOS 11.0, *) {
          locationManager.showsBackgroundLocationIndicator = true
       } else {
          // Fallback on earlier versions
       }
       locationManager.startUpdatingLocation()
    }
        
    private func setUpPins() {
            
        var annotations = [MKPointAnnotation]()
        
        //MARK: using CoreData to populate map with pins
        for dictionary in pins {
                
            let lat = CLLocationDegrees((dictionary.value(forKeyPath: "latitude") as? Double) ?? 0.0 )
            let long = CLLocationDegrees((dictionary.value(forKeyPath: "longitude") as? Double) ?? 0.0 )
                
            // The lat and long are used to create a CLLocationCoordinates2D instance.
            let coordinate = CLLocationCoordinate2D(latitude: lat, longitude: long)
                
            // Creating the annotation and setting its coordiate, title, and subtitle properties
            let annotation = MKPointAnnotation()
            annotation.coordinate = coordinate
                
            // Adding the annotation in an array of annotations.
            annotations.append(annotation)
                
        }
            
        // When the array is complete, we add the annotations to the map.
        self.mapView.addAnnotations(annotations)
    }
    
    fileprivate func fetchPins() {
        //Fetching Pins from CoreData persistent store
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Pin")
        do {
            pins = try dataController.viewContext.fetch(fetchRequest)
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
    }
    
    @objc func addPin(longGesture: UIGestureRecognizer) {
        
        if longGesture.state == .began {
        let touchedPoint = longGesture.location(in: mapView)
        let newCoords = mapView.convert(touchedPoint, toCoordinateFrom: mapView)
        let pressedLocation = CLLocation(latitude: newCoords.latitude, longitude: newCoords.longitude)
        
        let newPin = Pin(context: dataController.viewContext)
        newPin.latitude = pressedLocation.coordinate.latitude
        newPin.longitude = pressedLocation.coordinate.longitude
        try? dataController.viewContext.save()
        
        self.fetchPins()
        self.refresh()
        }
        
    }

// MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        // If this is a NotesListViewController, we'll configure its `Notebook`
        if let vc = segue.destination as? PhotoAlbumViewController {
            guard let passedPin = sender as? Pin else {
                return
            }
            vc.pin = passedPin 
            vc.dataController = dataController
        }
    }
}

 // MARK: - MKMapViewDelegate Funtions (required)

extension TravelLocationsMapViewController: MKMapViewDelegate {

    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        let reuseId = "pin"
        
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId) as? MKPinAnnotationView

        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView!.canShowCallout = true
            pinView!.pinTintColor = .red
            pinView!.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
        }
        else {
            pinView!.annotation = annotation
        }
        
        return pinView
    }
    
    /*
    //MARK: - TODO: (this should work in reverse. add to Pin first and then populate) Adds new 'pin'(s) as NSManagedObject 'Pin'
    func mapView(_ mapView: MKMapView, didAdd views: [MKAnnotationView]) {
        print("User is adding a pin here")
        for addedPin in views {
            let newPin = Pin(context: dataController.viewContext)
            newPin.latitude = addedPin.annotation?.coordinate.latitude ?? 0.0
            newPin.longitude = addedPin.annotation?.coordinate.longitude ?? 0.0
            try? dataController.viewContext.save()
        }
    }*/
    
    //User tapped on the pin
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        
        guard let annotation = view.annotation else {
            return
        }
        let thisCoordinate = annotation.coordinate
        mapView.deselectAnnotation(annotation, animated: true)
        
        for pin in pins as! [Pin] {
            if pin.latitude == thisCoordinate.latitude && pin.longitude == thisCoordinate.longitude {
                performSegue(withIdentifier: "PhotoAlbum", sender: pin) //Sending the Pin through segue!
            }
        }
    
    }
}

extension TravelLocationsMapViewController: CLLocationManagerDelegate {
   func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
      
      let location = locations.last! as CLLocation
      let currentLocation = location.coordinate
      let coordinateRegion = MKCoordinateRegion(center: currentLocation, latitudinalMeters: 100000, longitudinalMeters: 100000)
      mapView.setRegion(coordinateRegion, animated: true)
      locationManager.stopUpdatingLocation()
   }
   func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
      print(error.localizedDescription)
   }
}




