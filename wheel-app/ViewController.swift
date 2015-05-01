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

class ViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate {
    
    //Configクラス定義
    var config_cls:NSObject.Type = NSClassFromString("Configuration") as! NSObject.Type
    //地図ビュー
    @IBOutlet weak var MapView: MKMapView!
    @IBOutlet weak var InfoLabel: UILabel!
    //ロケーションマネージャー
    var myLocationManager: CLLocationManager!
    //取得した緯度を保持するインスタンス
    var map_latitude: CLLocationDegrees!
    //取得した経度を保持するインスタンス
    var map_longitude: CLLocationDegrees!
    //初回緯度経度セットフラグ
    var map_FirstPointSet: Bool! = false
    
    
    //ナビゲーション画面に遷移
    @IBAction func pushButton_NaviMap(sender: AnyObject) {
    }
    
    //ナビゲーション画面から戻ってきた場合
    @IBAction func unwindNavigationBackAction(segue: UIStoryboardSegue) {
    }
    
    //地図のトラッキングモード設定
    @IBAction func pushButton_Direction(sender: AnyObject) {
        
        // 位置情報の更新を停止
        myLocationManager.stopUpdatingLocation()
        
        //Config用のクラス設定
        var config:Configuration = (config_cls() as! Configuration)
        
        switch config.getMapDirection() {
        case 0://未設定の為、マーキング設定へ変更
            config.setMapDirection(1)
            
        case 1://マーキング設定されている為、向き設定へ変更
            config.setMapDirection(2)
            
        case 2://向き設定されている為、未設定へ戻す
            config.setMapDirection(0)
            
        default:
            config.setMapDirection(0)
            break
        }
        
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
        myLocationManager.distanceFilter = 10.0
        
    
        
        // セキュリティ認証のステータスを取得.
        let status = CLLocationManager.authorizationStatus()
        
        // まだ認証が得られていない場合は、認証ダイアログを表示.
        if(status == CLAuthorizationStatus.NotDetermined) {
            
            // まだ承認が得られていない場合は、認証ダイアログを表示.
            self.myLocationManager.requestAlwaysAuthorization()
        }
        
        self.MapView.showsUserLocation = false
        self.MapView.setUserTrackingMode(MKUserTrackingMode.None, animated: false)
        
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

        
        
        // セット済みのピンを削除
        self.MapView.removeAnnotations(self.MapView.annotations)
        
        switch config.getMapDirection() {
        case 0://未設定の為、マーキング設定へ変更
            self.MapView.showsUserLocation = false
            self.MapView.setUserTrackingMode(MKUserTrackingMode.None, animated: true)
            
            //初回のみ地図位置をセット
            if (self.map_FirstPointSet == false) {
                //初期位置を設定
                var centerCoordinate : CLLocationCoordinate2D = CLLocationCoordinate2DMake(self.map_latitude,self.map_longitude)
                let span = MKCoordinateSpanMake(0.01, 0.01) //小さい値であるほど近づく
                //任意の場所を表示する場合、MKCoordinateRegionを使って表示する -> (中心位置、表示領域)
                var centerPosition = MKCoordinateRegionMake(centerCoordinate, span)
                self.MapView.setRegion(centerPosition,animated:true)
                //初期フラグ設定解除
                self.map_FirstPointSet = true
            }

            
        case 1://マーキング設定されている為、向き設定へ変更
            self.MapView.showsUserLocation = true
            self.MapView.setUserTrackingMode(MKUserTrackingMode.None, animated: true)
            
            //初回のみ地図位置をセット
            if (self.map_FirstPointSet == false) {
                //初期位置を設定
                var centerCoordinate : CLLocationCoordinate2D = CLLocationCoordinate2DMake(self.map_latitude,self.map_longitude)
                let span = MKCoordinateSpanMake(0.001, 0.001) //小さい値であるほど近づく
                //任意の場所を表示する場合、MKCoordinateRegionを使って表示する -> (中心位置、表示領域)
                var centerPosition = MKCoordinateRegionMake(centerCoordinate, span)
                self.MapView.setRegion(centerPosition,animated:true)
                //初期フラグ設定解除
                self.map_FirstPointSet = true
            }
            
        case 2://向き設定されている為、未設定へ戻す
            self.MapView.showsUserLocation = true
            self.MapView.setUserTrackingMode(MKUserTrackingMode.FollowWithHeading, animated: true)
            
            //初回のみ地図位置をセット
            if (self.map_FirstPointSet == false) {
                //初期位置を設定
                var centerCoordinate : CLLocationCoordinate2D = CLLocationCoordinate2DMake(self.map_latitude,self.map_longitude)
//                let span = MKCoordinateSpanMake(0.00001, 0.00001) //小さい値であるほど近づく
                //任意の場所を表示する場合、MKCoordinateRegionを使って表示する -> (中心位置、表示領域)
//                var centerPosition = MKCoordinateRegionMake(centerCoordinate, span)
//                self.MapView.setRegion(centerPosition,animated:true)
                
                
                var theRegion: MKCoordinateRegion = self.MapView.region
                theRegion.span.longitudeDelta /= 500
                theRegion.span.latitudeDelta /= 500
                println("\(theRegion.span.longitudeDelta) - \(theRegion.span.latitudeDelta)")
                
                self.MapView.setRegion(theRegion, animated:true)
                //初期フラグ設定解除
                self.map_FirstPointSet = true
            }
                
        default:
            break
        }
        
        
        /*
        // ピンを生成.
        var myPin: MKPointAnnotation = MKPointAnnotation()
        
        // 座標を設定.
        myPin.coordinate = centerCoordinate
        
        // タイトルを設定.
        myPin.title = "自分"
        
        // サブタイトルを設定.
        myPin.subtitle = "現在の場所"
        
        // MapViewにピンを追加.
        self.MapView.addAnnotation(myPin)
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

}

