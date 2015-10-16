//
//  WordTableViewCell.swift
//  Dictionary words
//
//  Created by Alexsander  on 10/16/15.
//  Copyright © 2015 Alexsander Khitev. All rights reserved.
//

import UIKit

class WordTableViewCell: UITableViewCell {
    
    // MARK: - IBOutlet 
    @IBOutlet weak var originalWord: UILabel!
    @IBOutlet weak var translatedWord: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
