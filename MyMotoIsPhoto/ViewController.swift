//
//  ViewController.swift
//  MyMotoIsPhoto
//
//  Created by Miras Karazhigitov on 8/4/19.
//  Copyright © 2019 Miras Karazhigitov. All rights reserved.
//

import UIKit
import Photos

class ViewController: UIViewController {
    private let cellID = "CellID"
    @IBOutlet var galleryCollectionView: UICollectionView!
    
    var fetchResult: PHFetchResult<PHAsset>!
    let imageManager = PHCachingImageManager()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 1
        PHPhotoLibrary.shared().register(self)
        setupCollectionView()
        fetchAssets()
        requestAuthorization()
    }
    
    deinit {
        // 2
        PHPhotoLibrary.shared().unregisterChangeObserver(self)
    }
    
    private func setupCollectionView() {
        galleryCollectionView.register(GalleryCell.self, forCellWithReuseIdentifier: cellID)
    }
    
    private func fetchAssets() {
        fetchResult = PHAsset.fetchAssets(with: .ascendingOptions)
    }
    
    private func requestAuthorization() {
        PHPhotoLibrary.requestAuthorization { (status) in
            switch status {
            case .authorized:
                DispatchQueue.main.async {
                    self.fetchAssets()
                    self.galleryCollectionView.reloadData()
                    // 1
                    self.galleryCollectionView.scrollToItem(at: IndexPath(item: self.fetchResult.count-1, section: 0),
                                                            at: .bottom,
                                                            animated: false)
                }
            case .notDetermined:
                PHPhotoLibrary.requestAuthorization() { status in
                    if status == .authorized {
                        DispatchQueue.main.async {
                            self.fetchAssets()
                            self.galleryCollectionView.reloadData()
                        }
                    }
                }
            default:
                break
            }
        }
    }
    @IBAction func didPressAddNewImage(_ sender: UIButton) {
        PHPhotoLibrary.shared().performChanges({
            let image = UIColor.red.image()
            PHAssetChangeRequest.creationRequestForAsset(from: image)
        })
    }
}

extension ViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return fetchResult.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellID, for: indexPath) as! GalleryCell
        let asset = fetchResult.object(at: indexPath.item)
        cell.id = asset.localIdentifier
        
        imageManager.requestImage(for: asset, targetSize: cell.frame.size, contentMode: .aspectFill, options: nil) { (image, _) in
            if cell.id == asset.localIdentifier {
                cell.backgroundView = UIImageView(image: image)
            }
        }
        
        return cell
    }
}

extension ViewController: PHPhotoLibraryChangeObserver {
    func photoLibraryDidChange(_ changeInstance: PHChange) {
        // 1
        guard let changes = changeInstance.changeDetails(for: fetchResult)
            else { return }
        
        // 2
        self.fetchResult = changes.fetchResultAfterChanges
        
        // 3
        DispatchQueue.main.async {
            if changes.hasIncrementalChanges {
                self.galleryCollectionView?.performBatchUpdates({
                    if let removed = changes.removedIndexes, !removed.isEmpty {
                        self.galleryCollectionView?.deleteItems(at: removed.map({ IndexPath(item: $0, section: 0) }))
                    }
                    
                    if let inserted = changes.insertedIndexes, !inserted.isEmpty {
                        self.galleryCollectionView?.insertItems(at: inserted.map({ IndexPath(item: $0, section: 0) }))
                    }
                    
                    changes.enumerateMoves { fromIndex, toIndex in
                        self.galleryCollectionView?.moveItem(at: IndexPath(item: fromIndex, section: 0),
                                                             to: IndexPath(item: toIndex, section: 0))
                    }
                })
                
                if let changed = changes.changedIndexes, !changed.isEmpty {
                    self.galleryCollectionView?.reloadItems(at: changed.map({ IndexPath(item: $0, section: 0) }))
                }
                
            } else {
                self.galleryCollectionView?.reloadData()
            }
        }
    }
}

extension PHFetchOptions {
    static var ascendingOptions: PHFetchOptions = {
        let option = PHFetchOptions()
        option.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: true)]
        return option
    }()
}
