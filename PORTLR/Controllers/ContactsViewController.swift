//
//  ContactsViewController.swift
//  PORTLR
//
//  Created by Hunain on 18/08/2019.
//  Copyright © 2019 Ranksol. All rights reserved.
//

import UIKit
import ContactsUI

class ContactsViewController: UIViewController,UITableViewDataSource,UITableViewDelegate {

    //MARK: Outlets
    @IBOutlet weak var tblContacts: UITableView!
    
    var contacts = [CNContact]()
    //MARK:- View Life Cycle Start here...
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.setupView()
    }
    
    //MARK:- Setup View
    func setupView() {
        self.getContacts()
        self.tblContacts.rowHeight = 44
        self.tblContacts.layoutMargins = UIEdgeInsets.zero
        self.tblContacts.separatorInset = UIEdgeInsets.zero
    }
    
    //MARK:- Utility Methods
    func getContacts(){
        let contactStore = CNContactStore()
        let keys = [CNContactFormatter.descriptorForRequiredKeys(for: .fullName),CNContactPhoneNumbersKey,CNContactIdentifierKey] as [Any]
        let request = CNContactFetchRequest(keysToFetch: keys as! [CNKeyDescriptor])
        do {
            try contactStore.enumerateContacts(with: request) { (contact, stop) in
                self.contacts.append(contact)
            }
        } catch {
            print(error.localizedDescription)
        }
    }
    //MARK:- Button Action
    @IBAction func btnCancelAction(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    //MARK: API Methods
    
    //MARK:- DELEGATE METHODS
    
    //MARK: TableView
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.contacts.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cellContacts", for: indexPath) as! ContactsTableViewCell
        cell.lblContactName.text = (self.contacts[indexPath.row]).givenName
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print((self.contacts[indexPath.row]).givenName)
        NotificationCenter.default.post(name: NSNotification.Name("CallerName"), object: (self.contacts[indexPath.row]).givenName)
        self.dismiss(animated: true, completion: nil)
    }
    //MARK: CollectionView
    
    //MARK: Segment Control
    
    //MARK: Alert View
    
    //MARK: TextField
    
    
    
    //MARK:- View Life Cycle End here...
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
