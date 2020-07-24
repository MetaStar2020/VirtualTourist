//
//  PhotoAlbumViewController.swift
//  VirtualTourist
//
//  Created by Chantal Deguire on 2020-07-23.
//  Copyright © 2020 Udacity. All rights reserved.
//

import UIKit

class PhotoAlbumViewController: UIViewController { /*
    
    //outlet for map here
    //outlet for colection view
*/
    var dataController: DataController!
        
    //var fetchedResultsController: NSFetchedResultsController<Photo>!
 
    var pin: Pin!
    /*
    var photos: [NSManagedObject] = []
        
    //MARK: - Private Functions
        
    fileprivate func setupFetchedResultsController() {
        let fetchRequest: NSFetchRequest<Photo> = Photo.fetchRequest()
              
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: dataController.viewContext, sectionNameKeyPath: nil, cacheName: "pins")
        fetchedResultsController.delegate = self
        do {
            try fetchedResultsController.performFetch()
        } catch {
            fatalError("The fetch could not be performed: \(error.localizedDescription)")
        }
    }
        
    //MARK: - View Life Cycle
            
    override func viewDidLoad() {
        super.viewDidLoad()
                
        //Set MapView's delegate and properties
        self.mapView.delegate = self
        self.mapView.isZoomEnabled = true
        self.mapView.isScrollEnabled = true
        title = "Im here!"
                
        //Retrieving Pin Locations
        setupFetchedResultsController()
                    
    }
            
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupFetchedResultsController()
        self.refresh()
    }
        
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        fetchedResultsController = nil
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
            if let indexPath = tableView.indexPathForSelectedRow {
                vc.notebook = fetchedResultsController.object(at: indexPath)
                vc.dataController = dataController
            }
        }
    }*/
}

/*
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

//MARK: - NSFetchedResults Delegate (required?)

extension TravelLocationsMapViewController: NSFetchedResultsControllerDelegate {
        
    // Not sure if its necessary in this case? Do I need to fetch/add to the map everytime there is a change? -- like a refresh to make sure pins are added after saved?
}
*/
