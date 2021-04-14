//
//  AppDelegate.swift
//  TestCloudKitFeatureFlags
//
//  Created by Robin Malhotra on 18/07/20.
//

import Cocoa
import SwiftUI
import CloudKitFeatureFlags
import Combine
import UserNotifications
import CloudKit

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

	var window: NSWindow!

    //Sub in your own container ID for testing
	let container = CKContainer(identifier: "iCloud.com.rmalhotra.CloudKitTrial")
	lazy var featureFlags = CloudKitFeatureFlagsRepository(container: container)
	var cancellables = Set<AnyCancellable>()
    
    let predicate = NSPredicate(value: true)
    lazy var subscription = CKQuerySubscription(recordType: "FeatureFlag", predicate: predicate, options: [.firesOnRecordUpdate])

	func applicationDidFinishLaunching(_ aNotification: Notification) {
		// Create the SwiftUI view that provides the window contents.
		let contentView = ContentView()

		// Create the window and set the content view.
		window = NSWindow(
		    contentRect: NSRect(x: 0, y: 0, width: 480, height: 300),
		    styleMask: [.titled, .closable, .miniaturizable, .resizable, .fullSizeContentView],
		    backing: .buffered, defer: false)
		window.isReleasedWhenClosed = false
		window.center()
		window.setFrameAutosaveName("Main Window")
		window.contentView = NSHostingView(rootView: contentView)
		window.makeKeyAndOrderFront(nil)

        let notificationInfo = CKSubscription.NotificationInfo()
        notificationInfo.shouldBadge = false;
        notificationInfo.shouldSendContentAvailable = true;
        subscription.notificationInfo = notificationInfo
        container.publicCloudDatabase.save(subscription) { (subscription, error) in
            print(error)
            print(subscription)
        }
        
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert]) { (registered, error) in
            DispatchQueue.main.async {
                NSApp.registerForRemoteNotifications()
            }
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            self.container.publicCloudDatabase.fetch(withRecordID: CKRecord.ID.init(recordName: "testFeatureFlag1"), completionHandler: { [self]
                record, error in
                
                //Updating a record here
                record?.setValue(0.2, forKey: "rollout")
                container.publicCloudDatabase.save(record!) { (record, error) in
                    print(record)
                }
            })
        }
	}
    
    func application(_ application: NSApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {

    }
    
    func application(_ application: NSApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        
    }
    
    func application(_ application: NSApplication, didReceiveRemoteNotification userInfo: [String : Any]) {
        let notification = CKQueryNotification(fromRemoteNotificationDictionary: userInfo)
        print(notification)
    }
    
    
    //<Anything below isn't relevant for code review purposes>
    
    func setupFeatureFlags() {
        let featureFlagNames = ["discountBanner", "testFeatureFlag1", "testFeatureFlag2", "testFeatureFlag3", "prodFeatureFlag1", "prodFeatureFlag2", "prodFeatureFlag3", "prodFeatureFlag4"]
        for (index, name) in featureFlagNames.enumerated() {
            let featureFlag = FeatureFlag(name: FeatureFlag.Name(rawValue: name), uuid: UUID(), rollout: 0.1 * Float((index % 10)), value: true)
            container.featureFlaggingDatabase.fetch(withRecordID: .init(recordName: name)) { [weak self] (record, error) in
                if record == nil {
                    self?.container.featureFlaggingDatabase.save(featureFlag.convertToRecord()) { (record, error) in
                        print(record as Any)
                    }
                } else {
                    print(record as Any)
                }
            }
        }
    }

	func applicationWillTerminate(_ aNotification: Notification) {
		// Insert code here to tear down your application
	}


}

