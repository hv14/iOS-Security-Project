//
//  PhotosController.swift
//  DAJ_NET
//
//  Created by James Wegner on 4/14/16.
//  Copyright © 2016 James Wegner. All rights reserved.
//

import UIKit
import Photos

class PhotosController: NSObject {
    var assets: [PHAsset] = []
    let manager = PHImageManager.defaultManager()
    let images = NSMutableArray()
    
    func requestAccess() {
        let cachingImageManager = PHCachingImageManager()
        
        let options = PHFetchOptions()
        options.predicate = NSPredicate(format: "favorite == YES")
        options.sortDescriptors = [
            NSSortDescriptor(key: "creationDate", ascending: true)
        ]
        
        let results = PHAsset.fetchAssetsWithMediaType(.Image, options: options)
        var assets: [PHAsset] = []
        results.enumerateObjectsUsingBlock { (object, _, _) in
            if let asset = object as? PHAsset {
                assets.append(asset)
            }
        }
        
        print("\(assets.count) images found")
        
        cachingImageManager.startCachingImagesForAssets(assets,
                                                        targetSize: PHImageManagerMaximumSize,
                                                        contentMode: .AspectFit,
                                                        options: nil
        )
        
        for asset in assets {
            cachingImageManager.requestImageForAsset(asset, targetSize:CGSize(width: asset.pixelWidth, height: asset.pixelHeight)
                , contentMode: PHImageContentMode.AspectFit, options: nil, resultHandler: {(image, objects) in
                    let resources = PHAssetResource.assetResourcesForAsset(asset)
                    let imageUploadAsset = ImageUploadAsset()
                    imageUploadAsset.fileName = resources.first!.originalFilename
                    imageUploadAsset.image = image!
                    self.images.addObject(imageUploadAsset)
                    
                    // Hack to get PNG representation of image
                    UIGraphicsBeginImageContext(imageUploadAsset.image.size);
                    imageUploadAsset.image.drawInRect(CGRectMake(0, 0, imageUploadAsset.image.size.width, imageUploadAsset.image.size.height))
                    let pngImage = UIGraphicsGetImageFromCurrentImageContext();
                    UIGraphicsEndImageContext();
                    
                    imageUploadAsset.image = pngImage!
                    
                    if let dir = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.DocumentDirectory, NSSearchPathDomainMask.AllDomainsMask, true).first {
                        let path = NSURL(fileURLWithPath: dir).URLByAppendingPathComponent(imageUploadAsset.fileName)
                        imageUploadAsset.imageUrl = path
                        let pngData = UIImagePNGRepresentation(imageUploadAsset.image)!
                        
                        do {
                            try pngData.writeToURL(path, options: .AtomicWrite)
                        } catch {
                            print(error)
                        }
                    }
            })
        }
    }
    
    func uploadAllImages() {
        self.uploadImageAtIndex(0)
    }
    
    func uploadImageAtIndex(index: Int) {
        if index >= images.count || index < 0 {
            return
        }
        
        let imageUploadAsset = images.objectAtIndex(index) as! ImageUploadAsset
        FTPClient.uploadFileWithURL(imageUploadAsset.fileName, fileURL: imageUploadAsset.imageUrl, completion: { (error) in
            if imageUploadAsset != self.images.lastObject as! ImageUploadAsset {
                self.uploadImageAtIndex(index + 1)
            }
        })
    }
}
