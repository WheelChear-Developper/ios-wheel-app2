//
//  Configuration.swift
//  wheel-app
//
//  Created by MacServer on 2015/04/30.
//  Copyright (c) 2015年 Mobile Innovation, LLC. All rights reserved.
//

import Foundation

@objc(Configuration)
class Configuration: NSObject {
    
    let CONFIGURATION_SAMPLEBOOL = "Configuration.SampleBool"
    func setSampleBool(value: Bool) {
        
        let userDefaults = NSUserDefaults.standardUserDefaults()
        userDefaults.setBool(value, forKey: CONFIGURATION_SAMPLEBOOL)
        userDefaults.synchronize()
    }
    func getSampleBool() ->(Bool) {
        
        let userDefaults = NSUserDefaults.standardUserDefaults()
        var dic = [CONFIGURATION_SAMPLEBOOL: false]
        userDefaults.registerDefaults(dic)
        return userDefaults.boolForKey(CONFIGURATION_SAMPLEBOOL)
    }
    
    let CONFIGURATION_SAMPLESTRING = "Configuration.SampleString"
    func setSampleString(value: String) {
        
        let userDefaults = NSUserDefaults.standardUserDefaults()
        userDefaults.setObject(value, forKey: CONFIGURATION_SAMPLESTRING)
        userDefaults.synchronize()
    }
    func getSampleString() ->(String) {
        
        let userDefaults = NSUserDefaults.standardUserDefaults()
        var dic = [CONFIGURATION_SAMPLESTRING: ""]
        userDefaults.registerDefaults(dic)
        return userDefaults.objectForKey(CONFIGURATION_SAMPLESTRING) as! String
    }
    
    let CONFIGURATION_SAMPLEDOUBLE = "Configuration.SampleDouble"
    func setSampleDouble(value: Double) {
        
        let userDefaults = NSUserDefaults.standardUserDefaults()
        userDefaults.setDouble(value, forKey: CONFIGURATION_SAMPLEDOUBLE)
        userDefaults.synchronize()
    }
    func getSampleDouble() ->(Double) {
        
        let userDefaults = NSUserDefaults.standardUserDefaults()
        var dic = [CONFIGURATION_SAMPLEDOUBLE: 0]
        userDefaults.registerDefaults(dic)
        return userDefaults.doubleForKey(CONFIGURATION_SAMPLEDOUBLE)
    }
    
    let CONFIGURATION_SAMPLEINT = "Configuration.SampleInt"
    func setSampleInt(value: Int) {
        
        let userDefaults = NSUserDefaults.standardUserDefaults()
        userDefaults.setInteger(value, forKey: CONFIGURATION_SAMPLEINT)
        userDefaults.synchronize()
    }
    func getSampleInt() ->(Int) {
        
        let userDefaults = NSUserDefaults.standardUserDefaults()
        var dic = [CONFIGURATION_SAMPLEINT: 0]
        userDefaults.registerDefaults(dic)
        return userDefaults.integerForKey(CONFIGURATION_SAMPLEINT)
    }
    
    
    
    
    
    //初期起動フラグ
    let CONFIGURATION_FIRST_START = "Configuration.FirstStart"
    func setFirstStart(value: Bool) {
        
        let userDefaults = NSUserDefaults.standardUserDefaults()
        userDefaults.setBool(value, forKey: CONFIGURATION_FIRST_START)
        userDefaults.synchronize()
    }
    func getFirstStart() ->(Bool) {
        
        let userDefaults = NSUserDefaults.standardUserDefaults()
        var dic = [CONFIGURATION_FIRST_START: true]
        userDefaults.registerDefaults(dic)
        return userDefaults.boolForKey(CONFIGURATION_FIRST_START)
    }
    
    let CONFIGURATION_MAP_DIRECTION = "Configuration.Map_Direction"
    func setMapDirection(value: Int) {
        
        let userDefaults = NSUserDefaults.standardUserDefaults()
        userDefaults.setInteger(value, forKey: CONFIGURATION_MAP_DIRECTION)
        userDefaults.synchronize()
    }
    func getMapDirection() ->(Int) {
        
        let userDefaults = NSUserDefaults.standardUserDefaults()
        var dic = [CONFIGURATION_MAP_DIRECTION: 0]
        userDefaults.registerDefaults(dic)
        return userDefaults.integerForKey(CONFIGURATION_MAP_DIRECTION)
    }
    
    //緯度の保存
    let CONFIGURATION_MAP_LATITUDE = "Configuration.Map_latitude"
    func setMapLatitude(value: Double) {
        
        let userDefaults = NSUserDefaults.standardUserDefaults()
        userDefaults.setDouble(value, forKey: CONFIGURATION_MAP_LATITUDE)
        userDefaults.synchronize()
    }
    func getMapLatitude() ->(Double) {
        
        let userDefaults = NSUserDefaults.standardUserDefaults()
        var dic = [CONFIGURATION_MAP_LATITUDE: 0]
        userDefaults.registerDefaults(dic)
        return userDefaults.doubleForKey(CONFIGURATION_MAP_LATITUDE)
    }
    //経度の保存
    let CONFIGURATION_MAP_LONGITUDE = "Configuration.Map_longitude"
    func setMapLongitude(value: Double) {
        
        let userDefaults = NSUserDefaults.standardUserDefaults()
        userDefaults.setDouble(value, forKey: CONFIGURATION_MAP_LONGITUDE)
        userDefaults.synchronize()
    }
    func getMapLongitude() ->(Double) {
        
        let userDefaults = NSUserDefaults.standardUserDefaults()
        var dic = [CONFIGURATION_MAP_LONGITUDE: 0]
        userDefaults.registerDefaults(dic)
        return userDefaults.doubleForKey(CONFIGURATION_MAP_LONGITUDE)
    }
    
}
