//
//  PhotoView.swift
//  PhotoBrowser
//
//  Created by  lifirewolf on 16/3/4.
//  Copyright © 2016年 lifirewolf. All rights reserved.
//

import UIKit


@objc protocol PhotoViewDelegate: NSObjectProtocol {
    optional func view(view: UIView, singleTapDetected touch: UITouch)
    optional func view(view: UIView, doubleTapDetected touch: UITouch)
}

class PhotoView: UIView {
    
    var tapDelegate: PhotoViewDelegate?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    func setup() {
        
        
        userInteractionEnabled = true
        
        // 双击放大
        let scaleBigTap = UITapGestureRecognizer(target: self, action: "handleDoubleTap:")
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
    
    func handleDoubleTap(touch: UITouch) {
        if let tapDelegate = tapDelegate {
            if tapDelegate.respondsToSelector("view:doubleTapDetected:") {
                tapDelegate.view!(self, doubleTapDetected: touch)
            }
        }
    }
    
    func handleSingleTap(touch: UITouch) {
        if let tapDelegate = tapDelegate {
            if tapDelegate.respondsToSelector("view:singleTapDetected:") {
                tapDelegate.view!(self, singleTapDetected: touch)
            }
        }
    }
}
