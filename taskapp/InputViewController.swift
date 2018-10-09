//
//  InputViewController.swift
//  taskapp
//
//  Created by 藤田和磨 on 2018/10/03.
//  Copyright © 2018年 藤田和磨. All rights reserved.
//

import UIKit
import RealmSwift
import UserNotifications

class InputViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {

    @IBOutlet weak var titleTextField: UITextField!
    
    @IBOutlet weak var contentsTextView: UITextView!
    
    @IBOutlet weak var datePicker: UIDatePicker!

    @IBOutlet weak var categoryPicker: UIPickerView!
    
    var task: Task!
    
    let realm = try! Realm()
    
    // var categoryArray = try! Realm().objects(Category.self).sorted(byKeyPath: "id", ascending: false)
    var categoryArray: Array<Category>!
    
    var category_row: Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        // 背景をタップしたらdismissKeyboardメソッドを呼ぶように設定する
        let tabGesture: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action:#selector(dismissKeyboard))
        
        self.view.addGestureRecognizer(tabGesture)
        
        self.categoryPicker.delegate = self
        self.categoryPicker.dataSource = self
        
        // プレースホルダー設定
        self.titleTextField.placeholder = "タイトルを入力"
        //ナビゲーションバー右のボタンを設定
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "保存", style: UIBarButtonItemStyle.plain, target: self, action:#selector(self.saveAction))
        
        // 入力フィールド初期値設定
        titleTextField.text = task.title
        contentsTextView.text = task.contents
        datePicker.date = task.date
        
        // カテゴリ初期値設定
        self.initCategories()
        
        var category_index: Int = 0
        if task.category != nil {
            // タスクからカテゴリ取得->配列index取得
            let category = self.realm.objects(Category.self).filter("id == %@", task.category?.id as Any).first
            category_index = self.categoryArray.index(of: category!)!
        }
        // カテゴリPicker初期値設定
        categoryPicker.selectRow(category_index, inComponent: 0, animated: true)
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
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    @objc func saveAction () {
        try! self.realm.write {
            
            self.task.title = self.titleTextField.text!
            self.task.contents = self.contentsTextView.text
            self.task.date = self.datePicker.date
            // self.task.category_id = self.category_row != 0 ? self.categoryArray[self.category_row].id : 0
            if self.category_row != 0 {
                self.task.category = self.categoryArray[self.category_row]
            }
            self.realm.add(self.task, update: true)
        }
        setNotification(task: self.task)
        self.navigationController?.popViewController(animated: true)
    }

/*
    override func viewWillDisappear(_ animated: Bool) {

        try! self.realm.write {
            self.task.title = self.titleTextField.text!
            self.task.contents = self.contentsTextView.text
            self.task.date = self.datePicker.date
            self.realm.add(self.task, update: true)
        }
        
        setNotification(task: self.task)
        super.viewWillAppear(animated)
    }
*/
    
    func setNotification(task :Task) {
        let content = UNMutableNotificationContent()
        
        if task.title == "" {
            content.title = "(タイトルなし)"
        }
        else {
            content.title = task.title
        }
        
        if task.contents == "" {
            content.body = "(本文なし)"
        }
        else {
            content.body = task.contents
        }
        content.sound = UNNotificationSound.default()
        
        // ローカル通知が発動するtrigger（日付マッチ）を作成
        let calendar = Calendar.current
        let dateComponents = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: task.date)
        let trigger = UNCalendarNotificationTrigger.init(dateMatching: dateComponents, repeats: false)
        
        // identifier, content, triggerからローカル通知を作成（identifierが同じだとローカル通知を上書き保存）
        let request = UNNotificationRequest.init(identifier: String(task.id), content: content, trigger: trigger)
        
        // ローカル通知を登録
        let center = UNUserNotificationCenter.current()
        center.add(request) { (error) in
            print(error ?? "ローカル通知登録 OK")  // error が nil ならローカル通知の登録に成功したと表示します。errorが存在すればerrorを表示します。
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
        self.category_row = row
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.categoryPicker.reloadAllComponents()
    }
}
