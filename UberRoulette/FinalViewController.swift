//
//  FinalViewController.swift
//  UberRoulette
//
//  Created by Samuel Raudabaugh on 9/20/15.
//  Copyright © 2015 Cornell Tech. All rights reserved.
//

import UIKit

class FinalViewController: UIViewController {
    var res: [String:AnyObject]!

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var placeLabel: UILabel!
    @IBOutlet weak var messageLabel: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor(patternImage: UIImage(named: "background.png")!)
        if let name = self.res["friendFullName"] as? String {
            nameLabel.text = "\(name) says:"
        }
        if let place = self.res["name"] as? String {
            placeLabel.text = "Welcome to \(place)!"
        }
        if let message = self.res["message"] as? String {
            messageLabel.text = message
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    @IBAction func donePressed(sender: AnyObject) {
        let appDelegate: AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        appDelegate.resetApp()
        
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
