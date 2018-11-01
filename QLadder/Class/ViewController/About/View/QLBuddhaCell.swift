//
//  QLBuddhaCell.swift
//  QLadder
//
//  Created by TonyHan on 2018/3/21.
//  Copyright © 2018年 TonyHan All rights reserved.
//

import UIKit
import Kingfisher

class QLBuddhaCell: UITableViewCell {
    
    @IBOutlet weak var nameLabel: UILabel!
    
    @IBOutlet weak var videoImageView: UIImageView!
    
    @IBOutlet weak var durationLabel: UILabel!
    
    @IBOutlet weak var addTimeLabel: UILabel!
    
    @IBOutlet weak var userLabel: UILabel!
    
    public var buddha: Buddha! {
        didSet {
            nameLabel.text = buddha.name
            
            var imgUrl = QueryManager.shared.covertImageUrl
            if !QueryManager.shared.covertMode && buddha.imgUrl != nil {
                imgUrl = buddha.imgUrl!
            }
            
            videoImageView.kf.setImage(with: URL(string: imgUrl))
            
            durationLabel.text = " \(buddha.duration ?? "") "
            addTimeLabel.text = buddha.addTime
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
        
        durationLabel.textColor = QLColor.C2
        durationLabel.font = UIFont.systemFont(ofSize: 12)
        durationLabel.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.8)
        durationLabel.layer.cornerRadius = 3
        durationLabel.layer.masksToBounds = true
        
        addTimeLabel.textColor = QLColor.C6
        addTimeLabel.font = UIFont.systemFont(ofSize: 12)
        
        userLabel.textColor = QLColor.C6
        userLabel.font = UIFont.systemFont(ofSize: 12)
    }

    
}
