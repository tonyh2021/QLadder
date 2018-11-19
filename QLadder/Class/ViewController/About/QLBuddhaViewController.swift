//
//  QLBuddhaViewController.swift
//  QLadder
//
//  Created by TonyHan on 2018/3/22.
//  Copyright © 2018年 TonyHan All rights reserved.
//

import UIKit
import AVKit
import Alamofire

class QLBuddhaViewController: QLBaseViewController {
    
    private var buddha: Buddha
    
    private var buddhaType: BuddhaType
    
    @IBOutlet weak var imageView: UIImageView!
    
    @IBOutlet weak var nameDetailLabel: UILabel!
    
    @IBOutlet weak var durationLabel: UILabel!
    
    @IBOutlet weak var addTimeLabel: UILabel!
    
    @IBOutlet weak var userLabel: UILabel!
    
    @IBOutlet weak var pointsLabel: UILabel!
    
    init(_ buddha: Buddha, buddhaType: BuddhaType) {
        self.buddha = buddha
        self.buddhaType = buddhaType
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented") // or see Roman Sausarnes's answer
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initSubviews()

        if (self.buddhaType == .porn_91) {
            QueryManager.shared.fetchBuddhaDetailIn91(buddha) { (newBuddha, errorMessage) in
                if errorMessage != nil {
                    
                } else {
                    self.buddha = newBuddha
                    self.updateUI()
                }
            }
        } else {
            QueryManager.shared.fetchBuddhaDetailInHub(buddha) { (newBuddha, errorMessage) in
                if errorMessage != nil {
                    
                } else {
                    self.buddha = newBuddha
                    self.updateUI()
                }
            }
        }
        
    }
    
    private func initSubviews() {
        
        navigationItem.title = buddha.name
        
        nameDetailLabel.textColor = QLColor.C0
        nameDetailLabel.font = UIFont.systemFont(ofSize: 18)
        nameDetailLabel.numberOfLines = 2
        
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.backgroundColor = UIColor.lightGray
        imageView.isUserInteractionEnabled = false
        let singleTap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(singleTapping(_:)))
        singleTap.numberOfTapsRequired = 1;
        imageView.addGestureRecognizer(singleTap)
        
        durationLabel.textColor = QLColor.C6
        durationLabel.font = UIFont.systemFont(ofSize: 13)
        addTimeLabel.textColor = QLColor.C6
        addTimeLabel.font = UIFont.systemFont(ofSize: 13)
        userLabel.textColor = QLColor.C6
        userLabel.font = UIFont.systemFont(ofSize: 13)
        pointsLabel.textColor = QLColor.C6
        pointsLabel.font = UIFont.systemFont(ofSize: 13)
        
        nameDetailLabel.text = ""
        durationLabel.text = ""
        addTimeLabel.text = ""
        userLabel.text = ""
        pointsLabel.text = ""
    }
    
    private func updateUI() {
        
        var imgUrl = QueryManager.shared.covertImageUrl
        var name = buddha.name
        if !QueryManager.shared.covertMode && buddha.detailImgUrl != nil {
            imgUrl = buddha.detailImgUrl!
            name = buddha.name_zh
        }
        
        imageView.kf.setImage(with: URL(string: imgUrl), placeholder: nil, options: nil, progressBlock: nil) { (image, error, _, url) in
            self.imageView.isUserInteractionEnabled = true
        }
        
        nameDetailLabel.text = name
        durationLabel.text = "时长：\(buddha.duration ?? "")"
        addTimeLabel.text = "添加时间：\(buddha.addTime_zh ?? "")"
        userLabel.text = "作者：\(buddha.user ?? "")"
        pointsLabel.text = "积分：\(buddha.points ?? "")"
    }
    
    @objc private func singleTapping(_ recognizer: UIGestureRecognizer) {
        if let videoUrl = buddha.videoUrl, let url = URL(string:videoUrl) {
            //定义一个视频播放器
            let player = AVPlayer(url: url)
            let playerViewController = AVPlayerViewController()
            playerViewController.player = player
            self.present(playerViewController, animated: true) {
                playerViewController.player!.play()
            }
        }
    }
}

extension QLBuddhaViewController {

}
