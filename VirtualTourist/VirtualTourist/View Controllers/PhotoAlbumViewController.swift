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
    @IBOutlet weak var noImage: UIImageView!
    @IBOutlet weak var photoFlowLayout: UICollectionViewFlowLayout!
    
    let collectionCellID = "CollectionViewCell"
    
    private let sectionInsets = UIEdgeInsets(top: 5.0,
    left: 5.0,
    bottom: 50.0,
    right: 5.0)
    
    let actInd: UIActivityIndicatorView = UIActivityIndicatorView()
    
    var frameSize: CGSize = CGSize(width: 300.0, height: 300.0)
    
    private var blockOperation = BlockOperation()
    
    var dataController: DataController!
        
    var fetchedResultsController: NSFetchedResultsController<Photo>!
 
    var pin: Pin!
    
    //var photos: [NSManagedObject] = []
        
    //MARK: - Private Functions
        
    fileprivate func setupFetchedResultsController() {
        let fetchRequest: NSFetchRequest<Photo> = Photo.fetchRequest()
        let predicate = NSPredicate(format: "pin == %@", pin)
        fetchRequest.predicate = predicate
        
        fetchRequest.sortDescriptors = []
              
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
        print("pin's lat\(pin.latitude) and pin's long: \(pin.longitude)")
        let clLocation = CLLocation(latitude: pin.latitude, longitude: pin.longitude)
        centerMapOnLocation(clLocation , mapView: self.mapView)
        setUpPin()
        
        //Setting Collection View
        photoCollectionView.delegate = self
        photoCollectionView.dataSource = self
        //photoCollectionView.register(CollectionViewCell.self, forCellWithReuseIdentifier: "CollectionViewCell")
        
        photoFlowLayout.scrollDirection = .vertical
        self.photoCollectionView.collectionViewLayout = self.photoFlowLayout
        //photoFlowLayout.itemSize = frameSize
        
        noImage.isHidden = true
        self.showActivityIndicator(uiView: noImage)
        setupFetchedResultsController()
        
        //refactor this with activity indicator and loading images
        if (fetchedResultsController.fetchedObjects!.isEmpty == true) {
            actInd.startAnimating()
            FlickrClient.search(lat: pin!.latitude, long: pin!.longitude) { flickrPhotos, error in
                
                for photo in flickrPhotos {
                    print("this is flickr photo: \(flickrPhotos)")
                    FlickrClient.downloadPosterImage(photo: photo, completion: self.handleDownload(data:error:))
                }
                
            }
            setupFetchedResultsController()
            self.photoCollectionView.reloadData()
        }
                    
    }
        
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupFetchedResultsController()
        //self.refresh()
    }
        
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        fetchedResultsController = nil
    }
            
    /*//MARK: - IBActions
            
    private func refresh() {
        self.mapView.removeAnnotations(mapView.annotations)
        self.setUpPin()
    }*/
            
    //MARK: - Internal Class Functions
    
    //Setting up the activity Indicator programmically - storyboard won't allow overlap
    func showActivityIndicator(uiView: UIView) {
        actInd.frame = CGRect(x: 0.0, y: 0.0, width: 40.0, height: 40.0)
        actInd.center = uiView.center
        actInd.hidesWhenStopped = true
        actInd.style = UIActivityIndicatorView.Style.large
        uiView.addSubview(actInd)
    }
    
    //Retrieving Photos from Flickr
    func handleDownload(data: Data?, error: Error?) {
        if error != nil {
            print("error in downloading data from a photo")
        } else {
            if data != nil {
                //print(String(decoding: data!, as: UTF8.self ))
                let photo = Photo(context: dataController.viewContext)
                photo.imageData = data
                photo.pin = self.pin
                
                //self.photoCollectionView.reloadData()
                try? dataController.viewContext.save()
                print("one photo is saved")
                actInd.stopAnimating()
            }
        }
    }
    
    //Zoom in to display student's choosen location prior to finishing
    private func centerMapOnLocation(_ location: CLLocation, mapView: MKMapView) {
        
        let regionRadius: CLLocationDistance = 1000
        let coordinateRegion = MKCoordinateRegion(center: location.coordinate,
                                                  latitudinalMeters: regionRadius * 2.0, longitudinalMeters: regionRadius * 2.0)
        mapView.setRegion(coordinateRegion, animated: true)
        
    }
            
    private func setUpPin() {
                
        var annotations = [MKPointAnnotation]()
            
        //MARK: Using CoreData to populate map with the pin
                    
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
    // Return the number of sections in the collection view
    /*func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        print("scetion:\(section)")
        return fetchedResultsController.sections?.count ?? 1
    }*/
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return fetchedResultsController.sections?.count ?? 1
    }
    
    //Provides the number of object per section(s)
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let sectionInfo = self.fetchedResultsController.sections![section]
        print("sectionInfo.numberOfObjects\(sectionInfo.numberOfObjects)and sectionInfo: \(self.fetchedResultsController.sections!)")
        (sectionInfo.numberOfObjects == 0 ? (noImage.isHidden = false) : (noImage.isHidden = true) )
        return sectionInfo.numberOfObjects
    }

    // Populate the cells
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
       // Fetch a cell of the appropriate type.
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: collectionCellID , for: indexPath) as! CollectionViewCell
        print("indexPath:\(indexPath)")
        //cell.sizeThatFits(frameSize)
        
        if fetchedResultsController.fetchedObjects != nil {
            let cellPhoto = fetchedResultsController.object(at: indexPath)
            // Configure the cell’s contents.
            configureUI(cell: cell, photo: cellPhoto, atIndexPath: indexPath)
        } else { print("fetchedObjects = nil") }
        
       return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let objectToDelete = fetchedResultsController.object(at: indexPath)
        dataController.viewContext.delete(objectToDelete)
        try? dataController.viewContext.save()
    }
    
    func configureUI(cell: CollectionViewCell, photo: Photo, atIndexPath indexPath: IndexPath) {
        
        if photo.imageData != nil{
            noImage.isHidden = true
            cell.albumPhoto.image = UIImage(data: Data(referencing: photo.imageData! as NSData))
            print("Image.image \(photo.imageData!)")
        }else{
            print("photo is nil")
            //noImage.isHidden = false
        }
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
        
        //photoCollectionView.beginInteractiveMovementForItem(at: indexPath!)
        
        switch type {
            case .insert:
                guard let newIndexPath = newIndexPath else {break}
                photoCollectionView.insertItems(at: [newIndexPath])
            case .delete:
                guard let indexPath = indexPath else {break}
                photoCollectionView.deleteItems(at: [indexPath])
                break
            case .update:
                guard let indexPath = indexPath else {break}
                photoCollectionView.reloadItems(at: [indexPath])
                break
            case .move:
                guard let newIndexPath = newIndexPath else {break}
                photoCollectionView.moveItem(at: indexPath!, to: newIndexPath)
                break
        
            @unknown default:
                fatalError("Invalid change type in controller(_:didChange:atSectionIndex:for:). Only .insert/delete/move/update should be possible.")
        }
        
    }
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        blockOperation = BlockOperation()
        
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        photoCollectionView?.performBatchUpdates({self.blockOperation.start()}, completion: nil)
    }
}

// MARK: - Collection View Flow Layout Delegate
extension PhotoAlbumViewController : UICollectionViewDelegateFlowLayout {
  
  func collectionView(_ collectionView: UICollectionView,
                      layout collectionViewLayout: UICollectionViewLayout,
                      sizeForItemAt indexPath: IndexPath) -> CGSize {

    let itemsPerRow: CGFloat = UIScreen.main.bounds.width > UIScreen.main.bounds.height ? 5.0 : 3.0
    let paddingSpace = sectionInsets.left * (itemsPerRow + 1)
    let availableWidth = UIScreen.main.bounds.width - paddingSpace
    let widthPerItem = availableWidth / itemsPerRow
    
    frameSize = CGSize(width: widthPerItem, height: widthPerItem)
    
    return frameSize
  }
  
  
  func collectionView(_ collectionView: UICollectionView,
                      layout collectionViewLayout: UICollectionViewLayout,
                      insetForSectionAt section: Int) -> UIEdgeInsets {
    return sectionInsets
  }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        
        return sectionInsets.left
    }
  
  
  func collectionView(_ collectionView: UICollectionView,
                      layout collectionViewLayout: UICollectionViewLayout,
                      minimumLineSpacingForSectionAt section: Int) -> CGFloat {
    return sectionInsets.left
  }
    
}



