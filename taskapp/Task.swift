//
//  Task.swift
//  taskapp
//
//  Created by 岡本 翔真 on 2020/04/16.
//  Copyright © 2020 shoma.okamoto. All rights reserved.
//

import Foundation
import RealmSwift

class Task: Object {
    //管理用 ID。プライマリーキー
    @objc dynamic var id = 0
    //タイトル
    @objc dynamic var title = ""
    //内容
    @objc dynamic var contents = ""
    //日時
    @objc dynamic var date = Date()
    
    //idをプライマリーキーとして設定
    override static func primaryKey() -> String? {
        return "id"
    }
}
