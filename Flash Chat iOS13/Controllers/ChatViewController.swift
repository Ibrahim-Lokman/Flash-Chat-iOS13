//
//  ChatViewController.swift
//  Flash Chat iOS13
//
//  Created by Angela Yu on 21/10/2019.
//  Copyright © 2019 Angela Yu. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseFirestoreInternal

class ChatViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var messageTextfield: UITextField!
    let db = Firestore.firestore()
    
    var messages: [Message] = [

    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        tableView.delegate = self
        tableView.dataSource = self
        title = AppConstants.appName
        navigationItem.hidesBackButton = true
        
        tableView.register(UINib(nibName: AppConstants.cellNibName, bundle: nil), forCellReuseIdentifier: AppConstants.cellIdentifier)
        
        loadMessage()
        
        

    }
    func loadMessage(){
        db.collection(AppConstants.FStore.collectionName).order(by: AppConstants.FStore.dateField).addSnapshotListener {(querySnapshot, error) in
           
            if let e = error {
                print("Error in data loading")
            } else {
                self.messages = []
                if let snapshotDocuments =    querySnapshot?.documents{
                    for doc in snapshotDocuments {
                        print(doc.data())
                        
                        let data = doc.data()
                        if let messageSender = data[AppConstants.FStore.senderField] as? String, let messageBody = data[AppConstants.FStore.bodyField] as? String {
                            let newMessage = Message(sender: messageSender, body: messageBody)
                            self.messages.append(newMessage)
                            
                            DispatchQueue.main.async {
                                self.tableView.reloadData()
                                let indexPath = IndexPath(row: self.messages.count - 1, section: 0)
                                self.tableView.scrollToRow(at: indexPath, at: .top, animated: true)
                                
                            }
                         
                        }
                        
                    }
                }
            }
            
        }
        
    }
    
 
    
    @IBAction func sendPressed(_ sender: UIButton) {
        if let messageBody = messageTextfield.text, let messageSender = Auth.auth().currentUser?.email {
            
            db.collection(AppConstants.FStore.collectionName).addDocument(data: [
                AppConstants.FStore.senderField : messageSender,
                AppConstants.FStore.bodyField :messageBody,
                AppConstants.FStore.dateField: Date().timeIntervalSince1970
            ]) { (error) in
                if let e  = error {
                    print("Error in sending")
                } else {
                    DispatchQueue.main.async {
                        self.messageTextfield.text=""
                    }
                    print("Success")
                }
            }
            
            
        }
    }
    

    @IBAction func logOut(_ sender: UIBarButtonItem) {
     
        do {
            try Auth.auth().signOut()
            navigationController?.popToRootViewController(animated: true)
            
        } catch let signOutError as NSError {
            print("Error: ", signOutError)
        }
        
    }
}

extension ChatViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        messages.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let message = messages[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: AppConstants.cellIdentifier, for: indexPath) as! MessageCell
        cell.label.text = message.body
        if message.sender == Auth.auth().currentUser?.email {
            cell.leftImageView.isHidden = true
            cell.rightImageView.isHidden = false
            cell.messageBubble.backgroundColor = UIColor(named: AppConstants.BrandColors.lightPurple)
            cell.label.textColor = UIColor(named: AppConstants.BrandColors.purple)
        } else {
            cell.leftImageView.isHidden = false
            cell.rightImageView.isHidden = true
            cell.messageBubble.backgroundColor = UIColor(named: AppConstants.BrandColors.purple)
            cell.label.textColor = UIColor(named: AppConstants.BrandColors.lightPurple)
        }
      
        return cell;
    }
    
    
}

//extension ChatViewController: UITableViewDelegate {
//    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        print(indexPath.row )
//    }
//}
