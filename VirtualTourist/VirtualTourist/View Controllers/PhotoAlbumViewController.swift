//
//  PhotoAlbumViewController.swift
//  VirtualTourist
//
//  Created by Chantal Deguire on 2020-07-23.
//  Copyright © 2020 Udacity. All rights reserved.
//

import UIKit
import MapKit
import CoreData

class PhotoAlbumViewController: UIViewController,  UICollectionViewDelegate, UICollectionViewDataSource {
    
    //outlet for map here
    //outlet for colection view
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var photoCollectionView: UICollectionView!
    
    
    let collectionCellID = "CollectionViewCell"
    
    var dataController: DataController!
        
    var fetchedResultsController: NSFetchedResultsController<Photo>!
 
    var pin: Pin!
    
    var photos: [NSManagedObject] = []
        
    //MARK: - Private Functions
        
    fileprivate func setupFetchedResultsController() {
        let fetchRequest: NSFetchRequest<Photo> = Photo.fetchRequest()
              
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: dataController.viewContext, sectionNameKeyPath: nil, cacheName: "photos")
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
                
        print("view did load")
        //Set MapView's delegate and properties
        self.mapView.delegate = self
        self.mapView.isZoomEnabled = false
        self.mapView.isScrollEnabled = false
        
        //Setting pin on map
        let clLocation = CLLocation(latitude: pin.latitude, longitude: pin.longitude)
        centerMapOnLocation(clLocation , mapView: self.mapView)
        setUpPin()
        //setupFetchedResultsController()
                    
    }
        
    /*
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupFetchedResultsController()
        self.refresh()
    }*/
        
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        //fetchedResultsController = nil
    }
            
    //MARK: - IBActions
            
    private func refresh() {
        self.mapView.removeAnnotations(mapView.annotations)
        self.setUpPin()
    }
            
    //MARK: - Internal Class Functions
    
    //Zoom in to display student's choosen location prior to finishing
    private func centerMapOnLocation(_ location: CLLocation, mapView: MKMapView) {
        
        let regionRadius: CLLocationDistance = 1000
        let coordinateRegion = MKCoordinateRegion(center: location.coordinate,
                                                  latitudinalMeters: regionRadius * 2.0, longitudinalMeters: regionRadius * 2.0)
        mapView.setRegion(coordinateRegion, animated: true)
        
    }
            
    private func setUpPin() {
                
        var annotations = [MKPointAnnotation]()
            
        //MARK: - Using CoreData to populate map with the pin
                    
        let lat = CLLocationDegrees((pin.value(forKeyPath: "latitude") as? Double) ?? 0.0 )
        let long = CLLocationDegrees((pin.value(forKeyPath: "longitude") as? Double) ?? 0.0 )
                    
        // The lat and long are used to create a CLLocationCoordinates2D instance.
        let coordinate = CLLocationCoordinate2D(latitude: lat, longitude: long)
                    
        // Creating the annotation and setting its coordiate, title, and subtitle properties
        let annotation = MKPointAnnotation()
        annotation.coordinate = coordinate
                    
        // Adding the annotation in an array of annotations.
        annotations.append(annotation)
                    
                
        // When the array is complete, we add the annotations to the map.
        self.mapView.addAnnotations(annotations)
    }

    // MARK: - Navigation

    /*
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    
        if let vc = segue.destination as? TravelLocationsMapViewController {
            
                vc.dataController = dataController
    
        }
    }*/
    
    //MARK: - Required functions for collection view Delegate
    //MARK: - TO DO: Make it an extension
    // Return the number of rows for the table.
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 1    }

    // Provide a cell object for each row.
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
       // Fetch a cell of the appropriate type.
       let cell = collectionView.dequeueReusableCell(withReuseIdentifier: collectionCellID , for: indexPath) as! CollectionViewCell
        print(indexPath)
       
       // Configure the cell’s contents.
       //cell.collectionView.albumPhoto = self.memes[indexPath.row].originalImage
        
       return cell
    }
}


// MARK: - MKMapViewDelegate Funtions (required)

extension PhotoAlbumViewController: MKMapViewDelegate {

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
}

//MARK: - NSFetchedResults Delegate (required?)

extension PhotoAlbumViewController: NSFetchedResultsControllerDelegate {
        
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        
    }
        
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        //beginINteractionMovement....
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        //endInteractionMovement
    }
}

