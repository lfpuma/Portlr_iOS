//
//  LoggerListTableViewCell.swift
//  PORTLR
//
//  Created by puma on 08.04.2020.
//  Copyright © 2020 Ranksol. All rights reserved.
//

import UIKit

protocol EditBtnTapDelegate {
    func onEditBtnTapped(at index: IndexPath)
}

class LoggerListTableViewCell: UITableViewCell {
    
    var delegate:EditBtnTapDelegate!
    var indexPath: IndexPath!
    
    @IBOutlet weak var projectLb: UILabel!
    @IBOutlet weak var taskLb: UILabel!
    @IBOutlet weak var startLb: UILabel!
    @IBOutlet weak var endLb: UILabel!
    @IBOutlet weak var hoursLb: UILabel!
    
    @IBOutlet weak var commentLb: UILabel!
    
    @IBOutlet weak var backView: UIView!
    
    @IBOutlet weak var onEdit: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        backView.layer.cornerRadius = 20
        backView.layer.masksToBounds = true
        backView.layer.borderColor = #colorLiteral(red: 0.1129845455, green: 0.4494044185, blue: 0.747171104, alpha: 1)
        backView.layer.borderWidth = 1
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @IBAction func onEditBtn(_ sender: Any) {
        self.delegate.onEditBtnTapped(at: indexPath)
    }
}
