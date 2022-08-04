//
//  WeatherConditional.swift
//  home_work_23
//
//  Created by Natalia Drozd on 4.08.22.
//

import Foundation
import RealmSwift

class WeatherConditional: Object {
    @objc dynamic var rain: Bool = true
    @objc dynamic var thunderStorm: Bool = true
    @objc dynamic var snow: Bool = true
}
