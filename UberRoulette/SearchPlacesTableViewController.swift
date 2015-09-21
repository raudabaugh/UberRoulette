//
//  SearchPlacesTableViewController.swift
//  UberRoulette
//
//  Created by Samuel Raudabaugh on 9/19/15.
//  Copyright © 2015 Cornell Tech. All rights reserved.
//

import UIKit

import Alamofire
import HNKGooglePlacesAutocomplete

class SearchPlacesTableViewController: UITableViewController, UISearchBarDelegate, UISearchControllerDelegate, UISearchResultsUpdating {
    
    struct SearchControllerRestorableState {
        var wasActive = false
        var wasFirstResponder = false
    }
    
    var searchController: UISearchController!
    var resultsController: ResultsTableViewController!
    var searchQuery: HNKGooglePlacesAutocompleteQuery!
    var restoredState = SearchControllerRestorableState()
    var savedPlaces = [HNKGooglePlacesAutocompletePlace]()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        
        resultsController = storyboard?.instantiateViewControllerWithIdentifier("ResultsController") as! ResultsTableViewController
        resultsController.tableView.delegate = self
        
        searchController = UISearchController(searchResultsController: resultsController)
        searchController.searchResultsUpdater = self
        searchController.searchBar.sizeToFit()
        tableView.tableHeaderView = searchController.searchBar
        
        searchController.delegate = self
        searchController.searchBar.delegate = self
        
        definesPresentationContext = true
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        searchQuery = HNKGooglePlacesAutocompleteQuery.sharedQuery()
        
        // Restore the searchController's active state.
        if restoredState.wasActive {
            searchController.active = restoredState.wasActive
            restoredState.wasActive = false
            
            if restoredState.wasFirstResponder {
                searchController.searchBar.becomeFirstResponder()
                restoredState.wasFirstResponder = false
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return savedPlaces.count
    }
    
    func updateSearchResultsForSearchController(searchController: UISearchController) {
        searchQuery.fetchPlacesForSearchQuery(searchController.searchBar.text, completion: {(places: [AnyObject]!, error: NSError!) -> Void in
            if error != nil {
                print(error)
            } else {
                let resultsController = searchController.searchResultsController as! ResultsTableViewController
                resultsController.searchResults = places
                resultsController.tableView.reloadData()
            }
        })
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("PlaceCell", forIndexPath: indexPath)
        
        cell.textLabel?.text = savedPlaces[indexPath.row].name
        
        return cell
    }

    // MARK: - Table view delegate
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        // Check to see which table view cell was selected.
        if tableView != self.tableView {
            if let selectedPlace = resultsController.searchResults[indexPath.row] as? HNKGooglePlacesAutocompletePlace {
                savedPlaces.append(selectedPlace)
            }
            resultsController.dismissViewControllerAnimated(true, completion: nil)
            self.tableView.reloadData()
        }
    }

    @IBAction func invitePressed(sender: AnyObject) {
        let alert = UIAlertController(title: "Send List", message: "Enter your friend's email used to sign up for Uber.", preferredStyle: .Alert)
        alert.addTextFieldWithConfigurationHandler({(textField: UITextField!) in
            textField.keyboardType = .EmailAddress
        })
        
        alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel, handler: nil))
        let sendAction = UIAlertAction(title: "Send", style: UIAlertActionStyle.Default, handler: {(action: UIAlertAction!) in
            self.send((alert.textFields?.first?.text)!)
        })
        
        alert.addAction(sendAction)
        presentViewController(alert, animated: true, completion: nil)
    }
    
    func send(inviteeEmail: String) {
        var googKey: String!
        var geocodedPlaces = [[String:AnyObject]]()
        let keysDict = NSDictionary.init(contentsOfFile: NSBundle.mainBundle().pathForResource("Keys", ofType: "plist")!)
        if let googleClientKey = keysDict?.valueForKey("googleClientKey") as? String {
            googKey = googleClientKey
        }
        for place in savedPlaces as [HNKGooglePlacesAutocompletePlace] {
            CLPlacemark.hnk_placemarkFromGooglePlace(place, apiKey: googKey) {
                (pmark: CLPlacemark!, str: String!, err: NSError!) in
                if pmark != nil {
                    let geocodedPlace: [String:AnyObject] = [
                        "city": "New York City",
                        "name": place.name,
                        "latitude": Double((pmark.location?.coordinate.latitude)!),
                        "longitude": Double((pmark.location?.coordinate.longitude)!),
                        "message": "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Etiam efficitur commodo ligula, a porttitor nibh sollicitudin nec."
                    ]
                    geocodedPlaces.append(geocodedPlace)
                }
                if place == self.savedPlaces.last {
                    UberDataGetter.getMyProfile() {
                        (userName: String, userEmail: String) in
                        let parameters: [String: AnyObject] = [
                            "fullName": userName,
                            "userEmail": userEmail,
                            "inviteeEmail": inviteeEmail,
                            "places": geocodedPlaces
                        ]
                        
                        Alamofire.request(.POST, "http://10.128.1.19:3000/invite", parameters: parameters, encoding: .JSON)
                    }
                }
            }
        }
    }
    
    /*func geocodeLocationInMapView(mapView: MKMapView, location: CGPoint, completion: (annotation: [[String:AnyObject]]) -> ()) {
        let coordinate = mapView.convertPoint(location, toCoordinateFromView: mapView)
        let location = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
        
        CLGeocoder().reverseGeocodeLocation(location) {
            placemarks, error in
            
            if error != nil {
                completion(annotation: nil, error: error)
                return
            }
            
            let p = placemarks.first as CLPlacemark
            let annotation = MKPointAnnotation()
            annotation.coordinate = coordinate
            let thoroughfare = p.thoroughfare
            let subThoroughfare = p.subThoroughfare
            
            switch (thoroughfare, subThoroughfare) {
            case (nil, nil):
                annotation.title = "Added \(NSDate())"
            case (_, nil):
                annotation.title = thoroughfare
            default:
                annotation.title = thoroughfare + " " + subThoroughfare
            }
            
            completion(annotation: annotation, error: nil)
        }
    }*/
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
