//
//  PhotoInfo.swift
//  PhotoBrowser
//
//  Created by  lifirewolf on 16/3/4.
//  Copyright © 2016年 lifirewolf. All rights reserved.
//

import UIKit

class PhotoInfo: NSObject {
    var url: NSURL?
    var image: UIImage?
    
    init(url: NSURL) {
        self.url = url
    }
    
    init(image: UIImage) {
        self.image = image
    }
}

class PhotoRect: NSObject {
    
    static func setMaxMinZoomScalesForCurrentBoundWithImage(image: UIImage?) -> CGRect {
        
        guard let image = image else {
            return CGRectZero
        }
        
        let boundsSize = UIScreen.mainScreen().bounds.size
        let imageSize = image.size
        
        if imageSize.width == 0 && imageSize.height == 0 {
            return CGRectZero
        }
        
        // the scale needed to perfectly fit the image width-wise
        let xScale = boundsSize.width / imageSize.width
        
        // the scale needed to perfectly fit the image height-wise
        let yScale = boundsSize.height / imageSize.height
        
        var minScale = min(xScale, yScale)
        if xScale >= 1 && yScale >= 1 {
            minScale = min(xScale, yScale)
        }
        
        var frameToCenter = CGRectZero
        if minScale >= 3 {
            minScale = 3
        }
        frameToCenter = CGRect(x: 0, y: 0, width: imageSize.width * minScale, height: imageSize.height * minScale)
        
        // Horizontally
        if frameToCenter.size.width < boundsSize.width {
            frameToCenter.origin.x = floor((boundsSize.width - frameToCenter.size.width) / 2.0)
        } else {
            frameToCenter.origin.x = 0
        }
        
        // Vertically
        if frameToCenter.size.height < boundsSize.height {
            frameToCenter.origin.y = floor((boundsSize.height - frameToCenter.size.height) / 2.0)
        } else {
            frameToCenter.origin.y = 0
        }
        
        return frameToCenter
    }
    
    static func setMaxMinZoomScalesForCurrentBoundWithImageView(imageView: UIImageView) -> CGRect {
        return setMaxMinZoomScalesForCurrentBoundWithImage(imageView.image)
    }
    
}