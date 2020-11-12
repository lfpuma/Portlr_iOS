//
//  CompanyNamesViewController.swift
//  PORTLR
//
//  Created by Hunain on 01/06/2019.
//  Copyright © 2019 Ranksol. All rights reserved.
//

import UIKit

class CompanyNamesViewController: UIViewController,UITableViewDataSource,UITableViewDelegate {

    //MARK: Outlets
    @IBOutlet weak var tblCompanyNames: UITableView!
    @IBOutlet weak var imgDismiss: UIImageView!
    
    var arrCompanyNames = [[String:Any]]()
    var callID = ""
    
    //MARK:- View Life Cycle Start here...
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.setupView()
    }
    
    //MARK:- Setup View
    func setupView() {
        //self.tblCompanyNames.rowHeight = 50
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.tapDismiss))
        self.imgDismiss.addGestureRecognizer(tapGesture)
    }
    
    //MARK:- Utility Methods
    @objc func tapDismiss(){
        self.dismiss(animated: true, completion: nil)
    }
    //MARK:- Button Action
    
    //MARK: API Methods
    
    //MARK:- DELEGATE METHODS
    
    //MARK: TableView
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.arrCompanyNames.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cellCompanyName", for: indexPath) as! CompanyNameTableViewCell
        if let str = self.arrCompanyNames[indexPath.row]["name"] as? String{
            cell.lblName.text = self.arrCompanyNames[indexPath.row]["name"] as! String
        }else{
            cell.lblName.text = "Test"
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let companyID = "\(self.arrCompanyNames[indexPath.row]["id"] as! Int)"
        var companyName = "Test"
        if let str = self.arrCompanyNames[indexPath.row]["name"] as? String{
            companyName = self.arrCompanyNames[indexPath.row]["name"] as! String
        }
        let data = [companyID,companyName,self.callID]
        NotificationCenter.default.post(name: NSNotification.Name("CompanyData"), object: data)
        self.dismiss(animated: true, completion: nil)
    }
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    //MARK: Segment Control
    
    //MARK: Alert View
    
    //MARK: TextField
    
    
    
    //MARK:- View Life Cycle End here...
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
