//
//  PhotoAlbumViewController+NSFetchedResultsControllerDelegate.swift
//  VirtualTourist
//
//  Created by Chantal Deguire on 2020-08-07.
//  Copyright © 2020 Udacity. All rights reserved.
//

import Foundation
import CoreData

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
                    DispatchQueue.main.async {
                    self.photoCollectionView.reloadItems(at: [indexPath])
                    }
                }
            case .move:
                guard let newIndexPath = newIndexPath else {break}
                blockOperation.addExecutionBlock {
                    DispatchQueue.main.async {
                    self.photoCollectionView.moveItem(at: indexPath!, to: newIndexPath)
                    }
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

