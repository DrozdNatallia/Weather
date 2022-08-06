//
//  WeatherConditionalViewController+extension.swift
//  home_work_23
//
//  Created by Natalia Drozd on 18.07.22.
//

import Foundation
import UIKit

extension WeatherConditionalViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        weatherConditional.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: WeatherConditionalCell.key) as? WeatherConditionalCell {
            cell.nameWeatherConditional.text = NSLocalizedString(weatherConditional[indexPath.row], comment: "")
            let conditional = provaider.getResult(nameObject: WeatherConditional.self).last
            let snow = conditional?.snow ?? false
            let rain = conditional?.rain ?? false
            let thunderStorm = conditional?.thunderStorm ?? false
            
            switch conditionalType(rawValue: indexPath.row) {
            case .thuderstorm:
                cell.icon.image = UIImage(systemName: thunderStorm ? "square.fill" : "square")
            case .rain:
                cell.icon.image = UIImage(systemName: rain ? "square.fill" : "square")
            default:
                cell.icon.image = UIImage(systemName: snow ? "square.fill" : "square")
            }
            return cell
        }
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let conditional = provaider.getResult(nameObject: WeatherConditional.self).last
        let snow = conditional?.snow ?? false
        let rain = conditional?.rain ?? false
        let thunderStorm = conditional?.thunderStorm ?? false
        
        switch conditionalType(rawValue: indexPath.row){
        case .thuderstorm:
            provaider.updateConditionalWeather(rain: rain, snow: snow, thunderStorm: !thunderStorm)
        case.rain:
            provaider.updateConditionalWeather(rain: !rain, snow: snow, thunderStorm: thunderStorm)
        default:
            provaider.updateConditionalWeather(rain: rain, snow: !snow, thunderStorm: thunderStorm)
        }
        tableView.reloadData()
        notificationCenter.removeAllPendingNotificationRequests()
    }
}

