//
//  CalanderViewController.swift
//  PORTLR
//
//  Created by Hunain on 23/05/2019.
//  Copyright © 2019 Ranksol. All rights reserved.
//

import UIKit

class CalanderViewController: UIViewController {

    //MARK: Outlets
    @IBOutlet weak var pickerDate: UIDatePicker!
    
    //MARK:- View Life Cycle Start here...
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.setupView()
    }
    
    //MARK:- Setup View
    func setupView() {
        
    }
    
    //MARK:- Utility Methods
    
    //MARK:- Button Action
    @IBAction func btnCancelAction(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    @IBAction func btnOkAction(_ sender: Any) {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd-MM-yyyy"
        let date = formatter.string(from: self.pickerDate.date)
        AppUtility?.saveObject(obj: date, forKey: strDate)
        NotificationCenter.default.post(name: NSNotification.Name("PickedDate"), object: date)
        self.dismiss(animated: true, completion: nil)
    }
    
    //MARK: API Methods
    
    //MARK:- DELEGATE METHODS
    
    //MARK: TableView
    
    //MARK: Segment Control
    
    //MARK: Alert View
    
    //MARK: TextField
    
    
    
    //MARK:- View Life Cycle End here...
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
