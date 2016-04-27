
import UIKit
import CoreData

class  CitiesTableViewController: UITableViewController {
   
    let ForecastDetailSegueIdentifier = "ForecastDetailSegueIdentifier"
    let CityTableViewCellIdentifier = "CityTableViewCellIdentifier"
    let baseURLGoogle=NSURL(string:"https://maps.googleapis.com/maps/api/geocode/json?")
    let googleApiKey="AIzaSyC07iqLskaXEGnbXN1Oc04goTmnBhKOlck"
    let coreDataManager=CoreDataManager()

    
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
        cell.textLabel!.text = (city as City).name
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
            controller.coords=getLatLngForZip((city.valueForKey("name") as? String)!)
        }
    }
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
               self.coreDataManager.deleteCity(indexPath.row)
               self.coreDataManager.viewWillAppear()
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
    func getFormattedAdress(address:String)->String
    {
        let URLString = "\(self.baseURLGoogle?.absoluteString ?? "")address=\(address.stringByReplacingOccurrencesOfString(" ", withString: "+"))&key=\(self.googleApiKey)"
        let url = NSURL(string: URLString)
        let data = NSData(contentsOfURL: url!)
        let json = try! NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.AllowFragments) as! NSDictionary
        print(json)
        var formatted:String=""
        if let result = json["results"] as? NSArray
        {
            if result.count>0
            {
                formatted=(result[0]["formatted_address"] as? String)!
            }
        }
        return formatted
    }

    @IBAction func addClick(sender: UIButton)
    {
        let alert = UIAlertController(title: "New Name",
                                      message: "Add a new name",
                                      preferredStyle: .Alert)
        
        let saveAction = UIAlertAction(title: "Save",
                                       style: .Default,
                                       handler: { (action:UIAlertAction) -> Void in
                                        let formatted=self.getFormattedAdress((alert.textFields!.first?.text)!)
                                        if formatted.characters.count>0
                                        {
                                           self.coreDataManager.addCity(formatted)
                                           self.coreDataManager.viewWillAppear()
                                        }
                                        else
                                        {
                                            let alert2 = UIAlertController(title: "Loozer",
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

