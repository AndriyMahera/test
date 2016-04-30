//
//  CoreDataManager.swift
//  WeatherApp
//
//  Created by Admin on 26.04.16.
//  Copyright © 2016 Admin. All rights reserved.
//

import Foundation
import UIKit
import CoreData


class CoreDataManager
{
    var cities = [City]()
    var weatherArray = [Weather]()
    
    func addCity(name:String)
    {
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let managedContext = appDelegate.managedObjectContext
        let entity =  NSEntityDescription.entityForName("CityEntity",inManagedObjectContext:managedContext)
        let city = NSManagedObject(entity: entity!,insertIntoManagedObjectContext: managedContext) as? City
        city?.saveCity(name,id: self.findSuitableId(),inManagedObjectContext: managedContext)
        self.cities.append(city!)
        self.viewWillAppear()
    }
    
    func deleteCity(index:Int)
    {
        let appDel:AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let context:NSManagedObjectContext = appDel.managedObjectContext
        context.deleteObject(cities[index])
        self.cities.removeAtIndex(index)
        do
        {
            try context.save()
        }
        catch{}
        self.viewWillAppear()
    }
    
    func addWeatherOnDay(weatherDict:NSDictionary,isCurrent:Bool,id:Int)
    {
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let managedContext = appDelegate.managedObjectContext
        let weatherEntity =  NSEntityDescription.entityForName("WeatherEntity",inManagedObjectContext:managedContext)
        let weather = NSManagedObject(entity: weatherEntity!,insertIntoManagedObjectContext: managedContext) as? Weather
        weather?.saveWithWeatherDictionary(weatherDict as! [String : AnyObject], current: isCurrent, index:id,inManagedObjectContext: managedContext)
        self.weatherArray.append(weather!)
        self.viewWillAppear()
    }
    
    func deleteWeatherOnDay(index:Int)
    {
        let appDel:AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let context:NSManagedObjectContext = appDel.managedObjectContext
        context.deleteObject(weatherArray[index])
        self.weatherArray.removeAtIndex(index)
        do
        {
            try context.save()
        }
        catch{}
    }
    
    func deleteWeatherOnWeek(indexOfCity:Int)
    {
        if self.weatherArray.count>0
        {
            let weatherIDs=self.weatherArray.map{$0.indexOfCity}
            if weatherIDs.contains(indexOfCity)
            {
            var amount=0
            var index=0
            while(amount<7)
            {
                if self.weatherArray[index].indexOfCity==indexOfCity
                {
                    self.deleteWeatherOnDay(index)
                    index=index-1
                    amount=amount+1
                }
                index=index+1
            }
            }
            else
            {
                return
            }
            self.viewWillAppear()
        }

    }

    func viewWillAppear() {
        let appDelegate =
            UIApplication.sharedApplication().delegate as! AppDelegate
        let managedContext = appDelegate.managedObjectContext
        let fetchRequest = NSFetchRequest(entityName: "CityEntity")
        do
        {
            let results = try managedContext.executeFetchRequest(fetchRequest)
            self.cities = results as! [City]
        }
        catch  {}
        let fetchRequest2 = NSFetchRequest(entityName: "WeatherEntity")
        do
        {
            let results = try managedContext.executeFetchRequest(fetchRequest2)
            self.weatherArray = results as! [Weather]
        }
        catch  {}
    }
    
    func findSuitableId()->Int
    {
        let citiesIDs=self.cities.map{$0.id}
        var i=0
        while citiesIDs.contains(i)
        {
            i=i+1
        }
        return i
    }
    
    func getWeatherForCurrentCity(cityID:Int)->[Weather]
    {
        var currentCityWeather=[Weather]()
        for ind in 0...self.weatherArray.count-1
        {
            if self.weatherArray[ind].indexOfCity==cityID
            {
                currentCityWeather.append(self.weatherArray[ind])
            }
        }
        return currentCityWeather
    }
}
