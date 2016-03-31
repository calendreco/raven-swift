//
//  AppDelegate.swift
//  Raven-Swift
//
//  Created by Tommy Mikalsen on 03.09.14.
//

import UIKit
import Raven

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
                            
    var window: UIWindow?
    
    var ravenBuffer = UrlRequestBuffer()
    var ravenBufferFlushTask: UIBackgroundTaskIdentifier?
    
    static let FlushRavenBufferTaskIdentifier = "co.calendre.flush-raven-buffer-task"

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Override point for customization after application launch.
      
        RavenClient.clientWithDSN("https://663998f40e734ea59087883feda37647:306481b9f6bb4a6287b334178d9f8c71@app.getsentry.com/4394")

        RavenClient.sharedClient?.setupExceptionHandler()
        
        RavenClient.sharedClient?.transportDelegate = ravenBuffer

        return true
    }

    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        flushRavenBuffer(withApplication: application)
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(application: UIApplication) {
        flushRavenBuffer(withApplication: application)
    }
    
    func flushRavenBuffer(withApplication application: UIApplication) {
        ravenBufferFlushTask = application.beginBackgroundTaskWithName(AppDelegate.FlushRavenBufferTaskIdentifier, expirationHandler: nil)
        ravenBuffer.flushBuffer() {
            precondition(self.ravenBufferFlushTask != nil)
            application.endBackgroundTask(self.ravenBufferFlushTask!)
        }
    }
}
