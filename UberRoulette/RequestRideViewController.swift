//
//  RequestRideViewController.swift
//  UberRoulette
//
//  Created by Samuel Raudabaugh on 9/19/15.
//  Copyright © 2015 Cornell Tech. All rights reserved.
//

import UIKit
import CoreLocation

import Alamofire
import ASValueTrackingSlider
import p2_OAuth2
import SwiftyJSON

class RequestRideViewController: UIViewController, ASValueTrackingSliderDataSource {
    @IBOutlet weak var costSlider: ASValueTrackingSlider!
    @IBOutlet weak var distanceSlider: ASValueTrackingSlider!
    
    var oauth2: OAuth2CodeGrant!
    var responseJson: [String:AnyObject]!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setup(costSlider, max: 200.0)
        setup(distanceSlider, max: 50.0)
    }
    
    func setup(slider: ASValueTrackingSlider, max: Float) {
        slider.maximumValue = max
        slider.minimumValue = 1.0
        slider.popUpViewCornerRadius = 12.0
        slider.popUpViewColor = UIColor(hue: 0.55, saturation: 0.8, brightness: 0.9, alpha: 0.7)
        slider.font = UIFont(name: "GillSans-Bold", size: 22)
        slider.textColor = UIColor(hue: 0.55, saturation: 1.0, brightness: 0.5, alpha: 1)
        slider.dataSource = self
    }

    func slider(slider: ASValueTrackingSlider!, stringForValue value: Float) -> String! {
        if slider == costSlider {
            return String.localizedStringWithFormat("$%.2f", value)
        }
        return String.localizedStringWithFormat("%.1f miles", value)
    }
    
    @IBAction func requestPressed(sender: AnyObject) {
        oauth2.authorize()
        let req = oauth2.request(forURL: NSURL(string: "https://sandbox-api.uber.com/v1/me")!)
        let session = NSURLSession.sharedSession()
        let task = session.dataTaskWithRequest(req) { data, response, error in
            if nil != error {
                print(error)
            }
            else {
                let json = JSON(data: data!)
                
                // Get location data
                let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
                
                let location: CLLocationCoordinate2D = (appDelegate.coreLocationController?.locationManager.location?.coordinate)!
                
                // Send to uberroulette server
                let parameters: [String:AnyObject] = [
                    "accessToken": self.oauth2.accessToken!,
                    "uberId": json["uuid"].stringValue,
                    "firstName": json["first_name"].stringValue,
                    "lastName": json["last_name"].stringValue,
                    "email": json["email"].stringValue,
                    "picture": json["picture"].stringValue,
                    "start_latitude": location.latitude,
                    "start_longitude": location.longitude,
                    "max_dollar": self.costSlider.value,
                    "max_radius": self.distanceSlider.value
                ]
                
                Alamofire.request(.POST, "http://10.128.1.19:3000/ride", parameters: parameters, encoding: .JSON)
                    .responseJSON { request, response, result in
                        switch result {
                        case .Success(let json):
//                            print("Success with JSON: \(json)")
                            if let j = json as? [String:AnyObject] {
                                self.responseJson = j
                            }
                            self.performSegueWithIdentifier("RideRequested", sender: self)
                            
                        case .Failure(let data, let error):
                            print("Request failed with error: \(error)")
                            
                            if let data = data {
                                print("Response data: \(NSString(data: data, encoding: NSUTF8StringEncoding)!)")
                            }
                        }
                   }
            }
        }
        task.resume()
    }

    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "RideRequested" {
            if let driverMap = segue.destinationViewController as? DriverMapViewController {
                driverMap.res = responseJson
            }
        }
    }


}
