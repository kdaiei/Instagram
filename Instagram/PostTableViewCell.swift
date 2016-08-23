//
//  PostTableViewCell.swift
//  Instagram
//
//  Created by kobayashi on 2016/08/19.
//  Copyright © 2016年 hirotaka.kobayashi. All rights reserved.
//

import UIKit

class PostTableViewCell: UITableViewCell {
    
    @IBOutlet weak var postImageView: UIImageView!
    @IBOutlet weak var likeButton: UIButton!
    @IBOutlet weak var likeLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!

    @IBOutlet weak var captionLabel: UILabel!
    @IBOutlet weak var commentLabel: UILabel!
    @IBOutlet weak var commentButton: UIButton!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }

    
    func setPostData(postData: PostData) {
        postImageView.image = postData.image
        captionLabel.text = "\(postData.name!) : \(postData.caption!)"
        let likeNumber = postData.likes.count
        likeLabel.text = "\(likeNumber)"
        
        let formatter = NSDateFormatter()
        formatter.locale = NSLocale(localeIdentifier: "ja_JP")
        formatter.dateFormat = "yyyy-MM-dd HH:mm"
        
        let dateString:String = formatter.stringFromDate(postData.date!)
        dateLabel.text = dateString
        
        if postData.isLiked {
            let buttonImage = UIImage(named: "like_exist")
            likeButton.setImage(buttonImage, forState: UIControlState.Normal)
        } else {
            let buttonImage = UIImage(named: "like_none")
            likeButton.setImage(buttonImage, forState: UIControlState.Normal)
        }
        
        if postData.comment != nil && 0 < postData.comment?.count {
            //print("comment cell kita!")
            var cnt = 0
            let attributedString = NSMutableAttributedString()
            for ele in postData.comment! {
                // タイムラインのコメントは３件まで表示する
                // それ以降が見たいときはコメントをタップしてコメント画面で確認する。
                if 2 < cnt {
                    break
                }
                cnt += 1
                
                // 表示用のコメントを組み立てる
                if let itemArray:[String] = ele.componentsSeparatedByString("<,>") {
                    var newLine = ""
                    if 0 < attributedString.length {
                        newLine = "\n"
                    }
                    let normalText = NSMutableAttributedString(string: itemArray[2] + "\n")
                    let boldText = newLine + itemArray[1] + ": "
                    
                    let attrs = [NSFontAttributeName : UIFont.boldSystemFontOfSize(13)]
                    let boldString = NSMutableAttributedString(string: boldText, attributes:attrs)
                    
                    attributedString.appendAttributedString(boldString)
                    attributedString.appendAttributedString(normalText)
                }
            }
            commentLabel.attributedText = attributedString
        } else {
            commentLabel.text = "なし"
        }
    }
    
}
