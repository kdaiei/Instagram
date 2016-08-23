//
//  CommentViewController.swift
//  Instagram
//
//  Created by kobayashi on 2016/08/21.
//  Copyright © 2016年 hirotaka.kobayashi. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
import SVProgressHUD


class commentViewController: UIViewController, UITextViewDelegate, UITableViewDataSource, UITableViewDelegate {
    
    var commentArray:[String] = []
    
    @IBOutlet weak var commentField: UITextView!
    
    @IBOutlet weak var commentFieldStyleBottom: NSLayoutConstraint!

    @IBOutlet weak var comentFieldStyleHeight: NSLayoutConstraint!
    
    @IBOutlet weak var commentFieldViewStyleHeight: NSLayoutConstraint!
    
    @IBOutlet weak var commentTableView: UITableView!
    
    @IBAction func backHomeButton(sender: AnyObject) {
        // キーボードを閉じる
        self.view.endEditing(true)
        // 画面を閉じる
        self.dismissViewControllerAnimated(true, completion: nil)
        //let homeViewController = self.storyboard?.instantiateViewControllerWithIdentifier("Home")
        //self.presentViewController(homeViewController!, animated: true, completion: nil)
    }

    
    // コメント送信ボタンを押した
    @IBAction func sendMessageButton(sender: UIButton) {
        if let uid = FIRAuth.auth()?.currentUser?.uid {
            let sendString:String = uid + "<,>" + g_userName + "<,>" + commentField.text
            if let indexPath = g_currentID {
                setCommentData(indexPath, comment: sendString)
                // TableViewを再表示する
                //commentTableView.reloadData()
                commentField.text = ""
            }
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // commentArrayを更新する
        if let indexPath = g_currentID {
            if let aArray:[String] = g_postArray[indexPath.row].comment! {
                commentArray = aArray
            }
        }
        
        // 要素が変更されたら該当のデータをpostArrayから一度削除した後に新しいデータを追加してTableViewを再表示する
        FIRDatabase.database().reference().child(CommonConst.PostPATH).observeEventType(.ChildChanged, withBlock: { snapshot in
            if let uid = FIRAuth.auth()?.currentUser?.uid {
                // PostDataクラスを生成して受け取ったデータを設定する
                let postData = PostData(snapshot: snapshot, myId: uid)
                
                // 保持している配列からidが同じものを探す
                var index: Int = 0
                for post in g_postArray {
                    if post.id == postData.id {
                        index = g_postArray.indexOf(post)!
                        break
                    }
                }
                
                // 差し替えるため一度削除する
                g_postArray.removeAtIndex(index)
                
                // 削除したところに更新済みのでデータを追加する
                g_postArray.insert(postData, atIndex: index)
                
                // commentArrayを更新する
                if let indexPath = g_currentID {
                    if let aArray:[String] = g_postArray[indexPath.row].comment! {
                        self.commentArray = aArray
                    }
                }
                
                // commentTableViewの現在表示されているセルを更新する
                self.commentTableView.reloadData()
            }
        })
        
        
        
        // キーボードが開かれたことを検出するイベントを設定
        let notificationCenter = NSNotificationCenter.defaultCenter()
        //notificationCenter.addObserver(self, selector: "showKeyboard:", name: UIKeyboardDidShowNotification, object: nil)
        notificationCenter.addObserver(self, selector: #selector(commentViewController.showKeyboard(_:)), name: UIKeyboardDidShowNotification, object: nil)
        
         // 始めからキーボードを開く
        commentField.becomeFirstResponder()
        
        //
        commentField.delegate = self;
        
        commentTableView.delegate = self
        commentTableView.dataSource = self
        
        let nib = UINib(nibName: "commentTableViewCell", bundle: nil)
        commentTableView.registerNib(nib, forCellReuseIdentifier: "commentCell")
        commentTableView.estimatedRowHeight = 70.0
        commentTableView.rowHeight = UITableViewAutomaticDimension
        

    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // テーブルの数を返す
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return commentArray.count
    }
    
    // テーブルのセルをセットする
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        // セルを取得してデータを設定する
        let cell = tableView.dequeueReusableCellWithIdentifier("commentCell", forIndexPath: indexPath) as! commentTableViewCell
        
        if let aComment:String = commentArray[indexPath.row] {
            if let aArray:[String] = aComment.componentsSeparatedByString("<,>") {
                cell.setComentData(aArray[1], comment: aArray[2])
            }
        }
        
        return cell
    }
    
 
    
    // キーボードの高さを取得する
    func showKeyboard(notification:NSNotification){
        
        if let userInfo = notification.userInfo{
            if let keyboard = userInfo[UIKeyboardFrameEndUserInfoKey] as? NSValue{
                let keyBoardRect = keyboard.CGRectValue()
                let keyBoardHeight = keyBoardRect.size.height
                //print("kye height = \(keyBoardRect.size.height)")
                
                commentFieldStyleBottom!.constant = keyBoardHeight
            }
        }
    }
    
    // コメントフィールドに入力した時に行数に合わせてフィールドの高さを調節する
    func textViewDidChange(textView: UITextView) {
        let maxHeight = 74.25  // 入力フィールドの最大サイズ
        let miniHeight = 24.75 // 入力フィールドの最小サイズ
        // 現在のテキストにフィットするサイズ
        let size:CGSize = commentField.sizeThatFits(commentField.frame.size)
        let fitHeight = Double(size.height)
        let fieldHeight = commentField.frame.size.height.native
        var result = false
        if fitHeight > fieldHeight {
            result = commentField.frame.size.height.native + 24.75 <= maxHeight
        } else {
            result = commentField.frame.size.height.native >= miniHeight
        }
        if result {
            comentFieldStyleHeight!.constant = size.height
            commentFieldViewStyleHeight!.constant = size.height + 30
        }
    }
    
    func setCommentData(indexPath:NSIndexPath, comment:String) {
        // 配列からタップされたインデックスのデータを取り出す
        let postData = g_postArray[indexPath.row]
        
        // Firebaseに保存するデータの準備
            
        let imageString = postData.imageString
        let name = postData.name
        let caption = postData.caption
        let time = (postData.date?.timeIntervalSinceReferenceDate)! as NSTimeInterval
        let likes = postData.likes
        var commentArray:[String]? = []
        
        if nil == postData.comment {
            commentArray = []
        } else {
            commentArray! = postData.comment!
        }
        commentArray?.insert(comment, atIndex: 0)

        
        // 辞書を作成してFirebaseに保存する
        let post = ["caption": caption!, "image": imageString!, "name": name!, "time": time, "likes": likes, "comment": commentArray!]
        let postRef = FIRDatabase.database().reference().child(CommonConst.PostPATH)
        postRef.child(postData.id!).setValue(post)
    }

}