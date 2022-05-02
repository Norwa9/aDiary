//
//  LWFetchPhotoHelper.swift
//  日记2.0
//
//  Created by 罗威 on 2022/5/2.
//

import Foundation
import Photos

class LWFetchPhotoHelper{
    static let shared = LWFetchPhotoHelper()
    
    func fetchLatestPhotos(forCount count: Int?,callBack: @escaping (_ assets: PHFetchResult<PHAsset>) ->()){
        DispatchQueue.global().async {
            // Create fetch options.
            let options = PHFetchOptions()

            // If count limit is specified.
            if let count = count { options.fetchLimit = count }

            // Add sortDescriptor so the lastest photos will be returned.
            let sortDescriptor = NSSortDescriptor(key: "creationDate", ascending: false)
            options.sortDescriptors = [sortDescriptor]
            
            // Fetch the photos.
            let assets = PHAsset.fetchAssets(with: .image, options: options)
            DispatchQueue.main.async {
                callBack(assets)
            }
        }
        
        
    }
}
