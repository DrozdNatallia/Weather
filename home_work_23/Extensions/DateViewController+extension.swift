//
//  DateViewController+extension.swift
//  home_work_23
//
//  Created by Natalia Drozd on 18.07.22.
//

import Foundation
import UIKit

extension DateViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        dateFormatSettings.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        if let cell = tableView.dequeueReusableCell(withIdentifier: DateViewCell.key) as? DateViewCell {
            cell.nameDateFormat.text = NSLocalizedString(dateFormatSettings[indexPath.row], comment: "")
            if checkingDate() {
            switch DateTypeFormat(rawValue: indexPath.row) {
            case .firstType:
                cell.icon.image = UIImage(systemName: "square.fill")
            default:
                cell.icon.image = UIImage(systemName: "square")
            }
            } else {
                switch DateTypeFormat(rawValue: indexPath.row) {
                case .firstType:
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
        provaider.updateFormat(format: !checkingDate())
        tableView.reloadData()
    }
    
}
