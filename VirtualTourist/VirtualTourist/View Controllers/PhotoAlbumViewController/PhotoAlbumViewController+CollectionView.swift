//
//  PhotoAlbumViewController+CollectionView.swift
//  VirtualTourist
//
//  Created by Chantal Deguire on 2020-08-07.
//  Copyright © 2020 Udacity. All rights reserved.
//

import Foundation
import UIKit


extension PhotoAlbumViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return fetchedResultsController.sections?.count ?? 1
    }
    
    func collectionView(_ collectionView: UICollectionView, canMoveItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func collectionView(_ collectionView: UICollectionView, moveItemAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
     
        if sourceIndexPath.item < destinationIndexPath.item {
            
            for i in sourceIndexPath.item+1...destinationIndexPath.item {
                self.fetchedResultsController.object(at: IndexPath(item: i, section: 0)).photoOrder -= 1
            }
            self.fetchedResultsController.object(at: sourceIndexPath).photoOrder = Int16(destinationIndexPath.item+1)
        } else {
            
            for i in (destinationIndexPath.item...sourceIndexPath.item-1).reversed() {
                self.fetchedResultsController.object(at: IndexPath(item: i, section: 0)).photoOrder += 1
                
            }
            self.fetchedResultsController.object(at: sourceIndexPath).photoOrder = Int16(destinationIndexPath.item+1)
        }

        //remove and insert in array in case if images are still downloading.
            if self.photoURLs.count != 0 {
                let temp = self.photoURLs[sourceIndexPath.item]
                self.photoURLs.remove(at: sourceIndexPath.item)
                self.photoURLs.insert(temp, at: destinationIndexPath.item)
        }
        
            try? self.dataController.viewContext.save()
        self.setupFetchedResultsController()
        
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
        
        if let cellPhotoData = self.fetchedResultsController.object(at: indexPath).imageData {
            print("adding a photo in the album")
            cell.albumPhoto.image = UIImage(data: cellPhotoData)
        //Downloading the Images from URLs
        } else if  photoURLs.count != 0 {
            if let url = photoURLs[indexPath.row] {
                cell.cellActivityIndicator.startAnimating()
                FlickrClient.downloadPosterImage(photoURL: url) { data, error in
                if error != nil {
                    print("error in downloading data from a photo")
                } else {
                    if data != nil {
                        let cellPhoto = self.fetchedResultsController.object(at: indexPath)
                        cellPhoto.imageData = data
                        try? self.dataController.viewContext.save()
                        cell.albumPhoto.image = UIImage(data: data!)
                        cell.cellActivityIndicator.stopAnimating()
                        }
                    }
                }
            }
        }
       return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let objectToDelete = fetchedResultsController.object(at: indexPath)
        dataController.viewContext.delete(objectToDelete)
        try? dataController.viewContext.save()
    }
}

// MARK: - Collection View Flow Layout Delegate

extension PhotoAlbumViewController : UICollectionViewDelegateFlowLayout {
  
  func collectionView(_ collectionView: UICollectionView,
                      layout collectionViewLayout: UICollectionViewLayout,
                      sizeForItemAt indexPath: IndexPath) -> CGSize {

    let itemsPerRow: CGFloat = UIScreen.main.bounds.width > UIScreen.main.bounds.height ? itemsPerRowLandscape : itemsPerRowPortrait //I need to resolve for 3.0 for portrait
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
