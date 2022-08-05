//
//  SystemViewController+extension.swift
//  home_work_23
//
//  Created by Natalia Drozd on 18.07.22.
//

import Foundation
import UIKit

extension SystemViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        systemSettings.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if let cell = tableView.dequeueReusableCell(withIdentifier: SystemCell.key) as? SystemCell {
            cell.nameSystem.text = NSLocalizedString(systemSettings[indexPath.row], comment: "")
            if checkingTypeSystem() {
                switch SystemType(rawValue: indexPath.row) {
                case .metrical:
                    cell.icon.image = UIImage(systemName: "square.fill")
                default:
                    cell.icon.image = UIImage(systemName: "square")
                }
            } else {
                switch SystemType(rawValue: indexPath.row) {
                case .metrical:
                    cell.icon.image = UIImage(systemName: "square")
                default:
                    cell.icon.image = UIImage(systemName: "square.fill")
                }
            }
            return cell
        }
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        provaider.updateSystem(system: !checkingTypeSystem())
        tableView.reloadData()
    }
}
