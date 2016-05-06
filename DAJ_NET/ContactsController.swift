//
//  ContactsController.swift
//  DAJ_NET
//
//  Created by James Wegner on 4/14/16.
//  Copyright © 2016 James Wegner. All rights reserved.
//

import UIKit
import Contacts

class ContactsController: NSObject {
    
    let contactStore = CNContactStore()
    let contactData = NSMutableArray()
    var contactsData = String()
    
    func requestContactAccess() {
        let authorizationStatus = CNContactStore.authorizationStatusForEntityType(CNEntityType.Contacts)
        
        switch authorizationStatus {
        case .Authorized:
            print("Contact access authorized")
            self.getContacts()
            
        case .Denied, .NotDetermined:
            contactStore.requestAccessForEntityType(CNEntityType.Contacts, completionHandler: { (access, accessError) -> Void in
                if access {
                    print("Contact access granted")
                    self.getContacts()
                    
                } else if authorizationStatus == CNAuthorizationStatus.Denied {
                    print("Contact access denied")
                    self.getContacts()
                }
            })
            
        default:
            print("Contact access unknown");
        }
    }
    
    func getContacts() {
        let keysToFetch = [CNContactFormatter.descriptorForRequiredKeysForStyle(.FullName),CNContactPhoneNumbersKey, CNContactEmailAddressesKey]
        let fetchRequest = CNContactFetchRequest( keysToFetch: keysToFetch)
        CNContact.localizedStringForKey(CNLabelPhoneNumberiPhone)
        fetchRequest.mutableObjects = false
        fetchRequest.unifyResults = true
        fetchRequest.sortOrder = .UserDefault
        
        do {
            try CNContactStore().enumerateContactsWithFetchRequest(fetchRequest) { (contact, stop) -> Void in
                
                self.contactsData = self.contactsData.stringByAppendingString(contact.givenName + " " + contact.familyName + "\n")
                print(contact.givenName + " " + contact.familyName)
                
                for phoneNumber:CNLabeledValue in contact.phoneNumbers {
                    let numberValue = phoneNumber.value as! CNPhoneNumber
                    self.contactsData = self.contactsData.stringByAppendingString("\(phoneNumber.label) \(numberValue.stringValue)" + "\n")
                    print("\(phoneNumber.label) \(numberValue.stringValue)" + "\n")
                }
                
                for emailAddress:CNLabeledValue in contact.emailAddresses {
                    let email = emailAddress.value as! String
                    self.contactsData = self.contactsData.stringByAppendingString(email + "\n")
                    print(email)
                }
                self.contactsData = self.contactsData.stringByAppendingString("==============================\n")
                print("==============================")
            }
        } catch let error as NSError {
            print(error.localizedDescription)
        }        
    }
    
    func saveContactsFile() {
        let file = Constants.contactsFileName
        if let dir = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.DocumentDirectory, NSSearchPathDomainMask.AllDomainsMask, true).first {
            let path = NSURL(fileURLWithPath: dir).URLByAppendingPathComponent(file)            
            do {
                try contactsData.writeToURL(path, atomically: false, encoding: NSUTF8StringEncoding)
                print("Contacts written to file")
            } catch {
                print("Error writing contacts to file")
            }
        }
    }
}
