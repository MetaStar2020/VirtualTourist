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
    
    var pins: [NSManagedObject] = []
    
    
//MARK: - View Life Cycle
        
    override func viewDidLoad() {
        super.viewDidLoad()
            
        //Set MapView's delegate and properties
        self.mapView.delegate = self
        self.mapView.isZoomEnabled = true
        self.mapView.isScrollEnabled = true
        title = "Im here!"
            
        //Fetching Pins from CoreData persistent store
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Pin")
        do {
            pins = try dataController.viewContext.fetch(fetchRequest)
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
                
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
        
    private func setUpPins() {
            
        var annotations = [MKPointAnnotation]()
        
        //MARK: - TO DO: use CoreData to populate map with pins
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

// MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // If this is a NotesListViewController, we'll configure its `Notebook`
        if let vc = segue.destination as? PhotoAlbumViewController {
                //vc.pin = fetchedResultsController.object(at: indexPath)
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
    
    func mapView(_ mapView: MKMapView, didAdd views: [MKAnnotationView]) {
        print("User is adding a pin here")
    }
    
    // This delegate method is implemented to respond to taps. It opens the system browser
    // to the URL specified in the annotationViews subtitle property.
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        if control == view.rightCalloutAccessoryView {
            performSegue(withIdentifier: "PhotoAlbum", sender: self)
        }
    }
}

//MARK: - NSFetchedResults Delegate (required?)

extension TravelLocationsMapViewController: NSFetchedResultsControllerDelegate {
    
    // Not sure if its necessary in this case? Do I need to fetch/add to the map everytime there is a change? -- like a refresh to make sure pins are added after saved?
}



