//
//  Category.swift
//  taskapp
//
//  Created by 藤田和磨 on 2018/10/03.
//  Copyright © 2018年 藤田和磨. All rights reserved.
//

import RealmSwift

class Category: Object {
    // 管理用 ID。プライマリーキー
    @objc dynamic var id = 0
    
    // タイトル
    @objc dynamic var name = ""
    
    /**
     id をプライマリーキーとして設定
     */
    override static func primaryKey() -> String? {
        return "id"
    }
}
