//
//  CategoryInputViewController.swift
//  taskapp
//
//  Created by 藤田和磨 on 2018/10/03.
//  Copyright © 2018年 藤田和磨. All rights reserved.
//

import UIKit
import RealmSwift
import UserNotifications

class CategoryInputViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
        
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var nameField: UITextField!
    
    let realm = try! Realm()
    
    var categoryArray = try! Realm().objects(Category.self).sorted(byKeyPath: "id", ascending: false)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        // 背景をタップしたらdismissKeyboardメソッドを呼ぶように設定する
        let tabGesture: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action:#selector(dismissKeyboard))
        
        self.view.addGestureRecognizer(tabGesture)

        tableView.delegate = self
        tableView.dataSource = self
        
        // ナビゲーションバータイトルをセット
        // self.parent?.navigationItem.title = "カテゴリー編集"
        
        self.nameField.placeholder = "カテゴリーを入力"
        
        //ナビゲーションバー右のボタンを設定
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "保存", style: UIBarButtonItemStyle.plain, target: self, action:#selector(self.saveAction))
    }
    
    @objc func saveAction(){

        if !self.nameField.text!.isEmpty {
            try! realm.write {
                let category = Category()
                let allCategories = self.realm.objects(Category.self)
                print(allCategories)
                category.id = allCategories.count == 0 ? 1 : allCategories.max(ofProperty:"id")! + 1
                category.name = self.nameField.text!
                self.realm.add(category, update: true)
                self.nameField.text = ""
            }
            self.categoryArray = try! Realm().objects(Category.self).sorted(byKeyPath: "id", ascending: false)
            tableView.reloadData()
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: UITableViewDataSourceプロトコルのメソッド
    // データの数（＝セルの数）を返すメソッド
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categoryArray.count
    }
    
    // 各セルの内容を返すメソッド
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // 再利用可能な cell を得る
        let cell = tableView.dequeueReusableCell(withIdentifier: "CategoryCell", for: indexPath)
        let category = categoryArray[indexPath.row]
        cell.textLabel?.text = category.name
        return cell
    }

    // MARK: UITableViewDelegateプロトコルのメソッド
    // 各セルを選択した時に実行されるメソッド
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    }
    
    // セルが削除が可能なことを伝えるメソッド
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath)-> UITableViewCellEditingStyle {
        return .delete
    }
    
    // Delete ボタンが押された時に呼ばれるメソッド
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        
        if editingStyle == .delete {
            // データベースから削除する
            try! realm.write {
                let category = self.categoryArray[indexPath.row]
                let tasks = self.realm.objects(Task.self).filter("category == %@", category)
                for task in tasks {
                    task.category = nil
                }
                // let tasks = self.realm.objects(Task.self).filter("category_id == %@", category.id)
                // for task in tasks {
                //    task.category_id = 0
                // }
                self.realm.delete(category)
                tableView.deleteRows(at: [indexPath], with: .fade)
            }
        }
    }

    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
}
