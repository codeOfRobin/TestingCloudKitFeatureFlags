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

		featureFlags.featureEnabled(name: "some_feature_flag").sink(receiveCompletion: { (completion) in
			print(completion)
		}) { (value) in
			print(value)
		}.store(in: &cancellables)
		createFeatureFlagIfNecessary()
	}

	func createFeatureFlagIfNecessary() {
		let featureFlag = FeatureFlag(name: "some_feature_flag", uuid: UUID(), rollout: 0.1, value: true)
		container.featureFlaggingDatabase.fetch(withRecordID: .init(recordName: "some_feature_flag")) { [weak self] (record, error) in
			if record == nil {
				self?.container.featureFlaggingDatabase.save(featureFlag.convertToRecord()) { (record, error) in
					print(record as Any)
				}
			} else {
				print(record as Any)
			}
		}
	}

	func applicationWillTerminate(_ aNotification: Notification) {
		// Insert code here to tear down your application
	}


}

