//
//  CitiesTableViewController.swift
//  WeatherApp
//
//  Created by Admin on 29.04.16.
//  Copyright © 2016 Admin. All rights reserved.
//


import UIKit
import CoreData
import SystemConfiguration

class  CitiesTableViewController: UITableViewController {
    
    let ForecastDetailSegueIdentifier = "ForecastDetailSegueIdentifier"
    let CityTableViewCellIdentifier = "CityTableViewCellIdentifier"
    let coreDataManager=CoreDataManager()
    let apiOperations=ApiOperations()
    let reach=Reach()
    
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        navigationItem.leftBarButtonItem = editButtonItem()
        self.tableView.tableFooterView = UIView()
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int
    {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.coreDataManager.cities.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(self.CityTableViewCellIdentifier, forIndexPath: indexPath)
        let city=self.coreDataManager.cities[indexPath.row]
        cell.textLabel!.text = city.name
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        self.performSegueWithIdentifier(self.ForecastDetailSegueIdentifier, sender: indexPath)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let controller = segue.destinationViewController as? WeatherTableViewController,
            indexPath = sender as? NSIndexPath
        {
            let city=self.coreDataManager.cities[indexPath.row]
            controller.cityID = city.id
            controller.cityName=city.name
            let status=Reach().connectionStatus()
            switch  status
            {
                case .Unknown,.Offline: break
                default: controller.coords=apiOperations.getLatLngForZip(city.name)
                   break
            }
        }
    }
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete
        {
            let city=self.coreDataManager.cities[indexPath.row]
            self.coreDataManager.deleteWeatherOnWeek(city.id)
            self.coreDataManager.deleteCity(indexPath.row)
            
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        }
        else
        {
            return
        }
        
    }
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.coreDataManager.viewWillAppear()
    }
    
    @IBAction func addClick(sender: UIButton)
    {
        let alert = UIAlertController(title: "New Name",
                                      message: "Add a new name",
                                      preferredStyle: .Alert)
        
        let saveAction = UIAlertAction(title: "Save",
                                       style: .Default,
                                       handler: { (action:UIAlertAction) -> Void in
                                        let status=Reach().connectionStatus()
                                        switch  status
                                        {
                                        case .Unknown,.Offline:self.alertAboutError("You are offline now.Please try again.")
                                            break
                                        default:
                                            let formatted=self.apiOperations.getFormattedAdress((alert.textFields!.first?.text)!)
                                            let cNames=self.coreDataManager.cities.map{$0.name}
                                            if formatted.characters.count>0 && !cNames.contains(formatted)
                                            {
                                                self.coreDataManager.addCity(formatted)
                                            }
                                            else
                                            {
                                                if formatted.characters.count>0 && cNames.contains(formatted)
                                                {
                                                    self.alertAboutError("Fool,you tried to make duplicate!")
                                                }
                                                self.alertAboutError("There is no such city!")
                                            }
                                            
                                            self.tableView.reloadData()
                                            break
                                        }

        })
        
        let cancelAction = UIAlertAction(title: "Cancel",style: .Default) { (action: UIAlertAction) -> Void in
        }
        
        alert.addTextFieldWithConfigurationHandler {
            (textField: UITextField) -> Void in
        }
        
        alert.addAction(saveAction)
        alert.addAction(cancelAction)
        
        presentViewController(alert,animated: true,completion: nil)
    }
    
    func alertAboutError(error:String)
    {
        let alert2 = UIAlertController(title: "Error",
                                       message: error,
                                       preferredStyle: .Alert)
        let cancelAction = UIAlertAction(title: "Close",
                                         style: .Default) { (action: UIAlertAction) -> Void in
        }
        alert2.addAction(cancelAction)
        self.presentViewController(alert2,animated: true,completion: nil)
    }
}

