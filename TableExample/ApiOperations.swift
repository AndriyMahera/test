//
//  ApiOperations.swift
//  WeatherApp
//
//  Created by Admin on 27.04.16.
//  Copyright © 2016 Admin. All rights reserved.
//

import Foundation
import SystemConfiguration

class ApiOperations
{
    let baseURLGoogle=NSURL(string:"https://maps.googleapis.com/maps/api/geocode/json?")
    let googleApiKey="AIzaSyC07iqLskaXEGnbXN1Oc04goTmnBhKOlck"
    let apiKey="4e39340c48a7b3a9307503a14a16e14e"
    let coreDataManager=CoreDataManager()
    

    
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
    func convertToJSON(coords:String)->NSDictionary?
    {
        let baseURL = NSURL(string: "https://api.forecast.io/forecast/\(self.apiKey)/")
        let forecastURL = NSURL(string:coords, relativeToURL: baseURL)
        let data = NSData(contentsOfURL: forecastURL!)
        do
        {
            let json=try NSJSONSerialization.JSONObjectWithData(data!, options: []) as! NSDictionary
            return json
        }
        catch{}
        return nil
    }
    func fillWeatherData(json : NSDictionary,idOfCity:Int)
    {
        if let currently=json["currently"] as? NSDictionary
        {
            coreDataManager.viewWillAppear()
            coreDataManager.deleteWeatherOnWeek(idOfCity)
            coreDataManager.addWeatherOnDay(currently, isCurrent: true,id: idOfCity)
        }
        if let daily=json["daily"] as? NSDictionary
        {
            if let data=daily["data"] as? [NSDictionary]
            {
                for index in 1...6
                {
                    coreDataManager.addWeatherOnDay(data[index], isCurrent: false,id: idOfCity)
                }
            }
            print(coreDataManager.weatherArray)
        }
    }
}