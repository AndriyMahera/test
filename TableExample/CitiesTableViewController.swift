
import UIKit

class  CitiesTableViewController: UITableViewController {
   
    let ForecastDetailSegueIdentifier = "ForecastDetailSegueIdentifier"
    let CityTableViewCellIdentifier = "CityTableViewCellIdentifier"
    
    let cities = ["Lviv", "Manchester", "New York","Vellington"]
    let latitude_longitude=["49.839683,24.029717","53.480759,-2.242631","40.712784,-74.005941","-41.286460,174.776236"]
    
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
            controller.coords=latitude_longitude[indexPath.row]
        }
    }
    
}

