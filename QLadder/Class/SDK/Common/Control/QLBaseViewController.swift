//
//  QLBaseViewController.swift
//  QLadder
//
//  Created by TonyHan on 2017/11/16.
//  Copyright © 2017年 TonyHan All rights reserved.
//

import UIKit

class QLBaseViewController: UIViewController {
    
    var emptyView: UIView?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = QLColor.C2

		let backImage = UIImage(named: "nav-back")?.withRenderingMode(UIImage.RenderingMode.alwaysOriginal)
		
		navigationController?.navigationBar.backIndicatorImage = backImage
        navigationController?.navigationBar.backIndicatorTransitionMaskImage = backImage
		
        let backItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        navigationItem.backBarButtonItem = backItem
		
        navigationController?.navigationBar.barTintColor = QLColor.C2
    }
    
    func showEmptyView() {
        if emptyView == nil {
            let emptyView = UIView(frame: view.bounds)
            let image = UIImage(named: "empty")
            let imageView = UIImageView(image: image)
            imageView.center = emptyView.center
            imageView.frame.size = image!.size
            emptyView.addSubview(imageView)
            emptyView.isUserInteractionEnabled = true
            let singleTap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(emptyViewDidClick(_:)))
            singleTap.numberOfTapsRequired = 1;
            emptyView.addGestureRecognizer(singleTap)
            self.emptyView = emptyView
        }
        view.addSubview(emptyView!)
    }
    
    func hideEmptyView() {
        emptyView?.removeFromSuperview()
    }
    
    func isEmptyViewShowing() -> Bool {
        if let emptyView = self.emptyView, let _ = emptyView.superview {
            return true
        }
        return false
    }
    
    func layoutEmptyView() -> Bool {
        if let emptyView = self.emptyView, let superview = emptyView.superview {
            if (isViewLoaded) {
                let newSize = superview.bounds.size
                let oldSize = emptyView.frame.size
                if !oldSize.equalTo(newSize) {
                    emptyView.frame = CGRect(x: emptyView.frame.minX, y: emptyView.frame.minY, width: newSize.width, height: newSize.height)
                }
                return true
            }
        }
        return false
    }
    
    @objc func emptyViewDidClick(_ gestureRecognizer: UITapGestureRecognizer) {
        
    }
}
