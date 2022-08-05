//
//  DateViewController.swift
//  home_work_23
//
//  Created by Natalia Drozd on 18.07.22.
//

import UIKit

class DateViewController: UIViewController {
    var dateFormatSettings: [String]!
    @IBOutlet weak var tableView: UITableView!
    var provaider = RealmProvader()
    enum DateTypeFormat: Int {
        case firstType = 0
        case secondType
    }
    var defaults = UserDefaults()
    override func viewDidLoad() {
        super.viewDidLoad()
        dateFormatSettings = ["24-hour format", "12-hour format"]
        
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.register(UINib(nibName: "DateViewCell", bundle: nil), forCellReuseIdentifier: DateViewCell.key)
    }
    func checkingDate() -> Bool {
        let listSetting = provaider.getResult(nameObject: RealmSettings.self).last
        let dateFormat = listSetting?.formatDate
        return dateFormat ?? false
    }
}
