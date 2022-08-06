//
//  SettingsViewController.swift
//  home_work_23
//
//  Created by Natalia Drozd on 16.07.22.
//

import UIKit

class SettingsViewController: UIViewController {
    enum typeSettings: Int {
        case conditionalWeatherlistRequest = 0
        case listRequest
        case system
        case dateFormat
        
    }
    @IBOutlet weak var tableView: UITableView!
    var arraySettings: [String]!
    override func viewDidLoad() {
        super.viewDidLoad()
        arraySettings = ["Choice weather conditional", "History request", "System measurement", "Date format"]
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.register(UINib(nibName: "SettingsCells", bundle: nil), forCellReuseIdentifier: SettingsCells.key)
    }

}
