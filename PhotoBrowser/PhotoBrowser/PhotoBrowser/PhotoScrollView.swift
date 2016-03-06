//
//  PhotoScrollView.swift
//  PhotoBrowser
//
//  Created by  lifirewolf on 16/3/4.
//  Copyright © 2016年 lifirewolf. All rights reserved.
//

import UIKit

@objc protocol PhotoScrollViewDelegate: NSObjectProtocol {
    // 单击调用
    optional func photoScrollViewDidSingleClick(photoScrollView: PhotoScrollView)
    optional func imageLoadedSucceed(photoScrollView: PhotoScrollView, image: UIImage)
}

class PhotoScrollView: UIScrollView {
    
    var placeHolderImage: UIImage?
    
    var photo: PhotoInfo! {
        didSet {
            if let image = photo.image {
                photoImageView.image = image
                isLoadingDone = true
                indicatLayer?.removeFromSuperlayer()
                displayImage()
                
            } else if let url = photo.url {
//                if let placeHolderImage = placeHolderImage {
//                    photoImageView.sd_setImageWithURL(url, placeholderImage: placeHolderImage) {[weak self] image, error, type, url -> Void in
//                        guard let _self = self else {
//                            return
//                        }
//                        _self.completed(image, error: error, type: type, url: url)
//                    }
//                    
//                } else {
//                    photoImageView.sd_setImageWithURL(url) {[weak self] (image, error, type, url) -> Void in
//                        guard let _self = self else {
//                            return
//                        }
//                        _self.completed(image, error: error, type: type, url: url)
//                    }
//                }
                
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) {
                    if let data = NSData(contentsOfURL: url) {
                        if let img = UIImage(data: data) {
                            self.photo.image = img
                            self.photoImageView.image = img
                            self.isLoadingDone = true
                            self.indicatLayer?.removeFromSuperlayer()
                            self.displayImage()
                            
                            
                            if let photoScrollViewDelegate = self.photoScrollViewDelegate {
                                dispatch_async(dispatch_get_main_queue()) {
                                    photoScrollViewDelegate.imageLoadedSucceed?(self, image: img)
                                }
                            }
                        }
                    }
                }

                
            }
        }
    }
    
//    func completed(image: UIImage!, error: NSError!, type: SDImageCacheType, url: NSURL!) {
//        if let img = image {
//            photo.image = img
//            photoImageView.image = img
//            isLoadingDone = true
//            displayImage()
//            
//            if let photoScrollViewDelegate = photoScrollViewDelegate {
//                dispatch_async(dispatch_get_main_queue()) {
//                    photoScrollViewDelegate.imageLoadedSucceed?(self, image: img)
//                }
//            }
//            
//        } else {
//            print(error ?? "")
//        }
//        indicatLayer?.removeFromSuperlayer()
//    }
    
    var index = 0
    
    var tapView: PhotoView! // for background taps
    
    var photoImageView: PhotoImageView!
    
    var photoScrollViewDelegate: PhotoScrollViewDelegate?
    
    // 长按图片的操作，可以外面传入
    var sheet: UIActionSheet!
    
    // 单击销毁的block
    var callback: (() -> Void)?
    
    var isLoadingDone = false
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        setup()
    }
    
    deinit {
        indicatLayer?.removeFromSuperlayer()
    }
    
    func setup() {
        // Setup
        // Tap view for background
        tapView = PhotoView(frame: bounds)
        
        tapView.tapDelegate = self
        tapView.autoresizingMask = [UIViewAutoresizing.FlexibleWidth, UIViewAutoresizing.FlexibleHeight]
        tapView.backgroundColor = UIColor.blackColor()
        addSubview(tapView)
        
        // Image view
        photoImageView = PhotoImageView(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
        photoImageView.center = center
        photoImageView.tapDelegate = self
        photoImageView.contentMode = UIViewContentMode.Center
        photoImageView.backgroundColor = UIColor.blackColor()
        indicator()
        addSubview(photoImageView)
        
        // Setup
        backgroundColor = UIColor.blackColor()
        delegate = self
        showsHorizontalScrollIndicator = false
        showsVerticalScrollIndicator = false
        decelerationRate = UIScrollViewDecelerationRateFast
        autoresizingMask = [UIViewAutoresizing.FlexibleWidth, UIViewAutoresizing.FlexibleHeight]
        
        let longGesture = UILongPressGestureRecognizer(target: self, action: "longGesture:")
        addGestureRecognizer(longGesture)
        
    }
    
    var indicatLayer: CAReplicatorLayer?
    func indicator() {
        let r = CAReplicatorLayer()
        let w = CGFloat(44)
        let h = CGFloat(44)
        r.frame = CGRect(x: (photoImageView.bounds.width - w) / 2 , y: (photoImageView.bounds.height - h) / 2, width: w, height: h)
        photoImageView.layer.addSublayer(r)
        
        let dot = CALayer()
        dot.bounds = CGRect(x: 0.0, y: 0.0, width: 4.0, height: 4.0)
        dot.position = CGPoint(x: (r.bounds.width - 4)/2, y: 1.0)
        dot.backgroundColor = UIColor(red: 0x36 / 255.0, green: 0x91 / 255.0, blue: 0xea / 255.0, alpha: 1).CGColor
        dot.cornerRadius = 2.0
        
        r.addSublayer(dot)
        
        let nrDots: Int = 12
        
        r.instanceCount = nrDots
        let angle = CGFloat(2*M_PI) / CGFloat(nrDots)
        r.instanceTransform = CATransform3DMakeRotation(angle, 0.0, 0.0, 1.0)
        
        let duration: CFTimeInterval = 1.5
        
        let shrink = CABasicAnimation(keyPath: "transform.scale")
        shrink.fromValue = 1.0
        shrink.toValue = 0.0
        shrink.duration = duration
        shrink.repeatCount = Float.infinity
        
        dot.addAnimation(shrink, forKey: nil)
        
        r.instanceDelay = duration/Double(nrDots)
        dot.transform = CATransform3DMakeScale(0.01, 0.01, 0.01)
        
        indicatLayer = r
    }
    
    func longGesture(gesture: UILongPressGestureRecognizer) {
        if gesture.state == UIGestureRecognizerState.Began {
            if sheet == nil {
                sheet = UIActionSheet(title: "提示", delegate: self, cancelButtonTitle: "取消", destructiveButtonTitle: "保存到相册")
            }
            sheet.showInView(self)
        }
    }
    
    func displayImage() {
        // Reset
        maximumZoomScale = 1
        minimumZoomScale = 1
        zoomScale = 1
        contentSize = CGSize(width: 0, height: 0)
        
        // Get image from browser as it handles ordering of fetching
        if let img = photoImageView.image {
            
            //            photoImageView.image = img
            photoImageView.hidden = false
            
            // Setup photo frame
            var photoImageViewFrame = CGRect()
            photoImageViewFrame.origin = CGPointZero
            photoImageViewFrame.size = img.size
            photoImageView.frame = photoImageViewFrame
            contentSize = photoImageViewFrame.size
            
            // Set zoom to minimum zoom
            setMaxMinZoomScalesForCurrentBounds()
            
        }
        setNeedsLayout()
    }
    
    func setMaxMinZoomScalesForCurrentBounds() {
        // Reset
        maximumZoomScale = 1
        minimumZoomScale = 1
        zoomScale = 1
        
        // Bail if no image
        if photoImageView.image == nil {
            return
        }
        
        //    _photoImageView.frame = [ZLPhotoRect setMaxMinZoomScalesForCurrentBoundWithImageView:_photoImageView];
        // Reset position
        photoImageView.frame = CGRectMake(0, 0, photoImageView.frame.width, photoImageView.frame.height)
        
        // Sizes
        let boundsSize = UIScreen.mainScreen().bounds.size
        let imageSize = photoImageView.image!.size
        
        // Calculate Min
        let xScale = boundsSize.width / imageSize.width    // the scale needed to perfectly fit the image width-wise
        let yScale = boundsSize.height / imageSize.height  // the scale needed to perfectly fit the image height-wise
        
        var minScale = min(xScale, yScale)
        let maxScale = max(xScale, yScale)
        // use minimum of these to allow the image to become fully visible
        // Image is smaller than screen so no zooming!
        if xScale >= 1 && yScale >= 1 {
            minScale = min(xScale, yScale)
        }
        
        if xScale >= yScale * 2 {
            // Initial zoom
            maximumZoomScale = 1.0
            minimumZoomScale = maxScale
        } else {
            maximumZoomScale = yScale
            minimumZoomScale = xScale
        }
        zoomScale = minimumZoomScale
        
        // If we're zooming to fill then centralise
        if zoomScale != minScale {
            if yScale >= xScale {
                scrollEnabled = false
            }
        }
        
        // Layout
        setNeedsLayout()
    }
    
    override func layoutSubviews() {
        // Super
        super.layoutSubviews()
        
        // Center the image as it becomes smaller than the size of the screen
        let boundsSize = bounds.size
        var frameToCenter = photoImageView.frame
        
        // Horizontally
        if frameToCenter.size.width < boundsSize.width {
            frameToCenter.origin.x = floor((boundsSize.width - frameToCenter.size.width) / 2.0)
        } else {
            frameToCenter.origin.x = 0
        }
        
        // Vertically
        if (frameToCenter.size.height < boundsSize.height) {
            frameToCenter.origin.y = floor((boundsSize.height - frameToCenter.size.height) / 2.0)
        } else {
            frameToCenter.origin.y = 0
        }
        
        // Center
        if (!CGRectEqualToRect(photoImageView.frame, frameToCenter)) {
            photoImageView.frame = frameToCenter
        }
    }
    
}

extension PhotoScrollView: UIActionSheetDelegate {
    func actionSheet(actionSheet: UIActionSheet, clickedButtonAtIndex buttonIndex: Int) {
        if buttonIndex == 0 {
            
            if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.SavedPhotosAlbum) {
                
                UIImageWriteToSavedPhotosAlbum(photoImageView.image!, nil, nil, nil)
                if let _ = photoImageView.image {
                    showMessageWithText("保存成功")
                }
            } else {
                if let _ = photoImageView.image {
                    showMessageWithText("没有用户权限,保存失败")
                }
            }
        }
    }
    
    func showMessageWithText(text: String) {
        
        let alertLabel = UILabel()
        alertLabel.font = UIFont.systemFontOfSize(15)
        alertLabel.text = text
        alertLabel.textAlignment = .Center
        alertLabel.layer.masksToBounds = true
        alertLabel.textColor = UIColor.whiteColor()
        alertLabel.bounds = CGRect(x: 0, y: 0, width: 100, height: 80)
        alertLabel.center = CGPoint(x: frame.width * 0.5, y: frame.height * 0.5)
        alertLabel.backgroundColor = UIColor(red: 25 / 255.0, green: 25 / 255.0, blue: 25 / 255.0, alpha: 1)
        alertLabel.layer.cornerRadius = 10.0
        UIApplication.sharedApplication().keyWindow?.addSubview(alertLabel)
        UIView.animateWithDuration(0.3,
            animations: { () -> Void in
                alertLabel.alpha = 0.0
            }, completion: {flag in
                alertLabel.removeFromSuperview()
            }
        )
    }
    
    func disMissTap() {
        
        if let callback = callback {
            callback()
        } else if let photoScrollViewDelegate = photoScrollViewDelegate {
            if photoScrollViewDelegate.respondsToSelector("photoScrollViewDidSingleClick:") {
                photoScrollViewDelegate.photoScrollViewDidSingleClick!(self)
            }
        }
    }
    
    func handleDoubleTap(touchPoint: CGPoint) {
        // Zoom
        if zoomScale != minimumZoomScale && zoomScale != initialZoomScaleWithMinScale {
            // Zoom out
            setZoomScale(minimumZoomScale, animated: true)
            contentSize = CGSize(width: frame.width, height: 0)
        } else if isLoadingDone {
            // Zoom in to twice the size
            let newZoomScale = (self.maximumZoomScale + self.minimumZoomScale) / 1.5
            let xsize = self.bounds.size.width / newZoomScale
            let ysize = self.bounds.size.height / newZoomScale
            zoomToRect(CGRect(x: touchPoint.x - xsize / 2, y: touchPoint.y - ysize / 2, width: xsize, height: ysize), animated: true)
        }
    }
    
    var initialZoomScaleWithMinScale: CGFloat {
        var zoomScale = minimumZoomScale
        if let image = photoImageView.image {
            // Zoom image to fill if the aspect ratios are fairly similar
            let boundsSize = bounds.size
            let imageSize = image.size
            let boundsAR = boundsSize.width / boundsSize.height
            let imageAR = imageSize.width / imageSize.height
            let xScale = boundsSize.width / imageSize.width
            
            if abs(boundsAR - imageAR) < 0.17 {
                zoomScale = xScale
            }
        }
        
        return zoomScale
    }
}

extension PhotoScrollView: UIScrollViewDelegate {
    func viewForZoomingInScrollView(scrollView: UIScrollView) -> UIView? {
        return photoImageView
    }
    
    func scrollViewDidZoom(scrollView: UIScrollView) {
        setNeedsLayout()
        layoutIfNeeded()
    }
}

extension PhotoScrollView: PhotoImageViewDelegate {
    func imageView(imageView: UIImageView, singleTapDetected touch: UITouch) {
        disMissTap()
    }
    
    func imageView(imageView: UIImageView, doubleTapDetected touch: UITouch) {
        handleDoubleTap(touch.locationInView(imageView))
    }
}

extension PhotoScrollView: PhotoViewDelegate {
    func view(view: UIView, singleTapDetected touch: UITouch) {
        disMissTap()
    }
    
    func view(view: UIView, doubleTapDetected touch: UITouch) {
        // Translate touch location to image view location
        var touchX = touch.locationInView(view).x
        var touchY = touch.locationInView(view).y
        touchX *= 1 / zoomScale
        touchY *= 1 / zoomScale
        touchX += contentOffset.x
        touchY += contentOffset.y
        handleDoubleTap(CGPoint(x: touchX, y: touchY))
    }
}
