//
//  ApiOperations.swift
//  WeatherApp
//
//  Created by Admin on 27.04.16.
//  Copyright © 2016 Admin. All rights reserved.
//

import Foundation

class ApiOperations
{
    let baseURLGoogle=NSURL(string:"https://maps.googleapis.com/maps/api/geocode/json?")
    let googleApiKey="AIzaSyC07iqLskaXEGnbXN1Oc04goTmnBhKOlck"
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
    func fillWeatherData(json : NSDictionary,nameOfCity:String)
    {
        if let currently=json["currently"] as? NSDictionary
        {
            coreDataManager.viewWillAppear()
            
            let ind=coreDataManager.findIndexOfCity(nameOfCity)!
            coreDataManager.deleteWeatherOnWeek(ind)
            
            coreDataManager.addWeatherOnDay(currently, isCurrent: true,name: nameOfCity)
        }
        if let daily=json["daily"] as? NSDictionary
        {
            if let data=daily["data"] as? [NSDictionary]
            {
                for index in 0...5
                {
                    coreDataManager.addWeatherOnDay(data[index], isCurrent: false,name: nameOfCity)
                }
            }
            print(coreDataManager.weatherArray)
        }
    }


}