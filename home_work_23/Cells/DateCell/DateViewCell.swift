//
//  DateViewCell.swift
//  home_work_23
//
//  Created by Natalia Drozd on 18.07.22.
//

import UIKit

class DateViewCell: UITableViewCell {
    @IBOutlet weak var icon: UIImageView!
    @IBOutlet weak var nameDateFormat: UILabel!
    static let key = "DateViewCell"
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
