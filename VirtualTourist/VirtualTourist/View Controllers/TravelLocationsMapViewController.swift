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
    
    var dataController: DataController!
    
    var fetchedResultsController: NSFetchedResultsController<Pin>!
    
    
    
//MARK: - View Life Cycle
        
    override func viewDidLoad() {
        super.viewDidLoad()
            
        //Set MapView's delegate and properties
        self.mapView.delegate = self
        self.mapView.isZoomEnabled = true
        self.mapView.isScrollEnabled = true
            
        //Retrieving Pin Locations
                
    }
        
    override func viewWillAppear(_ animated: Bool) {
        self.refresh()
    }
        
    //MARK: - IBActions
        
    private func refresh() {
        self.mapView.removeAnnotations(mapView.annotations)
        self.setUpPins()
    }
        
    //MARK: - Internal Class Functions
        
    private func setUpPins() {
            
        var annotations = [MKPointAnnotation]()
        
        //MARK: - TO DO: use CoreData to populate map with pins
        for dictionary in VirtualTourist.studentLocations {
                
            let lat = CLLocationDegrees(dictionary.latitude ?? 0.0 )
            let long = CLLocationDegrees(dictionary.longitude ?? 0.0 )
                
            // The lat and long are used to create a CLLocationCoordinates2D instance.
            let coordinate = CLLocationCoordinate2D(latitude: lat, longitude: long)
                
            let first = dictionary.firstName
            let last = dictionary.lastName
            let mediaURL = dictionary.mediaURL
                
            // Creating the annotation and setting its coordiate, title, and subtitle properties
            let annotation = MKPointAnnotation()
            annotation.coordinate = coordinate
            annotation.title = "\(first) \(last)"
            annotation.subtitle = mediaURL
                
            // Adding the annotation in an array of annotations.
            annotations.append(annotation)
                
        }
            
        // When the array is complete, we add the annotations to the map.
        self.mapView.addAnnotations(annotations)
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

    
    // This delegate method is implemented to respond to taps. It opens the system browser
    // to the URL specified in the annotationViews subtitle property.
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        if control == view.rightCalloutAccessoryView {
            if let mediaURL = view.annotation?.subtitle! {
                if mediaURL.contains("https"){
                    if let mediaURL = URL(string: mediaURL){
                        UIApplication.shared.open(mediaURL, options: [:], completionHandler: nil)
                    }
                } else {
                    ErrorAlertView.showMessage(title: "Incorrect URL Format", msg: "Media contains a wrong URL format", on: self)
                }
            }
        }
    }
}



