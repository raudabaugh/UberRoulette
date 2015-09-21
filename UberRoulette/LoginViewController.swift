//
//  LoginViewController.swift
//  UberRoulette
//
//  Created by Samuel Raudabaugh on 9/18/15.
//  Copyright © 2015 Cornell Tech. All rights reserved.
//

import UIKit
import Alamofire
import FLAnimatedImage
import p2_OAuth2
import SwiftyJSON

class LoginViewController: UIViewController {
    var oauth2: OAuth2CodeGrant!
    @IBOutlet weak var gifView: FLAnimatedImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor(patternImage: UIImage(named: "background.png")!)

        let path = NSBundle.mainBundle().URLForResource("Roulette", withExtension: "gif")?.path
        
        gifView.animatedImage = FLAnimatedImage(animatedGIFData: NSFileManager.defaultManager().contentsAtPath(path!))

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func login(sender: AnyObject) {
        var uberClientKey: String!
        let keysDict = NSDictionary.init(contentsOfFile: NSBundle.mainBundle().pathForResource("Keys", ofType: "plist")!)
        if let uberKey = keysDict?.valueForKey("uberClientKey") as? String {
            uberClientKey = uberKey
        }
        // 1. Create settings dict
        let settings = [
            "client_id": "bKI2_eSBM_pHF2Abz1bHa7VNA9uUqsUM",
            "client_secret": uberClientKey,
            "authorize_uri": "https://login.uber.com/oauth/authorize",
            "token_uri": "https://login.uber.com/oauth/token",
            "scope": "profile",
            "redirect_uris": ["http://localhost:3000/auth/uber/callback"],   // don't forget to register this scheme
            "keychain": true,
            "title": "UberRoulette"  // optional title to show in views
            ] as OAuth2JSON            // the "as" part may or may not be needed
        
        // 2. Instantiate OAuth
        oauth2 = OAuth2CodeGrant(settings: settings)
        oauth2.onAuthorize = { parameters in
            print("Did authorize with parameters: \(parameters)")
            self.getProfile()
        }
        oauth2.onFailure = { error in        // `error` is nil on cancel
            if nil != error {
                print("Authorization went wrong: \(error!.localizedDescription)")
            }
        }
        
        // 3. Authorize
        oauth2.authConfig.authorizeEmbedded = true
        oauth2.authConfig.authorizeContext = self
        oauth2.authorize()
    }
    
    func getProfile() {
        let req = oauth2.request(forURL: NSURL(string: "https://sandbox-api.uber.com/v1/me")!)
        let session = NSURLSession.sharedSession()
        let task = session.dataTaskWithRequest(req) { data, response, error in
            if nil != error {
                print(error)
            }
            else {
                let json = JSON(data: data!)
                
                // Send to uberroulette server
                let parameters = [
                    "accessToken": self.oauth2.accessToken!,
                    "uberId": json["uuid"].stringValue,
                    "firstName": json["first_name"].stringValue,
                    "lastName": json["last_name"].stringValue,
                    "email": json["email"].stringValue,
                    "picture": json["picture"].stringValue
                ]
                
                Alamofire.request(.POST, "http://10.128.1.19:3000/auth/uber", parameters: parameters, encoding: .JSON)
                    .responseString { _, _, result in
                        print("Success: \(result.isSuccess)")
                        print("Response String: \(result.value)")
                        if result.isSuccess {
                            // advance to tabs screen
                            self.performSegueWithIdentifier("LoggedIn", sender: self)
                        }
                }
            }
        }
        task.resume()
        
    }
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "LoggedIn" {
            if let tabBarController = segue.destinationViewController as? UITabBarController {
                if let navController = tabBarController.viewControllers?.first as? UINavigationController {
                    if let requestRideVC = navController.topViewController as? RequestRideViewController {
                        requestRideVC.oauth2 = oauth2
                    }
                }
            }
        }
    }
}

