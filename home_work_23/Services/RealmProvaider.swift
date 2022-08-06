//
//  RealmProvaider.swift
//  home_work_23
//
//  Created by Natalia Drozd on 30.06.22.
//

import Foundation
import RealmSwift
import UIKit

class RealmProvader: RealmProviderProtocol {
    private let realm = try! Realm()
    
    func writeObjectToDatabase(name: Object) {
        try! realm.write {
            realm.add(name)
        }
    }
    func getResult<T: RealmFetchable>(nameObject: T.Type) -> Results<T> {
        realm.objects(nameObject.self)
    }
    
    func setQueryList(lat: Double, lon: Double, time: Int) {
        let newRequest = RealmQueryList()
        newRequest.latitude = lat
        newRequest.longitude = lon
        newRequest.time = time
        newRequest.currentWeather = getResult(nameObject: RealmCurrentWeather.self).last
        writeObjectToDatabase(name: newRequest)
    }
    
    func setCurrentWeatherQueryList(temp: Double, weather: String, time: Int, isCurrentWeather: Bool){
        let newRequest = RealmCurrentWeather()
        newRequest.temp = temp
        newRequest.weatherDescription = weather
        newRequest.time = time
        newRequest.isCurrentWeather = isCurrentWeather
        writeObjectToDatabase(name: newRequest)
    }
    
    func setSettingsList(system: Bool, format: Bool) {
        let systemSetting = RealmSettings()
        systemSetting.formatDate = format
        systemSetting.typeSystem = system
        systemSetting.weatherConditional = getResult(nameObject: WeatherConditional.self).last
        writeObjectToDatabase(name: systemSetting)
        
    }
    
    func setConditionalWeather(rain: Bool, snow: Bool, thunderStorm: Bool) {
        let newRequest = WeatherConditional()
        newRequest.rain = rain
        newRequest.thunderStorm = thunderStorm
        newRequest.snow = snow
        writeObjectToDatabase(name: newRequest)
    }
    
    func updateSystem(system: Bool) {
        try! realm.write {
            guard let settings = getResult(nameObject: RealmSettings.self).last else {
                return
            }
            settings.typeSystem = system
        }
    }
    
    
    func updateFormat(format: Bool) {
        try! realm.write {
            guard let settings = getResult(nameObject: RealmSettings.self).last else {
                return
            }
            settings.formatDate = format
        }
    }
    
    func updateConditionalWeather(rain: Bool, snow: Bool, thunderStorm: Bool) {
        try! realm.write {
            guard let setttings = getResult(nameObject: RealmSettings.self).last, let weathersConditional = setttings.weatherConditional else {
                return
            }
            weathersConditional.rain = rain
            weathersConditional.snow = snow
            weathersConditional.thunderStorm = thunderStorm
        }
    }
}
