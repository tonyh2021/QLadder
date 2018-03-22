//
//  LaunchViewManager.swift
//  QLadder
//
//  Created by qd-hxt on 2017/11/27.
//  Copyright © 2017年 qding. All rights reserved.
//

import UIKit

protocol LaunchViewManagerDelegate: class {
    func managerWillDisappear(_ manager: LaunchViewManager)
}

class LaunchViewManager {
    static let shared = LaunchViewManager()
    
    weak var delegate: LaunchViewManagerDelegate?
    
    open var isLogoZoom: Bool//open 只能被访问，不能继承重写
    
    open var isHomeZoom:Bool
    
    private var hasShown:Bool //本次启动是否已经显示过
    
    fileprivate init() {
        isLogoZoom = true
        isHomeZoom = true
        hasShown = false
    }
    
    deinit {
    }
    
    public func showLaunchView() {
        
        if self.hasShown {
            return
        }
        
        //1.获取 window 及 view
        guard let keyWindow = UIApplication.shared.keyWindow else {
            return
        }
        
        let view = keyWindow.rootViewController!.view!
        print(view)
        
        //2.从 bundle 中获取启动 View
        let launchVC = UIStoryboard(name: "LaunchScreen", bundle: nil).instantiateViewController(withIdentifier: "LaunchScreen")
        
        guard let launchView = launchVC.view else {
            return
        }
        
        //3.添加 launchView 作为过渡
        launchView.frame = view.frame
        view.addSubview(launchView)
        
        var imageView:UIImageView?

        for subview in launchView.subviews {
            if (subview is UIImageView) {
                imageView = subview as? UIImageView
            }
        }

        guard let logoImageView = imageView else {
            return
        }
        
        let bounds = CGRect(x: 0, y: 0, width: logoImageView.bounds.width, height: logoImageView.bounds.height)
        let point = CGPoint(x: logoImageView.center.x, y: view.center.y - 40)
        
        //4.添加 logo 的 layer
        let logoLayer = CALayer()
        logoLayer.bounds = bounds
        logoLayer.position = point
        logoLayer.contents = UIImage(named: "logo")?.cgImage
        view.layer.mask = logoLayer
        
        //5.添加白色背景并设置window的背景
        let shelterView = UIView(frame: view.frame)
        shelterView.backgroundColor = .white
        view.addSubview(shelterView)
        
        keyWindow.backgroundColor = launchView.backgroundColor
        //6.去掉作为过渡背景的launchView
        launchView.removeFromSuperview()
        
        //7.logo 的缩小放大
        if self.isLogoZoom {
            let logoAnimation = CAKeyframeAnimation(keyPath: "bounds")
            logoAnimation.beginTime = CACurrentMediaTime() + 1
            logoAnimation.duration = 1
            logoAnimation.keyTimes = [0, 0.4, 1]
            logoAnimation.values = [NSValue(cgRect: CGRect(x: 0, y: 0, width: 100, height: 100)),
                                    NSValue(cgRect: CGRect(x: 0, y: 0, width: 85, height: 85)),
                                    NSValue(cgRect: CGRect(x: 0, y: 0, width: 4500, height: 4500))]
            logoAnimation.timingFunctions = [CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseOut),
                                             CAMediaTimingFunction(name: kCAMediaTimingFunctionDefault)]
            logoAnimation.isRemovedOnCompletion = false
            logoAnimation.fillMode = kCAFillModeForwards
            logoLayer.add(logoAnimation, forKey: "zoomAnimation")
        }

        //8.初始界面颠一下
        if self.isHomeZoom {
            let mainViewAnimation = CAKeyframeAnimation(keyPath: "transform")
            mainViewAnimation.beginTime = CACurrentMediaTime() + 1.1
            mainViewAnimation.duration = 0.6
            mainViewAnimation.keyTimes = [0, 0.5, 1]
            mainViewAnimation.values = [NSValue(caTransform3D: CATransform3DIdentity),
                                        NSValue(caTransform3D: CATransform3DScale(CATransform3DIdentity, 1.1, 1.1, 1)),
                                        NSValue(caTransform3D: CATransform3DIdentity)]
            view.layer.add(mainViewAnimation, forKey: "transformAnimation")
            view.layer.transform = CATransform3DIdentity
        }
        
        //9.logo 透明
        UIView.animate(withDuration: 0.3, delay: 1.4, options: .curveLinear, animations: {
            shelterView.alpha = 0
        }) { (_) in
            shelterView.removeFromSuperview()
            view.layer.mask = nil
            self.delegate?.managerWillDisappear(self)
        }
        
        hasShown = true
    }
}
