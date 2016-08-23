//
//  PostData.swift
//  Instagram
//
//  Created by kobayashi on 2016/08/19.
//  Copyright © 2016年 hirotaka.kobayashi. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase

//class Comment : NSObject {
//    var uid:  String?
//    var name: String?
//    var text: String?
//    
//    init(uid:String, name:String, text:String) {
//        self.uid = uid
//        self.name = name
//        self.text = text
//    }
//}

class PostData: NSObject {
    var id: String?
    var image: UIImage?
    var imageString: String?
    var name: String?
    var caption: String?
    var date: NSDate?
    var likes: [String] = []
    var isLiked: Bool = false
    var comment: [String]? = []
    
    init(snapshot: FIRDataSnapshot, myId: String) {
        id = snapshot.key
        
        let valueDictionary = snapshot.value as! [String: AnyObject]
        
        imageString = valueDictionary["image"] as? String
        image = UIImage(data: NSData(base64EncodedString: imageString!, options: .IgnoreUnknownCharacters)!)
        
        name = valueDictionary["name"] as? String
        
        caption = valueDictionary["caption"] as? String
        
        if let likes = valueDictionary["likes"] as? [String] {
            self.likes = likes
        }
        
        for likeId in likes {
            if likeId == myId {
                isLiked = true
                break
            }
        }
        
        self.date = NSDate(timeIntervalSinceReferenceDate: valueDictionary["time"] as! NSTimeInterval)
        
        if let comment = valueDictionary["comment"] as? [String] {
            self.comment = comment
        }
    }
}
