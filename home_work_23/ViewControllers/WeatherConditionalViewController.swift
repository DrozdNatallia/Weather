//
//  WeatherConditionalViewController.swift
//  home_work_23
//
//  Created by Natalia Drozd on 16.07.22.
//

import UIKit

class WeatherConditionalViewController: UIViewController {
    var weatherConditional: [String]!
    var provaider = RealmProvader()
    @IBOutlet weak var tableView: UITableView!
    enum conditionalType: Int {
        case thuderstorm = 0
        case rain
        case snow
    }
    let notificationCenter = UNUserNotificationCenter.current()
    override func viewDidLoad() {
        super.viewDidLoad()
        weatherConditional = ["thunderstorm", "rain", "snow"]
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UINib(nibName: "WeatherConditionalCell", bundle: nil), forCellReuseIdentifier: WeatherConditionalCell.key)
    }
}
