//
//  WeatherStructure.swift
//  WeatherApp
//
//  Created by Admin on 20.04.16.
//  Copyright © 2016 Admin. All rights reserved.
//

import Foundation
import CoreData

class Weather:NSManagedObject
{
    @NSManaged var maxTemperature:Int
    @NSManaged var minTemperature:Int
    @NSManaged var temperature:Int
    @NSManaged var humidity:Int
    @NSManaged var precipProbability:Int
    @NSManaged var summary:String
    @NSManaged var pressure:Int
    @NSManaged var windSpeed:Int
    @NSManaged var icon:String
    @NSManaged var indexOfCity:Int
    
    func saveWithWeatherDictionary(weatherDictionary:[String:AnyObject],current:Bool, index:Int,inManagedObjectContext managedObjectContext: NSManagedObjectContext!)
    {
        if(current)
        {
            self.temperature=Int(5.0/9.0*(weatherDictionary["temperature"] as! Double-32))
            maxTemperature=100;
            minTemperature=100;
        }
        else
        {
            maxTemperature=Int(5.0/9.0*(weatherDictionary["temperatureMax"] as! Double-32))
            minTemperature=Int(5.0/9.0*(weatherDictionary["temperatureMin"] as! Double-32))
            temperature=100;
        }
        let floatHumidity=weatherDictionary["humidity"] as!Double
        humidity=Int(floatHumidity*100)
        let floatProbability=weatherDictionary["precipProbability"] as! Double
        precipProbability=Int(floatProbability*100)
        summary=weatherDictionary["summary"] as! String
        pressure=Int(weatherDictionary["pressure"] as! Double * 0.725)
        windSpeed=weatherDictionary["windSpeed"] as! Int
        icon=weatherDictionary["icon"] as! String
        indexOfCity=index
        
        try? managedObjectContext.save()
    }
}
