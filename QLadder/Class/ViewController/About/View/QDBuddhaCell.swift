//
//  QDBuddhaCell.swift
//  QLadder
//
//  Created by qd-hxt on 2018/3/21.
//  Copyright © 2018年 qding. All rights reserved.
//

import UIKit
import Kingfisher

class QDBuddhaCell: UITableViewCell {
    
    @IBOutlet weak var nameLabel: UILabel!
    
    @IBOutlet weak var videoImageView: UIImageView!
    
    @IBOutlet weak var timeLabel: UILabel!
    
    @IBOutlet weak var timeStampLabel: UILabel!
    
    @IBOutlet weak var userLabel: UILabel!
    
    public var buddha: Buddha! {
        didSet {
            nameLabel.text = buddha.name
            if let imgUrl = buddha.imgUrl {
//                let url = "https://timgsa.baidu.com/timg?image&quality=80&size=b9999_10000&sec=1521695385688&di=9e9de95b48c7c790be3cff64af36c6bb&imgtype=0&src=http%3A%2F%2Fstar.yule.com.cn%2Fuploadfile%2F2016%2F0926%2F20160926103248535.jpg"
                
                videoImageView.kf.setImage(with: URL(string: imgUrl))
            }
            timeLabel.text = " \(buddha.time ?? "") "
            timeStampLabel.text = buddha.timeStamp
            userLabel.text = buddha.user
        }
    }
    
    public class func identifier() -> String {
        return String(describing: self)
    }
    
    public class func height() -> CGFloat {
        return 110
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        selectionStyle = .none
        
        nameLabel.textColor = QLColor.C0
        nameLabel.font = UIFont.systemFont(ofSize: 17)
        nameLabel.numberOfLines = 3
        
        videoImageView.contentMode = .scaleAspectFill
        videoImageView.clipsToBounds = true
        videoImageView.backgroundColor = UIColor.lightGray
        
        timeLabel.textColor = QLColor.C2
        timeLabel.font = UIFont.systemFont(ofSize: 12)
        timeLabel.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.8)
        timeLabel.layer.cornerRadius = 3
        timeLabel.layer.masksToBounds = true
        
        timeStampLabel.textColor = QLColor.C6
        timeStampLabel.font = UIFont.systemFont(ofSize: 12)
        
        userLabel.textColor = QLColor.C6
        userLabel.font = UIFont.systemFont(ofSize: 12)
    }

    
}
