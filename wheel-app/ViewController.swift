//
//  ViewController.swift
//  wheel-app
//
//  Created by MacServer on 2015/04/26.
//  Copyright (c) 2015年 Mobile Innovation, LLC. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation
import Alamofire
import SwiftyJSON

class ViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate {
    
    //Configクラス定義
    var config_cls:NSObject.Type = NSClassFromString("Configuration") as! NSObject.Type
    //地図ビュー
    @IBOutlet weak var MapView: MKMapView!
    @IBOutlet weak var InfoLabel: UILabel!
    @IBOutlet weak var InfoLabel2: UILabel!
    
    //ロケーションマネージャー
    var myLocationManager: CLLocationManager!
    //取得した緯度を保持するインスタンス
    var map_latitude: CLLocationDegrees!
    //取得した経度を保持するインスタンス
    var map_longitude: CLLocationDegrees!
    //初回緯度経度セットフラグ
    var map_FirstPointSet: Bool! = false
    //ピンの情報保存用構造体
    var pinInfo:[Info] = []
    var pinCount: Int = 0
    
    struct Info {
        var sortno: Int      // 順番設定用
        var type: String     // TYPE
        var id: Int64        // ID
        var lat: Double      // 緯度
        var lon: Double      // 経度
        var tagcount: Int    // タグの数
        var title: String    // 名前
        var subTitle: String //サブ名前
        var pinType: String  //ピンの種類
    }
    
    //ナビゲーション画面に遷移
    @IBAction func pushButton_NaviMap(sender: AnyObject) {
    }
    
    //ナビゲーション画面から戻ってきた場合
    @IBAction func unwindNavigationBackAction(segue: UIStoryboardSegue) {
    }
    
    //地図のトラッキングモード設定
    @IBAction func pushButton_Direction_PositionOnly(sender: AnyObject) {
        
        // 位置情報の更新を停止
        myLocationManager.stopUpdatingLocation()
        
        //Config用のクラス設定
        var config:Configuration = (config_cls() as! Configuration)
        config.setMapDirection(0)
        
        //初期フラグ設定解除
        self.map_FirstPointSet = false
        
        // 位置情報の更新を開始.
        myLocationManager.startUpdatingLocation()
    }
    
    //地図のトラッキングモード設定
    @IBAction func pushButton_Direction_CenterPosition(sender: AnyObject) {
        
        // 位置情報の更新を停止
        myLocationManager.stopUpdatingLocation()
        
        //Config用のクラス設定
        var config:Configuration = (config_cls() as! Configuration)
        config.setMapDirection(1)
        
        //初期フラグ設定解除
        self.map_FirstPointSet = false
        
        // 位置情報の更新を開始.
        myLocationManager.startUpdatingLocation()
    }
    
    //地図のトラッキングモード設定
    @IBAction func pushButton_Direction_NabiPosition(sender: AnyObject) {
        
        // 位置情報の更新を停止
        myLocationManager.stopUpdatingLocation()
        
        //Config用のクラス設定
        var config:Configuration = (config_cls() as! Configuration)
        config.setMapDirection(2)
        
        //初期フラグ設定解除
        self.map_FirstPointSet = false
        
        // 位置情報の更新を開始.
        myLocationManager.startUpdatingLocation()
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Config用のクラス設定
        var config:Configuration = (config_cls() as! Configuration)
        
        // LocationManagerの生成.
        myLocationManager = CLLocationManager()
        map_longitude = CLLocationDegrees()
        map_latitude = CLLocationDegrees()
        
        // Delegateの設定.
        myLocationManager.delegate = self
        
        // 位置情報取得の許可を求めるメッセージの表示．必須．
        myLocationManager.requestAlwaysAuthorization()
        // 位置情報の精度を指定
        myLocationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
        // 位置情報取得間隔を指定．指定した値（メートル）移動したら位置情報を更新する
        myLocationManager.distanceFilter = 0.1//10.0
        
        
        
        // セキュリティ認証のステータスを取得.
        let status = CLLocationManager.authorizationStatus()
        
        // まだ認証が得られていない場合は、認証ダイアログを表示.
        if(status == CLAuthorizationStatus.NotDetermined) {
            
            // まだ承認が得られていない場合は、認証ダイアログを表示.
            self.myLocationManager.requestAlwaysAuthorization()
        }
        
        self.MapView.showsUserLocation = false
        self.MapView.setUserTrackingMode(MKUserTrackingMode.None, animated: false)
        
        var theRegion: MKCoordinateRegion = self.MapView.region
        theRegion.span.longitudeDelta = 0.005
        theRegion.span.latitudeDelta = 0.005
        self.MapView.setRegion(theRegion, animated:true)
        self.MapView.showsUserLocation = true
        
        // 位置情報の更新を開始.
        myLocationManager.startUpdatingLocation()
        
    }
    
    // GPSから値を取得した際に呼び出されるメソッド.
    func locationManager(manager: CLLocationManager, didUpdateToLocation newLocation: CLLocation, fromLocation oldLocation: CLLocation){
        
        //Config用のクラス設定
        var config:Configuration = (config_cls() as! Configuration)
        
        // 取得した緯度がnewLocation.coordinate.longitudeに格納されている
        self.map_latitude = newLocation.coordinate.latitude
        // 取得した経度がnewLocation.coordinate.longitudeに格納されている
        self.map_longitude = newLocation.coordinate.longitude
        
        //緯度、経度の保存
        config.setMapLatitude(self.map_latitude)
        config.setMapLongitude(self.map_longitude)
        
        // 取得した緯度・経度をLogに表示
        NSLog("latiitude: \(self.map_latitude) , longitude: \(self.map_longitude)")
        
        //緯度経度表示
        InfoLabel.text = "latiitude: \(self.map_latitude) , longitude: \(self.map_longitude)"
        
        switch config.getMapDirection() {
        case 0://現在ポイントのみ
            InfoLabel2.text = "現在ポイントのみ"
            
            if (self.map_FirstPointSet == false) {
                self.MapView.showsUserLocation = true
                self.MapView.setUserTrackingMode(MKUserTrackingMode.None, animated: false)
                self.MapView.setUserTrackingMode(MKUserTrackingMode.Follow, animated: true)
                
                //初期フラグ設定解除
                self.map_FirstPointSet = true
                
                // 位置情報の更新を停止
                myLocationManager.stopUpdatingLocation()
            }
            
            //初期位置を設定
            var centerCoordinate : CLLocationCoordinate2D = CLLocationCoordinate2DMake(self.map_latitude,self.map_longitude)
            self.MapView.centerCoordinate = centerCoordinate
            
        case 1://ポイント無し
            InfoLabel2.text = "ポイント無し"
            
            if (self.map_FirstPointSet == false) {
                self.MapView.showsUserLocation = false
                self.MapView.setUserTrackingMode(MKUserTrackingMode.None, animated: true)
                
                //初期フラグ設定解除
                self.map_FirstPointSet = true
            }
            
        case 2://ナビゲーション表示
            InfoLabel2.text = "ナビゲーション表示"
            
            if (self.map_FirstPointSet == false) {
                
                
                
                
                //ズーム
                var theRegion: MKCoordinateRegion = self.MapView.region
                theRegion.span.longitudeDelta = 0.01
                theRegion.span.latitudeDelta = 0.01
                self.MapView.setRegion(theRegion, animated:true)
                self.MapView.showsUserLocation = true
                
                //初期フラグ設定解除
                self.map_FirstPointSet = true
            }
            
            self.MapView.showsUserLocation = true
            self.MapView.setUserTrackingMode(MKUserTrackingMode.None, animated: false)
            self.MapView.setUserTrackingMode(MKUserTrackingMode.FollowWithHeading, animated: true)
            
            //初期位置を設定
            var centerCoordinate : CLLocationCoordinate2D = CLLocationCoordinate2DMake(self.map_latitude,self.map_longitude)
            self.MapView.centerCoordinate = centerCoordinate
            
        default:
            break
        }
        
        
        //ピンの情報構造体の初期化
        var pinInfo:[Info] = []
        
        //ピンカウント初期化
        self.pinCount = 0
        
        // セット済みのピンを削除
        self.MapView.removeAnnotations(self.MapView.annotations)
        
        //APIへのURLとパラメータ設定
        let urlPath = "http://overpass-api.de/api/interpreter"
        var apiString:String = "[out:json];"
        apiString = apiString + "("
        apiString = apiString + "node['wheelchair:description'~'.'](around.a:500.0,\(self.map_latitude),\(self.map_longitude));"
        
        apiString = apiString + "node['amenity'~''](around.a:500.0,\(self.map_latitude),\(self.map_longitude));"
        
        apiString = apiString + "node['building'~''](around.a:500.0,\(self.map_latitude),\(self.map_longitude));"
        
        apiString = apiString + ");"
        // print resultsc
        apiString = apiString + "out body;"
        apiString = apiString + ">;"
        apiString = apiString + "out skel qt;"
        
        var para:NSDictionary = ["data": apiString];
        
        //リクエスト
        Alamofire.request(.GET, urlPath, parameters: ["data": apiString]).responseJSON { (request, response, responseData, error) -> Void in
            
            // titleを表示
            if let data: AnyObject = responseData {

                let json_data = JSON(data)
                let count: Int? = json_data["elements"].array?.count
                
                println(json_data["elements"])
                
                if let num = count {
                    for index in 0..<num {
                        //tag_name
                        let get_type: String? = json_data["elements"][index]["type"].string
                        if get_type?.isEmpty != nil {
                            //println("type is {\(get_type)}")
                        } else {
                            // errorの処理
                        }
                        let get_id: Int64? = json_data["elements"][index]["id"].int64
                        let get_lat: Double? = json_data["elements"][index]["lat"].double
                        let get_lon: Double? = json_data["elements"][index]["lon"].double
                        println("id is {\(get_id)}")
                        println("lat is {\(get_lat)}")
                        println("lon is {\(get_lon)}")
                        
                        var get_tag_name:String? = ""
                        var get_tag_note:String? = ""
                        var get_tag_noteja:String? = ""
                        var get_tag_wheelchair:String? = ""
                        var get_tag_highway:String? = ""
                        var get_tag_amenity:String? = ""
                        
                        var get_tag_AdminArea:String? = ""
                        var get_tag_PubFacAdmin:String? = ""
                        
                        var get_tagCount = 0
                        
                        let get_tags_array: Dictionary? = json_data["elements"][index]["tags"].dictionary
                        if(get_tags_array?.count > 0){
                            
                            //tag_name
                            get_tag_name = json_data["elements"][index]["tags"]["name"].string
                            if get_tag_name?.isEmpty != nil {
                                get_tagCount+=1
                                println("name is {\(get_tag_name)}")
                            } else {
                                // errorの処理
                            }
                            
                            //tag_note
                            get_tag_note = json_data["elements"][index]["tags"]["note"].string
                            if get_tag_note?.isEmpty != nil {
                                get_tagCount+=1
                                println("note is {\(get_tag_note)}")
                            } else {
                                // errorの処理
                            }
                            
                            //tag_noteja
                            get_tag_noteja = json_data["elements"][index]["tags"]["note:ja"].string
                            if get_tag_noteja?.isEmpty != nil {
                                get_tagCount+=1
                                println("noteja is {\(get_tag_noteja)}")
                            } else {
                                // errorの処理
                            }
                            
                            //tag_wheelchair
                            get_tag_wheelchair = json_data["elements"][index]["tags"]["wheelchair"].string
                            if get_tag_wheelchair?.isEmpty != nil {
                                get_tagCount+=1
                                println("wheelchair is {\(get_tag_wheelchair)}")
                            } else {
                                // errorの処理
                            }
                            
                            //tag_highway
                            get_tag_highway = json_data["elements"][index]["tags"]["highway"].string
                            if get_tag_highway?.isEmpty != nil {
                                get_tagCount+=1
                                println("name is {\(get_tag_highway)}")
                            } else {
                                // errorの処理
                            }
                            
                            //tag_amenity
                            get_tag_amenity = json_data["elements"][index]["tags"]["amenity"].string
                            if get_tag_amenity?.isEmpty != nil {
                                get_tagCount+=1
                                println("name is {\(get_tag_amenity)}")
                            } else {
                                // errorの処理
                            }
                            
                            
                            //tag_AdminArea
                            get_tag_AdminArea = json_data["elements"][index]["tags"]["KSJ2:AdminArea"].string
                            if get_tag_AdminArea?.isEmpty != nil {
                                get_tagCount+=1
                                println("name is {\(get_tag_AdminArea)}")
                            } else {
                                // errorの処理
                            }
                            
                            //tag_PubFacAdmin
                            get_tag_PubFacAdmin = json_data["elements"][index]["tags"]["KSJ2:PubFacAdmin"].string
                            if get_tag_PubFacAdmin?.isEmpty != nil {
                                get_tagCount+=1
                                println("name is {\(get_tag_PubFacAdmin)}")
                            } else {
                                // errorの処理
                            }
                            
                        }
                        
                        if(get_lat != nil){
                            if(get_lon != nil){
                            
                                var myPin: MKPointAnnotation = MKPointAnnotation()
                            
                                // 座標を設定
                                myPin.coordinate = CLLocationCoordinate2DMake(get_lat!, get_lon!);
                            
                                // タイトルを設定
                                myPin.title = get_tag_name
                            
                                // サブタイトルを設定
                                myPin.subtitle = "aaa"
                                
                                //地図情報を保存
                                self.pinInfo.append(Info(sortno:index, type:get_type!, id: get_id!, lat: get_lat!, lon: get_lon!,tagcount: get_tagCount, title: "", subTitle: "aaa", pinType: "bb"))
                            
                            
                                self.MapView.addAnnotation(myPin)
                        
                            }
                        }
                        
                    }
                }
            }
            
            // Error処理
            if let resError = error {
                println("Connection failed.\(resError.localizedDescription)")
                println("Failure:\(urlPath)")
            }
        }
    }
    
    /* 位置情報取得失敗時に実行される関数 */
    func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        // この例ではLogにErrorと表示するだけ．
        NSLog("Error")
    }
    
    // Regionが変更した時に呼び出されるメソッド.
    func mapView(mapView: MKMapView!, regionDidChangeAnimated animated: Bool) {
        println("regionDidChangeAnimated")
    }
    
    // 認証が変更された時に呼び出されるメソッド.
    func locationManager(manager: CLLocationManager!, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        switch status{
        case .AuthorizedWhenInUse:
            println("AuthorizedWhenInUse")
        case .AuthorizedAlways:
            println("AuthorizedAlways")
        case .Denied:
            println("Denied")
        case .Restricted:
            println("Restricted")
        case .NotDetermined:
            println("NotDetermined")
        default:
            println("etc.")
        }
    }
    
    func mapView(mapView: MKMapView!, viewForAnnotation annotation: MKAnnotation!) -> MKAnnotationView! {
        
        
        if annotation === mapView.userLocation { // 現在地を示すアノテーションの場合はデフォルトのまま
            let identifier = "annotation"
            if let annotationView = mapView.dequeueReusableAnnotationViewWithIdentifier("annotation") { // 再利用できる場合はそのまま返す
                return annotationView
            } else { // 再利用できるアノテーションが無い場合（初回など）は生成する
                let annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: identifier)
                annotationView.image = UIImage(named: "pin_wheel") // ここで好きな画像を設定します
                return annotationView
            }
        } else {
            let identifier = "annotation"
            if let annotationView = mapView.dequeueReusableAnnotationViewWithIdentifier("annotation") { // 再利用できる場合はそのまま返す
                return annotationView
            } else { // 再利用できるアノテーションが無い場合（初回など）は生成する
                let annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: identifier)
                
                if(self.pinInfo.count > 0){
                    switch (self.pinInfo[self.pinCount].type) {
                    case "node":
                        if(self.pinInfo[self.pinCount].tagcount == 0){
                            annotationView.image = UIImage(named: "pin_purple")
                        }else{
                            annotationView.image = UIImage(named: "pin_blue")
                        }
                    case "way":
                        annotationView.image = UIImage(named: "pin_gray")
                    case "relation":
                        annotationView.image = UIImage(named: "pin_green")
                    case "route":
                        annotationView.image = UIImage(named: "pin_orenge")
                    default:
                        break
                    }
                    self.pinCount += 1
                }
                
                return annotationView
            }
        }
    }
    
    struct Order {
        var model: String  // 型名
        var price: Int  // 単価
        var quantity: Int  // 個数
        func payment() -> Int {  // 支払額(read only)
            return price * quantity
        }
    }
    
}

