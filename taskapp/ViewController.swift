//
//  ViewController.swift
//  taskapp
//
//  Created by 藤田和磨 on 2018/10/03.
//  Copyright © 2018年 藤田和磨. All rights reserved.
//

import UIKit
import RealmSwift
import UserNotifications

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate, UIPickerViewDelegate, UIPickerViewDataSource {
    
    @IBOutlet weak var categoryPicker: UIPickerView!
    
    @IBOutlet weak var searchBar: UISearchBar!
    
    @IBOutlet weak var tableView: UITableView!
    
    var seach_execute: Bool = false
    
    let realm = try! Realm()
    
    var taskArray = try! Realm().objects(Task.self).sorted(byKeyPath: "date", ascending: false)

    var searchResults: Results<Task>!

    // var categoryArray = try! Realm().objects(Category.self).sorted(byKeyPath: "id", ascending: false)
    var categoryArray: Array<Category>! = Array()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.categoryPicker.delegate = self
        self.categoryPicker.dataSource = self
        // カテゴリPicker初期値設定
        self.initCategories()
        self.categoryPicker.showsSelectionIndicator = true
        self.categoryPicker.selectRow(0, inComponent: 0, animated: true)
        // カテゴリ検索バー初期値設定
        self.searchBar.delegate = self
        self.searchBar.searchBarStyle = UISearchBarStyle.default
        self.searchBar.placeholder = "カテゴリー検索"
        self.searchBar.setValue("キャンセル", forKey: "_cancelButtonText")
        // self.tableView.tableHeaderView = searchBar
    }
    
    private func initCategories() {
        // カテゴリ初期値設定
        self.categoryArray = Array(try! Realm().objects(Category.self).sorted(byKeyPath: "id", ascending: false))
        
        if self.categoryArray != nil {
            let category = Category()
            category.id = 0
            category.name = "選択してください"

            self.categoryArray.insert(category, at: 0)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // 検索ボタンが押された時に呼ばれる
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        self.view.endEditing(true)
        searchBar.showsCancelButton = true
        self.categorySearch(category_name: self.searchBar.text)
    }
    
    // キャンセルボタンが押された時に呼ばれる
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        self.searchBar.showsCancelButton = false
        self.view.endEditing(true)
        self.searchBar.text = ""
        self.seach_execute = false
        self.tableView.reloadData()
    }
    
    // テキストフィールド入力開始前に呼ばれる
    func searchBarShouldBeginEditing(_ searchBar: UISearchBar) -> Bool {
        searchBar.showsCancelButton = true
        return true
    }
    
    private func categorySearch(category_name: String!) {
        self.searchResults = self.realm.objects(Task.self).filter("category.name == %@", category_name!)
        self.seach_execute = true
        self.tableView.reloadData()
    }
    
    // UIPickerViewの列の数
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    // UIPickerViewの行数、要素の全数
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        self.initCategories()
        return self.categoryArray != nil ? self.categoryArray.count : 0
    }
    
    // UIPickerViewに表示する配列
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        self.initCategories()
        return self.categoryArray != nil ? self.categoryArray[row].name : ""
    }
    
    // UIPickerViewのRowが選択された時の挙動
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if row == 0 {
            self.seach_execute = false
            self.tableView.reloadData()
        } else {
            self.categorySearch(category_name: self.categoryArray[row].name)
        }
    }
    
    // MARK: UITableViewDataSourceプロトコルのメソッド
    // データの数（＝セルの数）を返すメソッド
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.seach_execute ? self.searchResults.count : self.taskArray.count
    }
    
    // 各セルの内容を返すメソッド
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // 再利用可能な cell を得る
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        
        // Cellに値を設定する.
        let task = self.seach_execute ? self.searchResults[indexPath.row] : self.taskArray[indexPath.row]
        // let task = self.taskArray[indexPath.row]
        
        cell.textLabel?.text = task.title
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm"
        
        let dateString:String = formatter.string(from: task.date)
        cell.detailTextLabel?.text = dateString
        
        return cell
    }
    
    // MARK: UITableViewDelegateプロトコルのメソッド
    // 各セルを選択した時に実行されるメソッド
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "cellSegue", sender: nil)
    }
    
    // セルが削除が可能なことを伝えるメソッド
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath)-> UITableViewCellEditingStyle {
        return .delete
    }
    
    // Delete ボタンが押された時に呼ばれるメソッド
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        
        if editingStyle == .delete {
            
            // 削除されたタスクを取得する
            let task = self.seach_execute ? self.searchResults[indexPath.row] : self.taskArray[indexPath.row]
            // let task = self.taskArray[indexPath.row]
            
            // ローカル通知をキャンセルする
            let center = UNUserNotificationCenter.current()
            center.removePendingNotificationRequests(withIdentifiers: [String(task.id)])
            
            // データベースから削除する
            try! realm.write {
                self.realm.delete(task)
                tableView.deleteRows(at: [indexPath], with: .fade)
            }
            
            // 未通知のローカル通知一覧をログ出力
            center.getPendingNotificationRequests { (requests: [UNNotificationRequest]) in
                for request in requests {
                    print("/---------------")
                    print(request)
                    print("---------------/")
                }
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        let inputViewController:InputViewController = segue.destination as! InputViewController
        
        if segue.identifier == "cellSegue" {
            let indexPath = self.tableView.indexPathForSelectedRow
            inputViewController.task = self.seach_execute ? self.searchResults[indexPath!.row] : self.taskArray[indexPath!.row]
        }
        else {
            let task = Task()
            task.date = Date()
            let allTasks = self.realm.objects(Task.self)
            task.id = allTasks.count == 0 ? 1 : allTasks.max(ofProperty:"id")! + 1
            inputViewController.task = task
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
        self.categoryPicker.reloadAllComponents()
    }
}

