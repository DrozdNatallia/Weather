//
//  RealmSettings.swift
//  home_work_23
//
//  Created by Natalia Drozd on 4.08.22.
//

import Foundation
import RealmSwift

class RealmSettings: Object {
    @objc dynamic var formatDate: Bool = true
    @objc dynamic var typeSystem: Bool = true
    @objc dynamic var weatherConditional: WeatherConditional?
}
