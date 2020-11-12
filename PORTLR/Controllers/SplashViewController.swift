//
//  SplashViewController.swift
//  PORTLR
//
//  Created by Hunain on 21/05/2019.
//  Copyright © 2019 Ranksol. All rights reserved.
//

import UIKit
import KYDrawerController

class SplashViewController: UIViewController {

    //MARK: Outlets
    var myUser:[User]?{didSet{}}
    //var backgroundTask: UIBackgroundTaskIdentifier = UIBackgroundTaskIdentifier.invalid

    
    //MARK:- View Life Cycle Start here...
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.setupView()
        //registerBackgroundTask()
    }
    
    //MARK:- Setup View
    func setupView() {
        AppUtility?.delayWithSeconds(3.0, completion: {
            self.myUser = User.readUserFromArchive()
            if (self.myUser != nil && self.myUser?.count != 0){
//                let drawerController                        = KYDrawerController.init(drawerDirection: KYDrawerController.DrawerDirection.left, drawerWidth: 288)
//                drawerController.mainViewController         = self.storyboard?.instantiateViewController(withIdentifier: "RegistrationVC") as! TimeRegistrationController
//
////                drawerController.mainViewController         = self.storyboard?.instantiateViewController(withIdentifier: "ActivityVC") as! ActivityViewController
//                drawerController.drawerViewController       = self.storyboard?.instantiateViewController(withIdentifier: "MenuVC") as! MenuViewController
//
//                let nav                     = UINavigationController(rootViewController: drawerController)
//                nav.navigationBar.isHidden  = true
//                nav.modalPresentationStyle = .fullScreen
//                self.present(nav, animated: false, completion: nil)
                let autoTime = AutoTimeTrack()
                autoTime.loadObj()
                if autoTime.isStartPageSet() {
                    let vc = self.storyboard?.instantiateViewController(withIdentifier: "TimeClockVC") as! TimeClockViewController
                    self.navigationController?.pushViewController(vc, animated: false)
                } else {
                    let vc = self.storyboard?.instantiateViewController(withIdentifier: "RegistrationVC") as! TimeRegistrationController
                    self.navigationController?.pushViewController(vc, animated: false)
                }
                
            }else{
                let vc = self.storyboard?.instantiateViewController(withIdentifier: "LoginVC") as! LoginViewController
                self.navigationController?.pushViewController(vc, animated: false)
            }
        })
    }
    
    //MARK:- Utility Methods
    /*func registerBackgroundTask() {
        backgroundTask = UIApplication.shared.beginBackgroundTask { [weak self] in
            self?.endBackgroundTask()
        }
        assert(backgroundTask != UIBackgroundTaskIdentifier.invalid)
    }
    func endBackgroundTask() {
        print("Background task ended.")
        UIApplication.shared.endBackgroundTask(backgroundTask)
        backgroundTask = UIBackgroundTaskIdentifier.invalid
    }*/
    //MARK:- Button Action
    
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
