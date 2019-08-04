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
        
        setupCollectionView()
        fetchAssets()
        requestAuthorization()
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

extension PHFetchOptions {
    static var ascendingOptions: PHFetchOptions = {
        let option = PHFetchOptions()
        option.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: true)]
        return option
    }()
}
