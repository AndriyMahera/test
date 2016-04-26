
import UIKit
import CoreData

class  CitiesTableViewController: UITableViewController {
   
    let ForecastDetailSegueIdentifier = "ForecastDetailSegueIdentifier"
    let CityTableViewCellIdentifier = "CityTableViewCellIdentifier"
    let baseURLGoogle=NSURL(string:"https://maps.googleapis.com/maps/api/geocode/json?")
    let googleApiKey="AIzaSyC07iqLskaXEGnbXN1Oc04goTmnBhKOlck"
    var cities = [NSManagedObject]()

    
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
        return self.cities.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(self.CityTableViewCellIdentifier, forIndexPath: indexPath)
        let city=cities[indexPath.row]
        cell.textLabel!.text = city.valueForKey("name") as? String
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        self.performSegueWithIdentifier(self.ForecastDetailSegueIdentifier, sender: indexPath)
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let controller = segue.destinationViewController as? WeatherTableViewController,
            indexPath = sender as? NSIndexPath
        {
            let city=cities[indexPath.row]
            controller.cityName = city.valueForKey("name") as? String
            controller.coords=getLatLngForZip((city.valueForKey("name") as? String)!)
        }
    }
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            do
            {
            let appDel:AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
            let context:NSManagedObjectContext = appDel.managedObjectContext
            context.deleteObject(cities[indexPath.row] as NSManagedObject)
            cities.removeAtIndex(indexPath.row)
            try context.save()
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
            }
            catch{}
            
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
        let appDelegate =
            UIApplication.sharedApplication().delegate as! AppDelegate
        let managedContext = appDelegate.managedObjectContext
        let fetchRequest = NSFetchRequest(entityName: "City")
        do {
            let results =
                try managedContext.executeFetchRequest(fetchRequest)
            cities = results as! [NSManagedObject]
        } catch  {}
    }
    
    func getLatLngForZip(zipCode: String)->String {
        let URLString = "\(self.baseURLGoogle?.absoluteString ?? "")address=\(zipCode.stringByReplacingOccurrencesOfString(" ", withString: "+"))&key=\(self.googleApiKey)"
        let url = NSURL(string: URLString)
        let data = NSData(contentsOfURL: url!)
        let json = try! NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.AllowFragments) as! NSDictionary
        print(json)
        if let result = json["results"] as? NSArray {
            if result.count>0
            {
            if let geometry = result[0]["geometry"] as? NSDictionary {
                if let location = geometry["location"] as? NSDictionary {
                    let latitude = location["lat"] as! Float
                    let longitude = location["lng"] as! Float
                    return "\(latitude),\(longitude)"
                }
              }
            }
        }
        return ""
    }

    @IBAction func addClick(sender: UIButton)
    {
        let alert = UIAlertController(title: "New Name",
                                      message: "Add a new name",
                                      preferredStyle: .Alert)
        
        let saveAction = UIAlertAction(title: "Save",
                                       style: .Default,
                                       handler: { (action:UIAlertAction) -> Void in
                                        
                                        let textField = alert.textFields!.first
                                        self.saveName(textField!.text!)
                                        self.tableView.reloadData()
        })
        
        let cancelAction = UIAlertAction(title: "Cancel",
                                         style: .Default) { (action: UIAlertAction) -> Void in
        }
        
        alert.addTextFieldWithConfigurationHandler {
            (textField: UITextField) -> Void in
        }
        
        alert.addAction(saveAction)
        alert.addAction(cancelAction)
        
        presentViewController(alert,
                              animated: true,
                              completion: nil)
    }
    
    func saveName(name: String) {
        let appDelegate =
            UIApplication.sharedApplication().delegate as! AppDelegate
        let managedContext = appDelegate.managedObjectContext
        let entity =  NSEntityDescription.entityForName("City",
                                                        inManagedObjectContext:managedContext)
        let element = NSManagedObject(entity: entity!,
                                      insertIntoManagedObjectContext: managedContext)
        element.setValue(name, forKey: "name")
        do {
            try managedContext.save()
            cities.append(element)
        } catch let error as NSError  {
            print("Could not save \(error), \(error.userInfo)")
        }
    }
}

