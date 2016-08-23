//
//  HomeViewController.swift
//  Instagram
//
//  Created by kobayashi on 2016/08/18.
//  Copyright © 2016年 hirotaka.kobayashi. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
import FirebaseDatabase


var g_currentID:NSIndexPath!
var g_postArray: [PostData] = []
var g_userName:String = ""
var g_tableViewScrollBefore:CGFloat = 0
var g_viewDidLoadFlag = true

class HomeViewController: UIViewController, UITableViewDataSource, UITableViewDelegate,UIGestureRecognizerDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        let nib = UINib(nibName: "PostTableViewCell", bundle: nil)
        tableView.registerNib(nib, forCellReuseIdentifier: "Cell")
        //tableView.rowHeight = 500.0
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.contentOffset.y = g_tableViewScrollBefore
        
        // 初回はTableViewを再表示せずに終了する。
        if g_viewDidLoadFlag {
            g_viewDidLoadFlag = false
            return
        }

        // print("viewDidLoad kita!")
        // 要素が追加されたらpostArrayに追加してTableViewを再表示する
        FIRDatabase.database().reference().child(CommonConst.PostPATH).observeEventType(.ChildAdded, withBlock: { snapshot in
            //print("A kita!")
            
            // PostDataクラスを生成して受け取ったデータを設定する
            if let uid = FIRAuth.auth()?.currentUser?.uid {
                let postData = PostData(snapshot: snapshot, myId: uid)
                
                
                // 保持している配列からidが同じものを探す
                var index: Int = 0
                var consistent = false
                for post in g_postArray {
                    if post.id == postData.id {
                        consistent = true
                        index = g_postArray.indexOf(post)!
                        break
                    }
                }
                
                if 0 != g_postArray.count && consistent {
                    // 差し替えるため一度削除する
                    g_postArray.removeAtIndex(index)
                }
                // 削除したところに更新済みのでデータを追加する
                g_postArray.insert(postData, atIndex: index)

                
                // TableViewを再表示する
                self.tableView.reloadData()
            }
        })
        
        // 要素が変更されたら該当のデータをpostArrayから一度削除した後に新しいデータを追加してTableViewを再表示する
        FIRDatabase.database().reference().child(CommonConst.PostPATH).observeEventType(.ChildChanged, withBlock: { snapshot in
            //print("B kita!")
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
                
                // TableViewの現在表示されているセルを更新する
                self.tableView.reloadData()
            }
        })
        
        // TableViewを前回表示したスクロール位置に表示する
        self.tableView.contentOffset.y = g_tableViewScrollBefore
        
    }
    
    
    // セル数を返す
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return g_postArray.count
    }
    
    
    // セルを設定する
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        // セルを取得してデータを設定する
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as! PostTableViewCell
        cell.setPostData(g_postArray[indexPath.row])
        
        // ライクボタンタップした時のイベントを追加
        cell.likeButton.addTarget(self, action:#selector(handleButton(_:event:)), forControlEvents:  UIControlEvents.TouchUpInside)
        
        // コメントボタンをタップするとコメント投稿画面に遷移するイベント追加
        cell.commentButton.addTarget(self, action: #selector(handleCommentButton(_:event:)), forControlEvents: UIControlEvents.TouchUpInside)
        
        // コメントをタップするとコメント投稿画面に遷移する
        // シングルタップ
        let tapGesture:UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(HomeViewController.tapped(_:)))
        
        // デリゲートをセット
        tapGesture.delegate = self;
        cell.commentLabel.addGestureRecognizer(tapGesture)
        
        
        return cell
    }
    
    
    func tableView(tableView: UITableView, estimatedHeightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        // Auto Layoutを使ってセルの高さを動的に変更する
        return UITableViewAutomaticDimension
    }
    
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        // セルをタップされたら何もせずに選択状態を解除する
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
    
    // セル内のボタンがタップされた時に呼ばれるメソッド
    func handleButton(sender: UIButton, event:UIEvent) {
        
        // タップされたセルのインデックスを求める
        let touch = event.allTouches()?.first
        let point = touch!.locationInView(self.tableView)
        let indexPath = tableView.indexPathForRowAtPoint(point)
        
        setData(indexPath!)
    }
    
    
    // ライクの変更内容をFirebaseに保存する
    func setData(indexPath:NSIndexPath) {
        // 配列からタップされたインデックスのデータを取り出す
        let postData = g_postArray[indexPath.row]
        
        // Firebaseに保存するデータの準備
        if let uid = FIRAuth.auth()?.currentUser?.uid {
            if postData.isLiked {
                // すでにいいねをしていた場合はいいねを解除するためIDを取り除く
                var index = -1
                for likeId in postData.likes {
                    if likeId == uid {
                        // 削除するためにインデックスを保持しておく
                        index = postData.likes.indexOf(likeId)!
                        break
                    }
                }
                postData.likes.removeAtIndex(index)
            } else {
                postData.likes.append(uid)
            }
            
            let imageString = postData.imageString
            let name = postData.name
            let caption = postData.caption
            let time = (postData.date?.timeIntervalSinceReferenceDate)! as NSTimeInterval
            let likes = postData.likes
            let comment = postData.comment
            
            // 辞書を作成してFirebaseに保存する
            let post = ["caption": caption!, "image": imageString!, "name": name!, "time": time, "likes": likes, "comment": comment!]
            let postRef = FIRDatabase.database().reference().child(CommonConst.PostPATH)
            postRef.child(postData.id!).setValue(post)
        }
    }
    
    // コメントボタンをタップ時にコメント投稿画面に遷移する
    func handleCommentButton(sender: UIButton, event:UIEvent) {
        // tableViewのスクロール位置をセットする
        print(self.tableView.contentOffset.y)
        g_tableViewScrollBefore = self.tableView.contentOffset.y
        
        // タップされたセルのインデックスを求める
        let touch = event.allTouches()?.first
        let point = touch!.locationInView(self.tableView)
        g_currentID = tableView.indexPathForRowAtPoint(point)
        
        let commentViewController = storyboard!.instantiateViewControllerWithIdentifier("Comment")
        presentViewController(commentViewController, animated: true, completion: nil)
    }
    
    // コメントをタップ時にコメント投稿画面に遷移する
    func tapped(sender: UITapGestureRecognizer){
        //print("tapped kita!")
        // tableViewのスクロール位置をセットする
        g_tableViewScrollBefore = self.tableView.contentOffset.y
        
        // タップされたセルのインデックスを求める
        let point = sender.locationInView(self.tableView)
        g_currentID = tableView.indexPathForRowAtPoint(point)
        
        let commentViewController = storyboard!.instantiateViewControllerWithIdentifier("Comment")
        presentViewController(commentViewController, animated: true, completion: nil)
    }
    
}
