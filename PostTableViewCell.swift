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
    
//    @IBAction func commentButton(sender: UIButton) {
//        //let viewController = UIViewController()
//        //let storyboard = UIStoryboard()
//        let commentViewController = aViewController.storyboard!.instantiateViewControllerWithIdentifier("Comment")
//        aViewController.presentViewController(commentViewController, animated: true, completion: nil)
//    }

    

    

    
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
        
        if postData.comment != nil {
            var resultArrya:[AnyObject] = []
            for ele in postData.comment! {
                if let itemArray:[String] = ele.componentsSeparatedByString("<,>") {
                    resultArrya.append(itemArray)
                }
            }
        }
    }
    
}
