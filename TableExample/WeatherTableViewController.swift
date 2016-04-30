
import UIKit
import CoreLocation
import AddressBookUI
import CoreData



class WeatherTableViewController: UITableViewController {

    let LabelCell="CustomCell1"
    let LabelCell2="CustomCell2"
    var cityID:Int!
    var cityName:String!
    var coords:String!
    let calendar = NSCalendar.currentCalendar()
    let coreDataManager=CoreDataManager()
    let apiOperations=ApiOperations()
    let week=["Sunday","Monday","Tuesday","Wednesday","Thursday","Friday","Saturday"]

    override func viewDidLoad()
    {
        super.viewDidLoad()
        let imageView=UIImageView(image: UIImage(named: "background"))
        imageView.contentMode = .ScaleAspectFill
        self.tableView.backgroundView=imageView
        self.coreDataManager.viewWillAppear()
        let status=Reach().connectionStatus()
        switch  status
        {
        case .Unknown,.Offline:
            let weatherIDs=self.coreDataManager.weatherArray.map{$0.indexOfCity}
            if !weatherIDs.contains(self.cityID)
            {
                navigationController?.popViewControllerAnimated(true)
            }
            break
        default:
            let json=self.apiOperations.convertToJSON(coords)
            self.apiOperations.fillWeatherData(json!,idOfCity: self.cityID)
            break
        }
    }
    
    override func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath)
    {
        cell.backgroundColor = .clearColor()
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return 7
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        self.coreDataManager.viewWillAppear()
        let currentWeather=coreDataManager.getWeatherForCurrentCity(self.cityID)
        var cell:UITableViewCell
        if(indexPath.row==0)
        {
            cell=tableView.dequeueReusableCellWithIdentifier(self.LabelCell, forIndexPath: indexPath)
            let cell1=cell as! CustomCell1
            tableView.rowHeight=250
            
            if currentWeather.count>0
            {
               let components = self.calendar.components(.Weekday, fromDate: NSDate())
               cell1.dayOfWeekLabel.text=week[components.weekday-1]
               cell1.temperatureLabel.text="\(currentWeather[indexPath.row].temperature)ºC"
               cell1.humidityLabel.text="\(currentWeather[indexPath.row].humidity)%"
               cell1.pressureLabel.text="\(currentWeather[indexPath.row].pressure) mmHg"
               cell1.summaryLabel.text="\(currentWeather[indexPath.row].summary)"
               cell1.windLabel.text="\(currentWeather[indexPath.row].windSpeed) m/s"
               cell1.icon.image=UIImage(named: currentWeather[indexPath.row].icon)
            }
        }
        else
        {
            cell=tableView.dequeueReusableCellWithIdentifier(self.LabelCell2, forIndexPath: indexPath)
            let cell2=cell as! CustomCell2
            tableView.rowHeight=140
            
            if currentWeather.count>0
            {
               let thatDay=self.calendar.dateByAddingUnit(.Weekday, value: indexPath.row, toDate: NSDate(), options: [])
               let components=self.calendar.components(.Weekday,fromDate: thatDay!)
            
               cell2.dayOfWeekLabel.text=week[components.weekday-1]
               cell2.maxTempLabel.text="\(currentWeather[indexPath.row].maxTemperature)ºC"
               cell2.minTempLabel.text="\(currentWeather[indexPath.row].minTemperature)ºC"
               cell2.humidityLabel.text="\(currentWeather[indexPath.row].humidity)%"
               cell2.windLabel.text="\(currentWeather[indexPath.row].windSpeed)m/s"
               cell2.icon.image=UIImage(named: currentWeather[indexPath.row].icon)
            }
        }
        return cell
    }
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String?
    {
        return self.cityName
    }
}


