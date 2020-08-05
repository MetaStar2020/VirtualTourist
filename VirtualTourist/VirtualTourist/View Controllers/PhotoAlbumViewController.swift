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
    @IBOutlet weak var newCollectionButton: UIButton!
    
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
    
    var photoURLs: [URL?] = []
    
    //var photos: [NSManagedObject] = []
        
    //MARK: - Private Functions
        
    fileprivate func setupFetchedResultsController() {
        let fetchRequest: NSFetchRequest<Photo> = Photo.fetchRequest()
        let predicate = NSPredicate(format: "pin == %@", pin)
        fetchRequest.predicate = predicate
        
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "photoOrder", ascending: true)]
              
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: dataController.viewContext, sectionNameKeyPath: nil, cacheName: "photos")
        fetchedResultsController.delegate = self
        do {
            try fetchedResultsController.performFetch()
        } catch {
            fatalError("The fetch could not be performed: \(error.localizedDescription)")
        }
    }
    
        
    //MARK: - View Life Cycle
            
    fileprivate func fetchFlickrPhotoURLs() {
        actInd.startAnimating()
        newCollectionButton.isEnabled = false
        FlickrClient.search(lat: pin!.latitude, long: pin!.longitude) { flickrPhotos, error in
            
            if error == nil {
                var i: Int = 0
                self.noImage.isHidden = true
                
                for photoURL in flickrPhotos {
                    print("this is flickr photo: \(flickrPhotos)")
                    self.photoURLs.append(FlickrClient.photoPathURL(photo: photoURL))
                
                    //Create a Photo ManagedObject and assign its order in sync with array
                    let photo = Photo(context: self.dataController.viewContext)
                        photo.photoOrder = Int16(i)
                        photo.pin = self.pin
                
                        try? self.dataController.viewContext.save()
                        self.photoCollectionView.reloadData()
                        //FlickrClient.downloadPosterImage(photo: photo, completion: self.handleDownload(data:error:))
                    i += 1
                }
                i = 0
            }
            
        }
        setupFetchedResultsController()
        self.photoCollectionView.reloadData()
        actInd.stopAnimating()
        newCollectionButton.isEnabled = true
    }
    
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
        
        //Setting Gesture
        let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(self.handleLongGesture(gesture:)))
        longPressGesture.minimumPressDuration = 0.5
        longPressGesture.delegate = self
        longPressGesture.delaysTouchesBegan = true
        photoCollectionView.addGestureRecognizer(longPressGesture)
        
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
            print("FRC is empty")
            fetchFlickrPhotoURLs()
        }
                    
    }
        
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        setupFetchedResultsController()
        //self.refresh()
    }
    
    @objc func handleLongGesture(gesture: UILongPressGestureRecognizer) {
        switch(gesture.state) {
        case .began:
            guard let selectedIndexPath = photoCollectionView.indexPathForItem(at: gesture.location(in: photoCollectionView)) else {
                break
            }
            photoCollectionView.beginInteractiveMovementForItem(at: selectedIndexPath)
        case .changed:
            photoCollectionView.updateInteractiveMovementTargetPosition(gesture.location(in: gesture.view!))
        case .ended:
            photoCollectionView.endInteractiveMovement()
        default:
            photoCollectionView.cancelInteractiveMovement()
        }
    }
        
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        fetchedResultsController = nil
    }
            
    //MARK: - IBActions
     
     @IBAction func fetchNewCollection(_ sender: UIButton) {
        
        /*
        let deleteCollection = NSBatchDeleteRequest(fetchRequest: fetchedResultsController!.fetchRequest as! NSFetchRequest<NSFetchRequestResult>)
        try? dataController.viewContext.execute(deleteCollection)
        */
       
            if let  objects = self.fetchedResultsController.fetchedObjects {
                //MARK: - TODO: trying to hide the cells temporarily might need to review BlockOperation and how to cell.contentView.isHidden until the batch is complete. this way we can see the activity indicator.
                let photosToDelete = self.photoCollectionView.indexPathsForVisibleItems
            
                //photoCollectionView.deleteItems(at: photosToDelete)
            
                for photoToDelete in photosToDelete {
                    self.photoCollectionView.cellForItem(at: photoToDelete)!.isHidden = true
                }
            
                self.actInd.startAnimating()
                for object in objects{
                    self.dataController.viewContext.performAndWait {
                        self.dataController.viewContext.delete(object)
                        try? self.dataController.viewContext.save()
                    }
                }
            }
            self.photoCollectionView.reloadData()
            self.photoCollectionView!.numberOfItems(inSection: 0)
            self.dataController.viewContext.refreshAllObjects()
            try? self.dataController.viewContext.save()
            print("Now going to fetch new photos")
            self.fetchFlickrPhotoURLs()
        }
     
            
    //MARK: - Internal Class Functions
    
    //Setting up the activity Indicator programmically - storyboard won't allow overlap
    func showActivityIndicator(uiView: UIView) {
        actInd.frame = CGRect(x: 0.0, y: 0.0, width: 40.0, height: 40.0)
        actInd.center = uiView.center
        actInd.hidesWhenStopped = true
        actInd.style = UIActivityIndicatorView.Style.large
        uiView.superview!.addSubview(actInd)
    }
    
    //Retrieving Photos from Flickr ** need to be removed!
    func handleDownload(data: Data?, error: Error?) {
        if error != nil {
            print("error in downloading data from a photo")
        } else {
            if data != nil {
                //print(String(decoding: data!, as: UTF8.self ))
                //let photo = Photo(context: dataController.viewContext)
                //fetchedResultsController.object(at: <#T##IndexPath#>).imageData = data
                //photo.pin = self.pin
                
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
    
    func collectionView(_ collectionView: UICollectionView, canMoveItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func collectionView(_ collectionView: UICollectionView, moveItemAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        //MARK: - TODO: Need to add a sort descriptor that would arrange/rearrange order
        
        //dataController.viewContext.delete(objectToMove)
        if sourceIndexPath.row < destinationIndexPath.row {
            
            for i in sourceIndexPath.row+1...destinationIndexPath.row {
                fetchedResultsController.object(at: [0,i]).photoOrder -= 1
            }
            fetchedResultsController.object(at: sourceIndexPath).photoOrder = Int16(destinationIndexPath.row)
        } else {
            
            for i in sourceIndexPath.row-1...destinationIndexPath.row {
                fetchedResultsController.object(at: [0,i]).photoOrder += 1
            }
            fetchedResultsController.object(at: sourceIndexPath).photoOrder = Int16(destinationIndexPath.row)
        }

        //remove and insert in array
        let temp = photoURLs[sourceIndexPath.row]
        photoURLs.remove(at: sourceIndexPath.row)
        photoURLs.insert(temp, at: destinationIndexPath.row)
        
        
        //fetchedResultsController.fetchedObjects?.insert(objectToMove, at: destinationIndexPath)
        try? dataController.viewContext.save()
        //photoCollectionView.moveItem(at: sourceIndexPath, to: destinationIndexPath)
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
        print("cell indexPath:\(indexPath)")
        //cell.sizeThatFits(frameSize)
        
        
        if let cellPhotoData = self.fetchedResultsController.object(at: indexPath).imageData {
            cell.albumPhoto.image = UIImage(data: cellPhotoData)
        //Downloading the Images from URLs
        } else if  photoURLs.count != 0 {
            
            if let url = photoURLs[indexPath.row] {
                cell.cellActivityIndicator.startAnimating()
                cell.albumPhoto.image = UIImage(named: "noImage")
                //DispatchQueue.global().async {
                    FlickrClient.downloadPosterImage(photoURL: url) { data, error in
                        if error != nil {
                            print("error in downloading data from a photo")
                        } else {
                            if data != nil {
                                //print(String(decoding: data!, as: UTF8.self ))
                                //let photo = Photo(context: dataController.viewContext)
                                let cellPhoto = self.fetchedResultsController.object(at: indexPath)
                                cellPhoto.imageData = data
                                print("Image.image \(cellPhoto.imageData!)")
                                try? self.dataController.viewContext.save()
                                cell.albumPhoto.image = UIImage(data: data!)
                                //self.configureUI(cell: cell, photo: cellPhoto, atIndexPath: indexPath)
                                //photo.pin = self.pin
                    
                                //self.photoCollectionView.reloadData()
                                //try? self.dataController.viewContext.save()
                                print("one photo is saved")
                                cell.cellActivityIndicator.stopAnimating()
                                //self.actInd.stopAnimating()
                            }
                        }
                    }
                //}
            }
        } else {
            cell.albumPhoto.image = UIImage(named: "noImage")
        }
        
        
        
        
        /*if fetchedResultsController.fetchedObjects != nil {
            let cellPhoto = fetchedResultsController.object(at: indexPath)
            // Configure the cell’s contents.
            configureUI(cell: cell, photo: cellPhoto, atIndexPath: indexPath)
        } else {
            print("fetchedObjects = nil")
            cell.albumPhoto.image = UIImage(named: "noImage")
        }*/
        
        //***might not be the right place to stopAnimating
       return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let objectToDelete = fetchedResultsController.object(at: indexPath)
        dataController.viewContext.delete(objectToDelete)
        try? dataController.viewContext.save()
    }
    
    //***Might need to remove
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
                blockOperation.addExecutionBlock {
                    self.photoCollectionView.insertItems(at: [newIndexPath])
                }
            case .delete:
                guard let indexPath = indexPath else {break}
                blockOperation.addExecutionBlock {
                    self.photoCollectionView.deleteItems(at: [indexPath])
                }
            case .update:
                guard let indexPath = indexPath else {break}
                blockOperation.addExecutionBlock {
                    self.photoCollectionView.reloadItems(at: [indexPath])
                }
            case .move:
                guard let newIndexPath = newIndexPath else {break}
                blockOperation.addExecutionBlock {
                    self.photoCollectionView.moveItem(at: indexPath!, to: newIndexPath)
                }
        
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

    let itemsPerRow: CGFloat = UIScreen.main.bounds.width > UIScreen.main.bounds.height ? 5.0 : 5.0 //I need to resolve for 3.0 for portrait
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

extension PhotoAlbumViewController: UIGestureRecognizerDelegate {
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive press: UIPress) -> Bool {
        return true
    }
}



