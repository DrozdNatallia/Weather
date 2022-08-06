//
//  WeatherConditionalCell.swift
//  home_work_23
//
//  Created by Natalia Drozd on 17.07.22.
//

import UIKit

class WeatherConditionalCell: UITableViewCell {
    @IBOutlet weak var icon: UIImageView!
    @IBOutlet weak var nameWeatherConditional: UILabel!
    static let key = "WeatherConditionalCell"
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
