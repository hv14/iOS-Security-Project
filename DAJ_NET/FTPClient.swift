//
//  FTPClient.swift
//  DAJ_NET
//
//  Created by James Wegner on 4/22/16.
//  Copyright © 2016 James Wegner. All rights reserved.
//

import UIKit

class FTPClient: NSObject {
    static var session: Session!
    
    static func connectToServer(completion:(error: NSError) -> Void) {
        var configuration = SessionConfiguration()
        configuration.host = "ftp://\(Constants.ftpHost)"
        configuration.username = Constants.ftpUserName
        configuration.password = Constants.ftpPassword
        self.session = Session(configuration: configuration)
        listFTPFolderContents()
    }
    
    static func listFTPFolderContents() {
        self.session.list("shared") { (resources, error) -> Void in
            print("FTP directory:\n\(resources)\nerror: \(error)\n")
        }
    }
    
    static func uploadFileWithName(fileName: String, completion:(error: NSError?) -> Void) {
        if let dir = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.DocumentDirectory, NSSearchPathDomainMask.AllDomainsMask, true).first {
            let contactsPath = NSURL(fileURLWithPath: dir).URLByAppendingPathComponent(fileName)
            
            self.session.upload(contactsPath, path:"shared/\(fileName)", completionHandler: {(result, error) in
                if error == nil {
                    print("\(fileName) uploaded")
                } else {
                    print("\(fileName) failed to upload")
                    print(result)
                    print(error)
                }
                completion(error: error)
            })
        }
    }
    
    static func uploadFileWithURL(fileName: String, fileURL: NSURL, completion:(error: NSError?) -> Void) {
        self.session.upload(fileURL, path:"shared/\(fileName)", completionHandler: {(result, error) in
            if error == nil {
                print("\(fileName) uploaded")
            } else {
                print("\(fileName) failed to upload")
                print(result)
                print(error)
            }
            completion(error: error)
        })
    }
}
