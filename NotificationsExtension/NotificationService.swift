//
//  NotificationService.swift
//  NotificationsExtension
//
//  Created by Suraphan Laokondee on 9/13/2559 BE.
//  Copyright © 2559 Suraphan Laokondee. All rights reserved.
//

import UserNotifications

class NotificationService: UNNotificationServiceExtension {

    var contentHandler: ((UNNotificationContent) -> Void)?
    var bestAttemptContent: UNMutableNotificationContent?

    override func didReceive(_ request: UNNotificationRequest, withContentHandler contentHandler: @escaping (UNNotificationContent) -> Void) {
      
      func failEarly() {
        print("fail")
        contentHandler(request.content)
      }
      
      guard let content = (request.content.mutableCopy() as? UNMutableNotificationContent) else {
        return failEarly()
      }
      
      guard let attachmentURL = content.userInfo["attachement-url"] as? String else {
        return failEarly()
      }

      do {
        let imageData = try Data(contentsOf: URL(string: attachmentURL)!)
      
        guard let attachment = UNNotificationAttachment.create(imageFileIdentifier: "image.png", data: imageData, options: nil) else { return failEarly() }
        
        content.attachments = [attachment]
        contentHandler(content.copy() as! UNNotificationContent)
        
      } catch {
      
      }
    }
    
    override func serviceExtensionTimeWillExpire() {
        // Called just before the extension will be terminated by the system.
        // Use this as an opportunity to deliver your "best attempt" at modified content, otherwise the original push payload will be used.
        if let contentHandler = contentHandler, let bestAttemptContent =  bestAttemptContent {
            contentHandler(bestAttemptContent)
        }
    }
}



extension UNNotificationAttachment {
  
  /// Save the image to disk
  static func create(imageFileIdentifier: String, data: Data, options: [NSObject : AnyObject]?) -> UNNotificationAttachment? {
    let fileManager = FileManager.default
    let tmpSubFolderName = ProcessInfo.processInfo.globallyUniqueString
    let tmpSubFolderURL = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent(tmpSubFolderName, isDirectory: true)
    
    do {
      try fileManager.createDirectory(at: tmpSubFolderURL, withIntermediateDirectories: true, attributes: nil)
      
      let fileURL = tmpSubFolderURL.appendingPathComponent(imageFileIdentifier)
      
      try data.write(to: fileURL)
      
      let imageAttachment = try UNNotificationAttachment.init(identifier: imageFileIdentifier, url: fileURL, options: options)
      
      return imageAttachment
    } catch let error {
      print(error)
    }
    
    return nil
  }
}
