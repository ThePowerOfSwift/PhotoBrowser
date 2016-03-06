//
//  PhotoBrowserViewController.swift
//  PhotoBrowser
//
//  Created by  lifirewolf on 16/3/4.
//  Copyright © 2016年 lifirewolf. All rights reserved.
//

import UIKit

@objc protocol PhotoBrowserDataSource: NSObjectProtocol {
    
    /**
    *  有多少组
    */
    optional func numberOfSectionInPhotosInPickerBrowser(pickerBrowser: PhotoBrowserViewController)  -> Int
    
    /**
    *  每个组多少个图片
    */
    func photoBrowser(photoBrowser: PhotoBrowserViewController, numberOfItemsInSection section: Int) -> Int
    /**
    *  每个对应的IndexPath展示什么内容
    */
    func photoBrowser(pickerBrowser: PhotoBrowserViewController, photoAtIndexPath indexPath: NSIndexPath) -> PhotoInfo
    
}

@objc protocol PhotoBrowserDelegate: NSObjectProtocol {
    /**
    *  点击每个Item时候调用
    */
    optional func photoBrowser(pickerBrowser: PhotoBrowserViewController, photoDidSelectView scrollBoxView: UIView, atIndexPath indexPath: NSIndexPath)
    
    /**
    *  准备删除那个图片
    *
    *  @param index        要删除的索引值
    */
    optional func photoBrowser(photoBrowser: PhotoBrowserViewController, willRemovePhotoAtIndexPath indexPath: NSIndexPath) -> Bool
    
    /**
    *  删除indexPath对应索引的图片
    *
    *  @param indexPath        要删除的索引值
    */
    optional func photoBrowser(photoBrowser: PhotoBrowserViewController, removePhotoAtIndexPath indexPath: NSIndexPath)
    
    /**
    *  滑动结束的页数
    *
    *  @param page         滑动的页数
    */
    optional func photoBrowser(photoBrowser: PhotoBrowserViewController, didCurrentPage page: Int)
    
    /**
    *  滑动开始的页数
    *
    *  @param page         滑动的页数
    */
    optional func photoBrowser(photoBrowser: PhotoBrowserViewController, willCurrentPage page: Int)
    
    optional func photoBrowser(photoBrowser: PhotoBrowserViewController, loadedItem index: Int, loadedImage image: UIImage)
}

let cellIdentifier = "collectionViewCell"

class PhotoBrowserViewController: UIViewController {

    // 数据源/代理
    var dataSource: PhotoBrowserDataSource?
    var delegate: PhotoBrowserDelegate?
    
    var placeHolderImage: UIImage?
    var photos = [PhotoInfo]()
    
    // 当前提供的分页数
    var currentPage = 0
    
    // 长按保存图片会调用sheet
    var sheet: UIActionSheet?
    
    // 控件
    var pageLabel: UILabel!
    var collectionView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.minimumInteritemSpacing = 0.0
        flowLayout.minimumLineSpacing = 0.0
        flowLayout.itemSize = view.frame.size
        flowLayout.scrollDirection = UICollectionViewScrollDirection.Horizontal
        
        collectionView = UICollectionView(frame: CGRect(x: 0, y: 0, width: view.bounds.width, height: view.bounds.height), collectionViewLayout: flowLayout)
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.showsVerticalScrollIndicator = false
        collectionView.pagingEnabled = true
        collectionView.backgroundColor = UIColor.clearColor()
        collectionView.bounces = true
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.registerClass(UICollectionViewCell.self, forCellWithReuseIdentifier: cellIdentifier)
        view.addSubview(collectionView)
        
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        
        var widthVfl = "H:|-0-[collectionView]-0-|"
        var heightVfl = "V:|-0-[collectionView]-0-|"
        var views: [String: AnyObject] = ["collectionView": collectionView]
        var metrics: [String: AnyObject]?
        
        view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat(widthVfl, options: NSLayoutFormatOptions(), metrics: metrics, views: views))
        view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat(heightVfl, options: NSLayoutFormatOptions(), metrics: nil, views: views))
        
//        NSNotificationCenter.defaultCenter().addObserver(self, selector: "changeRotationDirection:", name: UIDeviceOrientationDidChangeNotification, object: nil)
        
        pageLabel = UILabel()
        pageLabel.font = UIFont.systemFontOfSize(18)
        pageLabel.textAlignment = NSTextAlignment.Center
        pageLabel.userInteractionEnabled = false
        pageLabel.translatesAutoresizingMaskIntoConstraints = false
        pageLabel.backgroundColor = UIColor.clearColor()
        pageLabel.textColor = UIColor.whiteColor()
        view.addSubview(pageLabel)
        
        widthVfl = "H:|-0-[pageLabel]-0-|"
        heightVfl = "V:[pageLabel(PickerPageCtrlH)]-20-|"
        views = ["pageLabel": pageLabel]
        metrics = ["PickerPageCtrlH": 25]
        
        view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat(widthVfl, options: NSLayoutFormatOptions(), metrics: metrics, views: views))
        view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat(heightVfl, options: NSLayoutFormatOptions(), metrics: metrics, views: views))

        view.backgroundColor = UIColor.blackColor()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        view.alpha = 0
        UIApplication.sharedApplication().setStatusBarHidden(true, withAnimation: UIStatusBarAnimation.None)
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        if photos.count == 0 {
            return
        }
        
        reloadData()
        
        if currentPage >= 0 && currentPage < photos.count {
            
            collectionView.contentOffset = CGPointMake(CGFloat(currentPage) * collectionView.frame.width, collectionView.contentOffset.y)
            view.alpha = 1
            if currentPage == photos.count - 1 && self.photos.count > 1 {
                
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(Double(NSEC_PER_SEC) * 0.1)), dispatch_get_main_queue()) {
                    
                    self.collectionView.contentOffset = CGPoint(x: CGFloat(self.currentPage) * self.collectionView.frame.width, y: self.collectionView.contentOffset.y)
                }
            }
        }
        
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        navigationController?.navigationBar.alpha = 1.0
        UIApplication.sharedApplication().setStatusBarHidden(false, withAnimation: UIStatusBarAnimation.None)
    }
    
    func setPageLabelPage(page: Int) {
        
        pageLabel.text = "\(page + 1) / \(photos.count)"

    }
    
    func delete() {
        // 准备删除
        if let delegate = delegate {
            if delegate.respondsToSelector("photoBrowser:willRemovePhotoAtIndexPath:") {
                if delegate.photoBrowser!(self, willRemovePhotoAtIndexPath: NSIndexPath(forItem: currentPage, inSection: 0)) {
                    return
                }
            }
        }
        let removeAlert = UIAlertView(title: "确定要删除此图片？", message: "", delegate: self, cancelButtonTitle: "取消", otherButtonTitles: "确定")
        removeAlert.show()
    }
    
    // 刷新数据
    func reloadData() {
        
        if currentPage >= photos.count  && currentPage < photos.count {
            currentPage = photos.count - 1
        }
        
        collectionView.reloadData()
        
        setPageLabelPage(currentPage)
        
        if currentPage >= 0 {
            
            collectionView.contentOffset = CGPointMake(CGFloat(currentPage) * collectionView.frame.width, collectionView.contentOffset.y)
            
            if currentPage == photos.count - 1 && photos.count > 1 {
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(0.1 * Double(NSEC_PER_SEC))), dispatch_get_main_queue()) {
                    
                    self.collectionView.contentOffset = CGPointMake(CGFloat(self.currentPage) * self.collectionView.frame.width, self.collectionView.contentOffset.y)
                }
            }
        }
    }
    
}

extension PhotoBrowserViewController: UIAlertViewDelegate {
    func alertView(alertView: UIAlertView, clickedButtonAtIndex buttonIndex: Int) {
        
        if buttonIndex == 0 {
            return
        }
        
        let page = currentPage
        
        if let delegate = delegate {
            if delegate.respondsToSelector("photoBrowser:removePhotoAtIndexPath:") {
                delegate.photoBrowser!(self, removePhotoAtIndexPath: NSIndexPath(forItem: page, inSection: 0))
            }
        }
        
        if photos.count > currentPage || dataSource != nil {
            photos.removeAtIndex(currentPage)
        }
        
        if page >= photos.count {
            currentPage--
        }
        
        if let cell = collectionView.cellForItemAtIndexPath(NSIndexPath(forItem: page, inSection: 0)) {
            if let view = cell.contentView.subviews.last {
                UIView.animateWithDuration(0.35, animations: {
                    view.alpha = 0.0
                    }, completion: { flag in
                        self.reloadData()
                    }
                )
            }
        }
        
        if photos.count < 1 {
            NSNotificationCenter.defaultCenter().removeObserver(self)
            dismissViewControllerAnimated(true, completion: nil)
        }
    }
}

extension PhotoBrowserViewController: PhotoScrollViewDelegate {

    func photoScrollViewDidSingleClick(photoScrollView: PhotoScrollView) {
        dismissViewControllerAnimated(true, completion: nil)
        
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    func imageLoadedSucceed(photoScrollView: PhotoScrollView, image: UIImage) {
        if let delegate = delegate {
            if delegate.respondsToSelector("photoBrowser:loadedItem:loadedImage:") {
                delegate.photoBrowser!(self, loadedItem: photoScrollView.index, loadedImage: image)
            }
        }
    }
}

extension PhotoBrowserViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(scrollView: UIScrollView) {
    }
    
    func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
        
        var currentPage = Int(scrollView.contentOffset.x / scrollView.frame.size.width)
        
        if currentPage == photos.count - 2 {
            currentPage = Int(round(scrollView.contentOffset.x / scrollView.frame.size.width))
        }
        
        self.currentPage = currentPage
        setPageLabelPage(currentPage)
        
        if let delegate = delegate {
            if delegate.respondsToSelector("photoBrowser:didCurrentPage:") {
                delegate.photoBrowser!(self, didCurrentPage: currentPage)
            }
        }
    }
}

extension PhotoBrowserViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return dataSource?.numberOfSectionInPhotosInPickerBrowser?(self) ?? photos.count
//        return self.photos.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(cellIdentifier, forIndexPath: indexPath)
        
        if collectionView.dragging {
            cell.hidden = false
        }
        
        if photos.count > 0 {
            
            let photo = dataSource?.photoBrowser(self, photoAtIndexPath: indexPath) ?? photos[indexPath.item]
//            let photo = photos[indexPath.item]
            
            if let cell = cell.contentView.subviews.last {
                cell.removeFromSuperview()
            }
            
            let tempF = UIScreen.mainScreen().bounds
            
            let scrollBoxView = UIView()
            scrollBoxView.frame = tempF
            scrollBoxView.autoresizingMask = [UIViewAutoresizing.FlexibleHeight, UIViewAutoresizing.FlexibleWidth]
            cell.contentView.addSubview(scrollBoxView)
            
            let scrollView = PhotoScrollView()
            scrollView.placeHolderImage = placeHolderImage
            scrollView.sheet = sheet
            // 为了监听单击photoView事件
            scrollView.frame = tempF
            scrollView.tag = 101
            scrollView.index = indexPath.item
            scrollView.photoScrollViewDelegate = self
            scrollView.photo = photo
            
            if let delegate = delegate {
                if delegate.respondsToSelector("photoBrowser:photoDidSelectView:atIndexPath:") {
                    scrollView.callback = {
                        self.delegate!.photoBrowser!(self, photoDidSelectView: scrollBoxView, atIndexPath: indexPath)
                    }
                }
            }
            
            scrollBoxView.addSubview(scrollView)
            
            scrollView.autoresizingMask = [UIViewAutoresizing.FlexibleHeight, UIViewAutoresizing.FlexibleWidth]
        }
        
        return cell
    }
}
