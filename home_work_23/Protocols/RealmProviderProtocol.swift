//
//  RealmProviderProtocol.swift
//  home_work_23
//
//  Created by Natalia Drozd on 30.06.22.
//

import Foundation
import UIKit
import RealmSwift

protocol RealmProviderProtocol {
    func getResult<T: RealmFetchable>(nameObject: T.Type) -> Results<T>
    func writeObjectToDatabase(name: Object) -> Void
    func setQueryList(lat: Double, lon: Double, time: Int)
    func setCurrentWeatherQueryList(temp: Double, weather: String, time: Int, isCurrentWeather: Bool)
    func setSettingsList(system: Bool, format: Bool)
    func setConditionalWeather(rain: Bool, snow: Bool, thunderStorm: Bool)
    func updateSystem(system: Bool)
    func updateFormat(format: Bool)
    func updateConditionalWeather(rain: Bool, snow: Bool, thunderStorm: Bool)    
}
