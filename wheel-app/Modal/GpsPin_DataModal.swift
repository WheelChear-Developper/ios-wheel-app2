//
//  GpsPin_DataModal.swift
//  wheel-app
//
//  Created by MacServer on 2015/05/13.
//  Copyright (c) 2015年 Mobile Innovation, LLC. All rights reserved.
//

import UIKit

@objc(GpsPin_DataModal)
class GpsPin_DataModal: NSObject {
    
    struct Info {
        var sortno: Int      // 順番設定用
        var type: String     // TYPE
        var id: Int64        // ID
        var lat: Double      // 緯度
        var lon: Double      // 経度
        var title: String    // 名前
        var subTitle: String //サブ名前
        var pinType: String  //ピンの種類
    }
}
