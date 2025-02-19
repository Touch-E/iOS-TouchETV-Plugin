//
//  AppDelegate.swift
//  ExampleApp
//
//  Created by Parth on 24/01/25.
//

import UIKit
import TouchETVPlugin
@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        let urlString = "https://api-cluster.system.touchetv.com"
        var userToken = ""//"Bearer eyJhbGciOiJIUzUxMiJ9.eyJzdWIiOiI0MSIsInVzZXJSb2xlcyI6WyJWSUVXRVIiXSwib3JnSWRzIjpbMV0sImlhdCI6MTcwNzI3OTE4MSwiZXhwIjoxNzA3MzY5MTgxfQ.vLJ73Ei6jklWSCPGHY54Tpluom1hgCH0cgXPjrvjrPvdg8792SJOWlFx8ojpOAF1-ZVP8cdGqwGmkfMse8n9ow"
        if let retrievedString = UserDefaults.standard.string(forKey: "userToken") {
            userToken = retrievedString
        } else {
            userToken = ""
        }
        
        TouchETVPluginVC.shared.validateURLAndToken(urlString: urlString, token: userToken) { isURLValid, isTokenValid in
            if isURLValid {
                if isTokenValid {
                    
                    if let archivedObject = UserDefaults.standard.object(forKey:"profileData") as? Data {
                        profileData = NSMutableDictionary(dictionary: NSKeyedUnarchiver.unarchiveObject(with: archivedObject) as! NSMutableDictionary)
                        print(profileData)
                    }
                    
                    if let userID = UserDefaults.standard.string(forKey: "userID") {
                       UserID = userID
                    }
                    
                    headersCommon = [
                        "Authorization": userToken
                    ]
                    
                    let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
                    let vc  = storyboard.instantiateViewController(withIdentifier: "HomeNavigation") as! UINavigationController
                    self.window?.rootViewController = vc
                    self.window?.makeKeyAndVisible()
                } else {
                    print("Your Token invalid")
                    let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
                    let vc  = storyboard.instantiateViewController(withIdentifier: "loginNavigation") as! UINavigationController
                    self.window?.rootViewController = vc
                    self.window?.makeKeyAndVisible()
                }
            } else {
                print("URL is invalid")
                let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
                let vc  = storyboard.instantiateViewController(withIdentifier: "loginNavigation") as! UINavigationController
                self.window?.rootViewController = vc
                self.window?.makeKeyAndVisible()
            }
        }
        
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }


}

