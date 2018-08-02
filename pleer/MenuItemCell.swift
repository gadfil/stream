//
//  MenuItemCell.swift
//  pleer
//
//  Created by Alexey Galaev on 6/13/18.
//  Copyright © 2018 Александр. All rights reserved.
//

import UIKit
import SwiftyJSON

struct MenuItem: Codable {
    var title: String = ""
    var url: String = ""
    
    init(item: JSON) {
        if let dic = item.dictionaryObject {
        self.title = dic["title"] as! String
        self.url = dic["url"] as! String
        }
    }
    
    enum CodingKeys : String, CodingKey {
        case title
        case url
    }
}

class MenuItemCell: UITableViewCell {
    
    
    @IBOutlet var channelNumber: UILabel!
    @IBOutlet var channelTitleLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func confugure(item: MenuItem, index: Int) {
        channelNumber.text = "\(index + 1)."
        channelTitleLabel.text = item.title
    }
}
