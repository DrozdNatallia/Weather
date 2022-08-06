//
//  FormattedType.swift
//  home_work_23
//
//  Created by Natalia Drozd on 30.06.22.
//

import Foundation

enum FormattedType {
    case day
    case hourFirstType
    case hourSecondType
    case fullTime
    case minutly
    
    var description: String {
        switch self {
         case .day:
             return "EEE"
         case .hourFirstType:
             return "HH"
        case .hourSecondType:
            return "hh"
         case .fullTime:
             return "dd-MM-yy HH:mm:ss"
        case .minutly:
            return "mm"
         }
    }
}
