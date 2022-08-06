//
//  SystemCell.swift
//  home_work_23
//
//  Created by Natalia Drozd on 18.07.22.
//

import UIKit

class SystemCell: UITableViewCell {
    @IBOutlet weak var nameSystem: UILabel!
    @IBOutlet weak var icon: UIImageView!
    static let key = "SystemCell"
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }
    
}
