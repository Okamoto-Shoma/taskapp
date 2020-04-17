//
//  ViewController.swift
//  taskapp
//
//  Created by 岡本 翔真 on 2020/04/16.
//  Copyright © 2020 shoma.okamoto. All rights reserved.
//

import UIKit
import RealmSwift
import UserNotifications

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var category: UITextField!
    
    //Realmインスタンスを取得
    let realm = try! Realm()
    
    
    //DB内のタスクが格納されるリスト。
    //日付の近い順でソート:昇順
    //以降内容をアップデートするとリスト内は自動的に更新される。
    var taskArray = try! Realm().objects(Task.self).sorted(byKeyPath: "date", ascending: true)
    
    
    
    //カテゴリー検索された際に昇順ソート
    //var categoryArray = try! Realm().objects(Task.self).sorted(byKeyPath: "category", ascending: true)
    

//MARK: - Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        tableView.delegate = self
        tableView.dataSource = self
    }
    //segueで画面遷移する時
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let inputViewController: InputViewController = segue.destination as! InputViewController
        
        if segue.identifier == "cellSegue" {
            let indexPath = self.tableView.indexPathForSelectedRow
            inputViewController.task = taskArray[indexPath!.row]
        } else {
            let task = Task()
            let allTasks = realm.objects(Task.self)
            if allTasks.count != 0 {
                task.id = allTasks.max(ofProperty: "id")! + 1
            }
            inputViewController.task = task
        }
    }
    
//MARK: -Action
    @IBAction func searchbutton(_ sender: UIButton) {
        guard let inputCategoryField = category.text, !inputCategoryField.isEmpty else {
            self.taskArray = try! Realm().objects(Task.self).sorted(byKeyPath: "date", ascending: true)
            tableView.reloadData()
            return
        }
        let predicate = NSPredicate(format: "category = %@", inputCategoryField)
        self.taskArray = realm.objects(Task.self).filter(predicate).sorted(byKeyPath: "category", ascending: true)
        print(taskArray)
        
        tableView.reloadData()
    }
    
 
//MARK: - メソッド
    
    //データの数を返すメソッド
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return taskArray.count
    }
    //各セルの内容を返すメソッド
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //再利用可能なcellを得る
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        //Cellに値を設定する
        let task = taskArray[indexPath.row]
        cell.textLabel?.text = task.title
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyy-MM-dd HH:mm"
        
        let dateString:String = formatter.string(from: task.date)
        cell.detailTextLabel?.text = dateString
        
        return cell
    }
    
    //各セルを選択した時に実行されるメソッド
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "cellSegue", sender: nil)
    }
    
    //セルが削除が可能なことを伝えるメソッド
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return .delete
    }
    
    //Deleteボタンが押された時に呼ばれたメソッド
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            //削除するタスクを取得
            let task = self.taskArray[indexPath.row]
            
            //ローカル通知をキャンセルする
            let center = UNUserNotificationCenter.current()
            center.removePendingNotificationRequests(withIdentifiers: [String(task.id)])
            
            //データベースから削除
            try! realm.write {
                self.realm.delete(task)
                tableView.deleteRows(at: [indexPath], with: .fade)
            }
            
            //未通知のローカル通知一覧をログ出力
            center.getPendingNotificationRequests { (requests: [UNNotificationRequest]) in
                for request in requests {
                    print("/-------------------------------------------------------------")
                    print(request)
                    print("-------------------------------------------------------------/")
                }
            }
        }
    }
    

    
    //入力画面から戻ってきた時にTableViewを更新させる
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
    }
}

