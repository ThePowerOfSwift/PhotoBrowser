//
//  ViewController.swift
//  PhotoBrowser
//
//  Created by  lifirewolf on 16/3/4.
//  Copyright © 2016年 lifirewolf. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    @IBAction func showImg(sender: AnyObject) {
        
        var photos = [PhotoInfo]()
        
        photos.append(PhotoInfo(image: UIImage(named: "img.PNG")!))
        photos.append(PhotoInfo(image: UIImage(named: "img.PNG")!))
        photos.append(PhotoInfo(image: UIImage(named: "img.PNG")!))
        photos.append(PhotoInfo(image: UIImage(named: "img.PNG")!))
        
//        // 测试数据啦
//        let photo1 = PhotoInfo(url: NSURL(string: "http://imgsrc.baidu.com/forum/w%3D580/sign=445a261ef01fbe091c5ec31c5b610c30/23064a90f603738d96e6154ab11bb051f819ec35.jpg")!)
//        photos.append(photo1)
//        
//        let photo2 = PhotoInfo(url: NSURL(string: "http://imgsrc.baidu.com/forum/w%3D580/sign=14e206601d30e924cfa49c397c096e66/1bcc39dbb6fd5266c3fc277ca918972bd507368d.jpg")!)
//        photos.append(photo2)
//        
//        let photo3 = PhotoInfo(url: NSURL(string: "http://imgsrc.baidu.com/forum/pic/item/4753564e9258d1095d4280dad358ccbf6c814d38.jpg")!)
//        photos.append(photo3)
//        
//        let photo4 = PhotoInfo(url: NSURL(string: "http://imgsrc.baidu.com/forum/pic/item/6c04738da9773912fcb7ae09fa198618377ae2c8.jpg")!)
//        photos.append(photo4)
        
        // 图片游览器
        let photoBrowser = PhotoBrowserViewController()
        photoBrowser.photos = photos
        
        photoBrowser.currentPage = 3
        
        presentViewController(photoBrowser, animated: false, completion: nil)
    }

}

