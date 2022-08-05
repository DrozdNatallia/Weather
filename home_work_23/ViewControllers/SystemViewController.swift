//
//  SystemViewController.swift
//  home_work_23
//
//  Created by Natalia Drozd on 18.07.22.
//

import UIKit

class SystemViewController: UIViewController {
    var systemSettings: [String]!
    @IBOutlet weak var tableView: UITableView!
    var provaider = RealmProvader()
    enum SystemType: Int {
        case metrical = 0
        case imperial
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        systemSettings = ["metrical system", "imperial system"]
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UINib(nibName: "SystemCell", bundle: nil), forCellReuseIdentifier: SystemCell.key)
    }
    
    func checkingTypeSystem() -> Bool {
        let listSetting = provaider.getResult(nameObject: RealmSettings.self).last
        let type = listSetting?.typeSystem
        return type ?? false
    }
}
