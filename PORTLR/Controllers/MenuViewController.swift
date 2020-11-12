//
//  MenuViewController.swift
//  PORTLR
//
//  Created by Hunain on 21/05/2019.
//  Copyright © 2019 Ranksol. All rights reserved.
//

import UIKit
import KYDrawerController

class MenuViewController: UIViewController,UITableViewDelegate,UITableViewDataSource {

    //MARK: Outlets
    @IBOutlet weak var tblMenu: UITableView!
    
    var arrMenu = ["Activity","Logout"]
    var myUser: [User]? {didSet {}}
    
    //MARK:- View Life Cycle Start here...
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.setupView()
    }
    
    //MARK:- Setup View
    func setupView() {
        self.tblMenu.rowHeight = 60
    }
    
    //MARK:- Utility Methods
    
    //MARK:- Button Action
    
    //MARK: API Methods
    
    //MARK:- DELEGATE METHODS
    
    //MARK: TableView
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.arrMenu.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cellMenu", for: indexPath) as! MenuTableViewCell
        cell.lblMenu.text = self.arrMenu[indexPath.row]
        cell.imgMenu.image = UIImage(named: self.arrMenu[indexPath.row])
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.row {
        case 0:
            //let vc = self.storyboard?.instantiateViewController(withIdentifier: "ActivityVC") as! ActivityViewController
            if let drawerController = self.parent as? KYDrawerController {
                //let mainNav = UINavigationController(rootViewController: vc)
                //mainNav.navigationBar.isHidden = true
                //drawerController.mainViewController = mainNav
                drawerController.setDrawerState(.closed, animated: true)
            }
            break
        /*case 1:
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "LoginVC") as! LoginViewController
            vc.isUpdate = true
            if let drawerController = self.parent as? KYDrawerController {
                drawerController.mainViewController = vc
                drawerController.setDrawerState(.closed, animated: true)
            }
            break*/
        case 1:
            self.myUser = User.readUserFromArchive()
            self.myUser?.remove(at: 0)
            if User.saveUserToArchive(user: self.myUser!){
                let appDelegate = UIApplication.shared.delegate as! AppDelegate
                let vc = self.storyboard?.instantiateViewController(withIdentifier: "LoginVC") as! LoginViewController
                let nav = UINavigationController(rootViewController: vc)
                nav.navigationBar.isHidden = true
                appDelegate.window!.rootViewController = nav
            }
            break
        default:
            break
        }
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
