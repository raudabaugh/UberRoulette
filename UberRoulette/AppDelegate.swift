//
//  AppDelegate.swift
//  UberRoulette
//
//  Created by Samuel Raudabaugh on 9/18/15.
//  Copyright © 2015 Cornell Tech. All rights reserved.
//

import UIKit
import HNKGooglePlacesAutocomplete

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var coreLocationController: CoreLocationController?
    var googleClientKey: String!
    var uberClientKey: String!

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        UITabBar.appearance().tintColor = UIColor(red: 178.0/255.0, green: 0.0, blue: 0.0, alpha: 1.0)

        let keysDict = NSDictionary.init(contentsOfFile: NSBundle.mainBundle().pathForResource("Keys", ofType: "plist")!)
        
        if let googKey = keysDict?.valueForKey("googleClientKey") as? String {
            googleClientKey = googKey
        }
        
        HNKGooglePlacesAutocompleteQuery.setupSharedQueryWithAPIKey(googleClientKey)
        coreLocationController = CoreLocationController()
        return true
    }
    
    func resetApp() {
//        self.window.rootViewController = [[MyMainViewController alloc] initWithNibName:nil bundle:nil];
        window?.rootViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("LoginVC")
    }

    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}

