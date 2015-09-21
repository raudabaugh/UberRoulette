//
//  DriverMapViewController.swift
//  UberRoulette
//
//  Created by Samuel Raudabaugh on 9/20/15.
//  Copyright © 2015 Cornell Tech. All rights reserved.
//

import UIKit

class DriverMapViewController: UIViewController, MKMapViewDelegate {
    @IBOutlet weak var driverMap: MKMapView!
    var res: [String:AnyObject]!

    override func viewDidLoad() {
        super.viewDidLoad()

        let geocoder = CLGeocoder()
        if res != nil {
            if let addr = res["location"] as? String {
                geocoder.geocodeAddressString(addr) {
                    (placemarks, error) in
                    let driverCoordinate = (placemarks?.first?.location?.coordinate)!
                    
                    let driverPin = MKPointAnnotation()
                    driverPin.coordinate = driverCoordinate
                    if let title = self.res["vehicle"] as? String {
                        driverPin.title = title
                    }
                    if let subtitle = self.res["driver"] as? String {
                        driverPin.subtitle = subtitle
                    }
                    self.driverMap.addAnnotation(driverPin)
                    
                    let region = MKCoordinateRegionMakeWithDistance(driverCoordinate, 200.0, 200.0)
                    self.driverMap.setRegion(region, animated: true)
                }
                
            }
        }
        
    }
    
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        if (annotation is MKUserLocation) {
            //if annotation is not an MKPointAnnotation (eg. MKUserLocation),
            //return nil so map draws default view for it (eg. blue dot)...
            return nil
        }
        
        let reuseId = "test"
        
        var anView = mapView.dequeueReusableAnnotationViewWithIdentifier(reuseId)
        if anView == nil {
            anView = MKAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            anView?.canShowCallout = true
        }
        else {
            //we are re-using a view, update its annotation reference...
            anView?.annotation = annotation
        }
        
        return anView
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "FinalSegue" {
            if let finalVC = segue.destinationViewController as? FinalViewController {
                finalVC.res = res
            }
        }
    }

}
