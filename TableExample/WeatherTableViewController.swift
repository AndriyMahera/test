
import UIKit
import CoreLocation
import AddressBookUI
import CoreData

class WeatherTableViewController: UITableViewController {
    
    
    let apiKey="4e39340c48a7b3a9307503a14a16e14e"
    let LabelCell="CustomCell1"
    let LabelCell2="CustomCell2"
    var cityName:String!
    var coords:String!
    let calendar = NSCalendar.currentCalendar()
    let coreDataManager=CoreDataManager()

//    NSFetchedResultsController
    override func viewDidLoad()
    {
        super.viewDidLoad()
        let baseURL = NSURL(string: "https://api.forecast.io/forecast/\(apiKey)/")
        let forecastURL = NSURL(string:coords, relativeToURL: baseURL)
        let weatherData = NSData(contentsOfURL: forecastURL!)
        let json=convertToJSON(weatherData!)
        fillWeatherData(json!)
    }
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int
    {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return 7
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        var cell:UITableViewCell
        if(indexPath.row==0)
        {
            cell=tableView.dequeueReusableCellWithIdentifier(self.LabelCell, forIndexPath: indexPath)
            let cell1=cell as! CustomCell1
            tableView.rowHeight=250

            let components = calendar.components(.Weekday, fromDate: NSDate())
            cell1.dayOfWeekLabel.text=nameOfDay(components.weekday)
            cell1.temperatureLabel.text="\((coreDataManager.weatherArray[indexPath.row] as! Weather).temperature)ºC"
            cell1.humidityLabel.text="\((coreDataManager.weatherArray[indexPath.row] as! Weather).humidity)%"
            cell1.pressureLabel.text="\((coreDataManager.weatherArray[indexPath.row] as! Weather).pressure) mmHg"
            cell1.summaryLabel.text="\((coreDataManager.weatherArray[indexPath.row] as! Weather).summary)"
            cell1.windLabel.text="\((coreDataManager.weatherArray[indexPath.row] as! Weather).windSpeed) m/s"
            cell1.icon.image=UIImage(named: (coreDataManager.weatherArray[indexPath.row] as! Weather).icon)
        }
        else
        {
            cell=tableView.dequeueReusableCellWithIdentifier(self.LabelCell2, forIndexPath: indexPath)
            let cell2=cell as! CustomCell2
            tableView.rowHeight=140
            
            let thatDay=calendar.dateByAddingUnit(.Weekday, value: indexPath.row, toDate: NSDate(), options: [])
            let components=calendar.components(.Weekday,fromDate: thatDay!)
            
            cell2.dayOfWeekLabel.text=nameOfDay(components.weekday)
            cell2.maxTempLabel.text="\((coreDataManager.weatherArray[indexPath.row] as! Weather).maxTemperature)ºC"
            cell2.minTempLabel.text="\((coreDataManager.weatherArray[indexPath.row] as! Weather).minTemperature)ºC"
            cell2.humidityLabel.text="\((coreDataManager.weatherArray[indexPath.row] as! Weather).humidity)%"
            cell2.windLabel.text="\((coreDataManager.weatherArray[indexPath.row] as! Weather).windSpeed)m/s"
            cell2.icon.image=UIImage(named: (coreDataManager.weatherArray[indexPath.row] as! Weather).icon)
        }
        return cell
    }
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String?
    {
        return self.cityName
    }
    
    func convertToJSON(data:NSData)->NSDictionary?
    {
        do
        {
            let json=try NSJSONSerialization.JSONObjectWithData(data, options: []) as! NSDictionary
            return json
        }
        catch{}
        return nil
    }
    func fillWeatherData(json : NSDictionary)
    {
        if let currently=json["currently"] as? NSDictionary
        {
            coreDataManager.viewWillAppear()
            let i=coreDataManager.findIndexOfCity(self.cityName)!
            
            if coreDataManager.weatherArray.count>0
            {
                for _ in i*7...i*7+6
                {
                    coreDataManager.deleteWeatherOnDay(i*7)
                }
                coreDataManager.viewWillAppear()
            }
            coreDataManager.addWeatherOnDay(currently, isCurrent: true)
            coreDataManager.viewWillAppear()
        }
        if let daily=json["daily"] as? NSDictionary
        {
            if let data=daily["data"] as? [NSDictionary]
            {
                for index in 0...5
                {
                    coreDataManager.addWeatherOnDay(data[index], isCurrent: false)
                    coreDataManager.viewWillAppear()
                }
            }
            print(coreDataManager.weatherArray)
        }
    }
    func nameOfDay(day:Int)->String
    {
        switch day {
        case 1:return "Sunday"
        case 2:return "Monday"
        case 3:return "Tuesday"
        case 4:return "Wednesday"
        case 5:return "Thursday"
        case 6:return "Friday"
        case 7:return "Saturday"
        default:return "You're such an idiot!"
        }
    }

}


