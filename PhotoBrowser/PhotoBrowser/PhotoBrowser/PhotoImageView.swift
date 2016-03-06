//
//  PhotoImageView.swift
//  PhotoBrowser
//
//  Created by  lifirewolf on 16/3/4.
//  Copyright © 2016年 lifirewolf. All rights reserved.
//

import UIKit

@objc protocol PhotoImageViewDelegate: NSObjectProtocol {
    optional func imageView(imageView: UIImageView, singleTapDetected touch:UITouch)
    optional func imageView(imageView: UIImageView, doubleTapDetected touch:UITouch)
}

class PhotoImageView: UIImageView {
    
    var tapDelegate: PhotoImageViewDelegate?
    var scaleBigTap: UITapGestureRecognizer!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        setup()
    }
    
    override init(image: UIImage?) {
        super.init(image: image)
        
        setup()
    }
    
    override init(image: UIImage?, highlightedImage: UIImage?) {
        super.init(image: image, highlightedImage: highlightedImage)
        
        setup()
    }
    
    func setup() {
        userInteractionEnabled = true
        contentMode = UIViewContentMode.ScaleAspectFit
        // 双击放大
        scaleBigTap = UITapGestureRecognizer(target: self, action: "handleDoubleTap:")
        scaleBigTap.numberOfTapsRequired = 2
        scaleBigTap.numberOfTouchesRequired = 1
        addGestureRecognizer(scaleBigTap)
        
        // 单击缩小
        let disMissTap = UITapGestureRecognizer(target: self, action: "handleSingleTap:")
        disMissTap.numberOfTapsRequired = 1
        disMissTap.numberOfTouchesRequired = 1
        addGestureRecognizer(disMissTap)
        
        // 只能有一个手势存在
        disMissTap.requireGestureRecognizerToFail(scaleBigTap)
    }
    
    func addScaleBigTap() {
        scaleBigTap.addTarget(self, action: "handleDoubleTap:")
    }
    
    func removeScaleBigTap() {
        scaleBigTap.removeTarget(self, action: "handleDoubleTap:")
    }
    
    func handleSingleTap(touch: UITouch) {
        if let tapDelegate = tapDelegate {
            if tapDelegate.respondsToSelector("imageView:singleTapDetected:") {
                tapDelegate.imageView!(self, singleTapDetected: touch)
            }
        }
    }
    
    func handleDoubleTap(touch: UITouch) {
        if let tapDelegate = tapDelegate {
            if tapDelegate.respondsToSelector("imageView:doubleTapDetected:") {
                tapDelegate.imageView!(self, doubleTapDetected: touch)
            }
        }
    }

    
}
