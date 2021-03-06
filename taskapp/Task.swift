//
//  Task.swift
//  taskapp
//
//  Created by 藤田和磨 on 2018/10/03.
//  Copyright © 2018年 藤田和磨. All rights reserved.
//

import RealmSwift

class Task: Object {
    // 管理用 ID。プライマリーキー
    @objc dynamic var id = 0
    
    // タイトル
    @objc dynamic var title = ""
    
    // 内容
    @objc dynamic var contents = ""
    
    /// 日時
    @objc dynamic var date = Date()
    
    /// カテゴリーID
    // @objc dynamic var category_id = 0
    
    // カテゴリーオブジェクト
    @objc dynamic var category: Category?
    
    /**
     id をプライマリーキーとして設定
     */
    override static func primaryKey() -> String? {
        return "id"
    }
}
