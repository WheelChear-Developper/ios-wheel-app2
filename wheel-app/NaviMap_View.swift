//
//  NaviMap_View.swift
//  wheel-app
//
//  Created by MacServer on 2015/04/28.
//  Copyright (c) 2015年 Mobile Innovation, LLC. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class NaviMap_View: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate {
    
    // 地図ビュー
    @IBOutlet weak var MapView: MKMapView! 
    
    //メインマップへ戻る時
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        //identifierが"back_mainmap"
        if (segue.identifier == "back_mainmap") {
            println("\(segue.identifier)")
        }
    }
    
    // 現在地の位置情報の取得にはCLLocationManagerを使用
    var lm: CLLocationManager!
    // 取得した緯度を保持するインスタンス
    var latitude: CLLocationDegrees!
    // 取得した経度を保持するインスタンス
    var longitude: CLLocationDegrees!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // GPS位置情報用フィールドの初期化
        lm = CLLocationManager()
        longitude = CLLocationDegrees()
        latitude = CLLocationDegrees()
        
        // CLLocationManagerをDelegateに指定
        lm.delegate = self
        
        // 位置情報取得の許可を求めるメッセージの表示．必須．
        lm.requestAlwaysAuthorization()
        // 位置情報の精度を指定．任意，
        // lm.desiredAccuracy = kCLLocationAccuracyBest
        // 位置情報取得間隔を指定．指定した値（メートル）移動したら位置情報を更新する．任意．
        //        lm.distanceFilter = 500
        
        //マップの設定
        //        mapMakeing(latitude, sub_longitude: longitude)
        
        // GPSの使用を開始する
        lm.startUpdatingLocation()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    /* 位置情報取得成功時に実行される関数 */
    func locationManager(manager: CLLocationManager, didUpdateToLocation newLocation: CLLocation, fromLocation oldLocation: CLLocation){
        // 取得した緯度がnewLocation.coordinate.longitudeに格納されている
        latitude = newLocation.coordinate.latitude
        // 取得した経度がnewLocation.coordinate.longitudeに格納されている
        longitude = newLocation.coordinate.longitude
        // 取得した緯度・経度をLogに表示
        NSLog("latiitude: \(latitude) , longitude: \(longitude)")
        
        // GPSの使用を停止する．停止しない限りGPSは実行され，指定間隔で更新され続ける．
        //        lm.stopUpdatingLocation()
        
        //マップの設定
        mapMakeing(latitude, sub_longitude: longitude)
    }
    
    /* 位置情報取得失敗時に実行される関数 */
    func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        // この例ではLogにErrorと表示するだけ．
        NSLog("Error")
        
        //マップの設定
        mapMakeing(latitude, sub_longitude: longitude)
    }
    
    /* 地図の生成 */
    func mapMakeing(sub_latitude: CLLocationDegrees, sub_longitude: CLLocationDegrees){
        
        //緯度経度の位置データが無い場合
        if (sub_latitude == 0){
            if (sub_longitude == 0){
                latitude = 35.710080
                longitude = 139.810699
            }
        }
        
        //初期位置を設定
        //経度、緯度からメルカトル図法の点に変換する
        var centerCoordinate : CLLocationCoordinate2D = CLLocationCoordinate2DMake(latitude,longitude)
        let span = MKCoordinateSpanMake(0.003, 0.003) //小さい値であるほど近づく
        //任意の場所を表示する場合、MKCoordinateRegionを使って表示する -> (中心位置、表示領域)
        var centerPosition = MKCoordinateRegionMake(centerCoordinate, span)
        self.MapView.setRegion(centerPosition,animated:true)
        
        //出発点：現在の位置
        //経度、緯度からメルカトル図法の点に変換する
        var fromCoordinate :CLLocationCoordinate2D = CLLocationCoordinate2DMake(latitude, longitude)
        var toCoordinate   :CLLocationCoordinate2D = CLLocationCoordinate2DMake(34.074449, 134.551010)
        
        //CLLocationCoordinate2DからMKPlacemarkを作成する
        var fromPlacemark = MKPlacemark(coordinate:fromCoordinate, addressDictionary:nil)
        var toPlacemark = MKPlacemark(coordinate:toCoordinate, addressDictionary:nil)
        
        //MKPlacemarkからMKMapItemを生成します。
        var fromItem = MKMapItem(placemark:fromPlacemark);
        var toItem = MKMapItem(placemark:toPlacemark);
        
        //MKMapItem をセットして MKDirectionsRequest を生成します
        let request = MKDirectionsRequest()
        request.setSource(fromItem)
        request.setDestination(toItem)
        request.requestsAlternateRoutes = true; //複数経路
        request.transportType = MKDirectionsTransportType.Walking //移動手段 Walking:徒歩/Automobile:車
        
        //経路を検索する(非同期で実行される)
        let directions = MKDirections(request:request)
        directions.calculateDirectionsWithCompletionHandler({
            (response:MKDirectionsResponse!, error:NSError!) -> Void in
            if (error == nil) {
                if (response.routes.isEmpty) {
                    return
                }
            }
            let route: MKRoute = response.routes[0] as! MKRoute
            self.MapView.addOverlay(route.polyline!)
        })
        
        
        //アノテーションというピンを地図に刺すことができる
        //出発点：六本木　〜　目的地：渋谷　の２点に刺す
        var theRoppongiAnnotation = MKPointAnnotation()
        theRoppongiAnnotation.coordinate  = fromCoordinate
        theRoppongiAnnotation.title       = "現在の場所"
        theRoppongiAnnotation.subtitle    = "xxxxxxxxxxxxxxxxxx"
        self.MapView.addAnnotation(theRoppongiAnnotation)
        
        var theShibuyaAnnotation = MKPointAnnotation()
        theShibuyaAnnotation.coordinate  = toCoordinate
        theShibuyaAnnotation.title       = "徳島駅"
        theShibuyaAnnotation.subtitle    = "xxxxxxxxxxxxxxxxxx"
        self.MapView.addAnnotation(theShibuyaAnnotation)
        
        //カメラの設定をしてみる（少し手前に傾けた状態）
        var camera:MKMapCamera = self.MapView.camera;
        //camera.altitude += 100
        //camera.heading += 15
        camera.pitch += 60
        self.MapView.setCamera(camera, animated: true)
    }
    
    func mapView(mapView: MKMapView!, rendererForOverlay overlay: MKOverlay!) -> MKOverlayRenderer! {
        let route: MKPolyline = overlay as! MKPolyline
        let routeRenderer = MKPolylineRenderer(polyline:route)
        routeRenderer.lineWidth = 5.0
        routeRenderer.strokeColor = UIColor.redColor()
        return routeRenderer
    }
    
    
    
    
}


