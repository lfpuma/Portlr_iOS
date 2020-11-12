//
//  CallListTableViewCell.swift
//  PORTLR
//
//  Created by Hunain on 22/05/2019.
//  Copyright © 2019 Ranksol. All rights reserved.
//

import UIKit

protocol ActivityListDelegate {
    func onEditBtnTap(at index: IndexPath!)
    func onDeleteBtnTap(at index: IndexPath!)
}

class CallListTableViewCell: UITableViewCell {
    
    var delegate:ActivityListDelegate!
    var indexPath: IndexPath!

//    @IBOutlet weak var lblDate: UILabel!
    @IBOutlet weak var btnDuration: UIButton!
//    @IBOutlet weak var btnStatus: UIButton!
    @IBOutlet weak var lblCallerName: UILabel!
    @IBOutlet weak var parentView: UIView!
    
    //@IBOutlet weak var btnCallerName: UIButton!
    //@IBOutlet weak var btnPhoneBook: UIButton!
    //var buttonCallerNamePressed : (() -> ()) = {}
    //var buttonPhoneBookPressed : (() -> ()) = {}
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        parentView.layer.cornerRadius = 20
        parentView.layer.masksToBounds = true
        parentView.layer.borderColor = #colorLiteral(red: 0.1129845455, green: 0.4494044185, blue: 0.747171104, alpha: 1)
        parentView.layer.borderWidth = 1
    }
    
    

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    /*@IBAction func btnCallerNameAction(_ sender: Any) {
        buttonCallerNamePressed()
    }
    @IBAction func btnPhoneBookAction(_ sender: Any) {
        buttonPhoneBookPressed()
    }*/
    
    @IBAction func onEdit(_ sender: Any) {
        delegate.onEditBtnTap(at: indexPath)
    }
    
    @IBAction func onDelete(_ sender: Any) {
        delegate.onDeleteBtnTap(at: indexPath)
    }
    
}
