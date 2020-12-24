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
import CloudKit

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

	var window: NSWindow!

	let container = CKContainer(identifier: "iCloud.com.rmalhotra.CloudKitTrial")
	lazy var featureFlags = CloudKitFeatureFlagsRepository(container: container)
	var cancellables = Set<AnyCancellable>()

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

		setupFeatureFlags()
        
        featureFlags.DEBUGGING_AND_VERIFICATION.sendDataToVerificationServer(url: URL(string: "https://insert_url_here")!).sink { (error) in
            print(error)
        } receiveValue: { (data, response) in
            print(data)
            print((response as? HTTPURLResponse)?.statusCode)
        }.store(in: &cancellables)

	}
    
    func setupFeatureFlags() {
        let featureFlagNames = ["discountBanner", "testFeatureFlag1", "testFeatureFlag2", "testFeatureFlag3", "prodFeatureFlag1", "prodFeatureFlag2", "prodFeatureFlag3", "prodFeatureFlag4"]
        for (index, name) in featureFlagNames.enumerated() {
            let featureFlag = FeatureFlag(name: name, uuid: UUID(), rollout: 0.1 * Float((index % 10)), value: true)
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

