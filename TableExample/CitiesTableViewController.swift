
import UIKit

class  CitiesTableViewController: UITableViewController {
   
    let ForecastDetailSegueIdentifier = "ForecastDetailSegueIdentifier"
    let CityTableViewCellIdentifier = "CityTableViewCellIdentifier"
    let baseURLGoogle=NSURL(string:"https://maps.googleapis.com/maps/api/geocode/json?")
    let googleApiKey="AIzaSyC07iqLskaXEGnbXN1Oc04goTmnBhKOlck"
    
    let cities = ["Lviv", "Manchester", "New York","Wellington"]

    
    override func viewDidLoad()
    {
        super.viewDidLoad()
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
        cell.textLabel?.text = self.cities[indexPath.row]
        
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        self.performSegueWithIdentifier(self.ForecastDetailSegueIdentifier, sender: indexPath)
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let controller = segue.destinationViewController as? WeatherTableViewController,
            indexPath = sender as? NSIndexPath
        {
            controller.cityName = cities[indexPath.row]
            controller.coords=getLatLngForZip(cities[indexPath.row])
        }
    }
    func getLatLngForZip(zipCode: String)->String {
        let URLString = "\(self.baseURLGoogle?.absoluteString ?? "")address=\(zipCode.stringByReplacingOccurrencesOfString(" ", withString: "+"))&key=\(self.googleApiKey)"
        print(URLString)
        let url = NSURL(string: URLString)
        let data = NSData(contentsOfURL: url!)
        let json = try! NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.AllowFragments) as! NSDictionary
        print(json)
        if let result = json["results"] as? NSArray {
            if let geometry = result[0]["geometry"] as? NSDictionary {
                if let location = geometry["location"] as? NSDictionary {
                    let latitude = location["lat"] as! Float
                    let longitude = location["lng"] as! Float
                    return "\(latitude),\(longitude)"
                }
            }
        }
        return ""
    }

    
    
}

