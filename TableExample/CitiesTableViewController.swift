
import UIKit
import CoreData

class  CitiesTableViewController: UITableViewController {
   
    let ForecastDetailSegueIdentifier = "ForecastDetailSegueIdentifier"
    let CityTableViewCellIdentifier = "CityTableViewCellIdentifier"
    let coreDataManager=CoreDataManager()
    let apiOperations=ApiOperations()

    
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
            controller.cityName = city.name
            controller.coords=apiOperations.getLatLngForZip(city.name)
        }
    }
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
               let city=self.coreDataManager.cities[indexPath.row]
               self.coreDataManager.deleteWeatherOnWeek(self.coreDataManager.findIndexOfCity(city.name)!)
               self.coreDataManager.deleteCity(indexPath.row)
            
               tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
            
        }
        else {
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
                                        let formatted=self.apiOperations.getFormattedAdress((alert.textFields!.first?.text)!)
                                        if formatted.characters.count>0
                                        {
                                           self.coreDataManager.addCity(formatted)
                                        }
                                        else
                                        {
                                            let alert2 = UIAlertController(title: "Error",
                                                message: "There is no such city!",
                                                preferredStyle: .Alert)
                                            let cancelAction = UIAlertAction(title: "Close",
                                            style: .Default) { (action: UIAlertAction) -> Void in
                                            }
                                            alert2.addAction(cancelAction)
                                            self.presentViewController(alert2,animated: true,completion: nil)
                                        }
                                        self.tableView.reloadData()
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
}

