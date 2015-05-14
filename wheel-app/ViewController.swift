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
//import Alamofire_SwiftyJSON

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
    var pinInfo:[GpsPin_DataModal.Info] = []
    
    struct Info {
        var id: Double       // ID
        var lat: Double      // 緯度
        var lon: Double      // 経度
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
        
        
        
        
        var apiString:String = "[out:json];"
        apiString = apiString + "("
        apiString = apiString + "node['wheelchair:description'~'.'](around.a:500.0,\(self.map_latitude),\(self.map_longitude));way['wheelchair:description'~'.'](around.a:500.0,\(self.map_latitude),\(self.map_longitude));relation['wheelchair:description'~'.'](around.a:500.0,\(self.map_latitude),\(self.map_longitude));"
        
        apiString = apiString + "node['amenity'~''](around.a:500.0,\(self.map_latitude),\(self.map_longitude));way['amenity'~''](around.a:500.0,\(self.map_latitude),\(self.map_longitude));relation['amenity'~''](around.a:500.0,\(self.map_latitude),\(self.map_longitude));"
        
        apiString = apiString + "node['highway'~''](around.a:500.0,\(self.map_latitude),\(self.map_longitude));way['highway'~''](around.a:500.0,\(self.map_latitude),\(self.map_longitude));relation['highway'~''](around.a:500.0,\(self.map_latitude),\(self.map_longitude));"
        
        apiString = apiString + "node['building'~''](around.a:500.0,\(self.map_latitude),\(self.map_longitude));way['building'~''](around.a:500.0,\(self.map_latitude),\(self.map_longitude));relation['building'~''](around.a:500.0,\(self.map_latitude),\(self.map_longitude));"
        
        apiString = apiString + ");"
        // print resultsc
        apiString = apiString + "out body;"
        apiString = apiString + ">;"
        apiString = apiString + "out skel qt;"
        
        var para:NSDictionary = ["data": apiString];
        
        //ピンの情報構造体の初期化
        var pinInfo:[GpsPin_DataModal.Info] = []
        
        //リクエスト

        
/*
        let manager:AFHTTPRequestOperationManager = AFHTTPRequestOperationManager()
        let serializer:AFJSONRequestSerializer = AFJSONRequestSerializer()
        manager.requestSerializer = serializer
        manager.GET("http://overpass-api.de/api/interpreter", parameters: para,
            success: { (operation, json) -> Void in
                let array = json as! NSDictionary
                //絞り込み
                let el_array: AnyObject? = array["elements"]
                
                //ピンの情報構造体の初期化
                var pinInfo:[GpsPin_DataModal.Info] = []
                
                // セット済みのピンを削除
                self.MapView.removeAnnotations(self.MapView.annotations)
                
                for(var i = 0;i < 5;i++){//el_array?.count;i++){
                    println("ピンの回数  : \(i)")
                    
                    var gps_pin_id: Double? = ((el_array as? NSArray)?[i] as? NSDictionary)?["id"]?.doubleValue
                    var gps_pin_lat: Double? = ((el_array as? NSArray)?[i] as? NSDictionary)?["lat"]?.doubleValue
                    var gps_pin_lon: Double? = ((el_array as? NSArray)?[i] as? NSDictionary)?["lon"]?.doubleValue
                    
                    println("id  : \(gps_pin_id)")
                    println("lat : \(gps_pin_lat)")
                    println("lon : \(gps_pin_lon)")
                    
                    let gps_pin_tag_name: String? = (((el_array as? NSArray)?[i] as? NSDictionary)?["tags"] as? NSDictionary)?["name"]?.stringValue
                    //                    let gps_pin_tag_name:NSString =
                    println("name : \(gps_pin_tag_name)")
                    
                    let gps_pin_tag_highway: AnyObject? = (((el_array as? NSArray)?[i] as? NSDictionary)?["tags"] as? NSDictionary)?["highway"]
                    println("highway : \(gps_pin_tag_highway)")
                    
                    
                    if((gps_pin_lat != nil) || (gps_pin_lon != nil)){
                        
                        var myPin: MKPointAnnotation = MKPointAnnotation()
                        
                        // 座標を設定
                        myPin.coordinate = CLLocationCoordinate2DMake(gps_pin_lat!, gps_pin_lon!);
                        
                        // タイトルを設定
                        //                        myPin.title = gps_pin_tag_name
                        
                        // サブタイトルを設定
                        myPin.subtitle = "aaa"
                        
                        pinInfo.append(GpsPin_DataModal.Info(id: gps_pin_id!, lat: gps_pin_lat!, lon: gps_pin_lon!, title: gps_pin_tag_name! as! String, subTitle: "aaa", pinType: "bb"))
                        
                        
                        self.MapView.addAnnotation(myPin)
                    }
                    
                }
                
            },
            failure: {(operation: AFHTTPRequestOperation!, error: NSError!) in
                println("Error!!")
            }
        )
        */
        
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
                annotationView.image = UIImage(named: "pin_green") // ここで好きな画像を設定します
                
                
                
                switch (pinInfo[0].pinType) {
                case "bb":
                    annotationView.image = UIImage(named: "pin_red") // ここで好きな画像を設定します
                default:
                    break
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

