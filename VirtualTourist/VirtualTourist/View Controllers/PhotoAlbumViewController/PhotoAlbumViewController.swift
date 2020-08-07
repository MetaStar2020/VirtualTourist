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

class PhotoAlbumViewController: UIViewController {
    
    // MARK: - Outlets
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var photoCollectionView: UICollectionView!
    @IBOutlet weak var noImage: UIImageView!
    @IBOutlet weak var photoFlowLayout: UICollectionViewFlowLayout!
    @IBOutlet weak var newCollectionButton: UIButton!
    
    // MARK: - Properties: Variables and Constants
    
    let collectionCellID = "CollectionViewCell"
    
    let sectionInsets = UIEdgeInsets(top: 5.0,
    left: 5.0,
    bottom: 50.0,
    right: 5.0)
    
    let itemsPerRowPortrait: CGFloat = 5.0
    let itemsPerRowLandscape: CGFloat = 6.0
    
    let actInd: UIActivityIndicatorView = UIActivityIndicatorView()
    
    var frameSize: CGSize = CGSize(width: 300.0, height: 300.0)
    
    var blockOperation = BlockOperation()
    
    var dataController: DataController!
        
    var fetchedResultsController: NSFetchedResultsController<Photo>!
 
    var pin: Pin!
    
    var photoURLs: [URL?] = []
    
    //MARK: - Fileprivate Functions
    
    fileprivate func setUpMap() {
        //Set MapView's delegate and properties
        self.mapView.delegate = self
        self.mapView.isZoomEnabled = false
        self.mapView.isScrollEnabled = false
        
        //Setting pin on map
        print("pin's lat\(pin.latitude) and pin's long: \(pin.longitude)")
        let clLocation = CLLocation(latitude: pin.latitude, longitude: pin.longitude)
        centerMapOnLocation(clLocation , mapView: self.mapView)
        setUpPin()
    }
    
    fileprivate func setUpGesture() {
        //Setting Gesture
        let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(self.handleLongGesture(gesture:)))
        longPressGesture.minimumPressDuration = 0.5
        longPressGesture.delegate = self
        longPressGesture.delaysTouchesBegan = true
        photoCollectionView.addGestureRecognizer(longPressGesture)
    }
    
    fileprivate func setUpCollection() {
        //Setting Collection View
        photoCollectionView.delegate = self
        photoCollectionView.dataSource = self
        
        photoFlowLayout.scrollDirection = .vertical
        self.photoCollectionView.collectionViewLayout = self.photoFlowLayout
    }
    
    fileprivate func showActivityIndicator(uiView: UIView) {
        let container: UIView = UIView()
        container.frame = CGRect(x: 0, y: 0, width: 80, height: 80) // Set X and Y whatever you want
        container.backgroundColor = .clear
        actInd.style = UIActivityIndicatorView.Style.large
        actInd.center = self.view.center
        container.addSubview(actInd)
        self.view.addSubview(container)
    }
    
    fileprivate func fetchFlickrPhotoURLs() {
        actInd.startAnimating()
        newCollectionButton.isEnabled = false
        FlickrClient.search(lat: pin!.latitude, long: pin!.longitude) { flickrPhotos, error in
            
            if error == nil {
                var i: Int = 0
                
                for photoURL in flickrPhotos {
                    
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
                self.noImage.isHidden = true
                i = 0
            }
            
        }
        setupFetchedResultsController()
        self.photoCollectionView.reloadData()
        actInd.stopAnimating()
        newCollectionButton.isEnabled = true
    }
            
    //MARK: - View Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
            
        //Set up UIs
        setUpMap()
        setUpGesture()
        setUpCollection()
        showActivityIndicator(uiView: noImage)
        setupFetchedResultsController()
        
        //Fetching the image urls from Flickr
        if (fetchedResultsController.fetchedObjects!.isEmpty == true) {
            print("FRC is empty")
            fetchFlickrPhotoURLs()
        }
                    
    }
        
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        setupFetchedResultsController()
        
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
        
            if let  objects = self.fetchedResultsController.fetchedObjects {
                
                let photosToHide = self.photoCollectionView.indexPathsForVisibleItems
            
                for photoToHide in photosToHide {
                    self.photoCollectionView.cellForItem(at: photoToHide)!.isHidden = true
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
            self.fetchFlickrPhotoURLs()
        }
     
            
    //MARK: - Internal Class Functions
    
    func setupFetchedResultsController() {
        actInd.startAnimating()
        let fetchRequest: NSFetchRequest<Photo> = Photo.fetchRequest()
        let predicate = NSPredicate(format: "pin == %@", pin)
        
        fetchRequest.predicate = predicate
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "photoOrder", ascending: true)]

        fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: dataController.viewContext, sectionNameKeyPath: nil, cacheName: nil)
        fetchedResultsController.delegate = self
        do {
            try fetchedResultsController.performFetch()
        } catch {
            fatalError("The fetch could not be performed: \(error.localizedDescription)")
        }
        actInd.stopAnimating()
    }
    
    //Retrieving Photos from Flickr ** need to be removed!
    func handleDownload(data: Data?, error: Error?) {
        if error != nil {
            print("error in downloading data from a photo")
        } else {
            if data != nil {
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
}


extension PhotoAlbumViewController: UIGestureRecognizerDelegate {
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive press: UIPress) -> Bool {
        return true
    }
}



