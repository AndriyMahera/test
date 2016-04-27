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
        let entity =  NSEntityDescription.entityForName("City",inManagedObjectContext:managedContext)
        let city = NSManagedObject(entity: entity!,insertIntoManagedObjectContext: managedContext) as? City
        city?.saveCity(name,id: self.findSuitableId(),inManagedObjectContext: managedContext)
        cities.append(city!)
        self.viewWillAppear()
    }
    func deleteCity(index:Int)
    {
        let appDel:AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let context:NSManagedObjectContext = appDel.managedObjectContext
        context.deleteObject(cities[index])
        cities.removeAtIndex(index)
        do
        {
            try context.save()
        }
        catch{}
        self.viewWillAppear()
    }
    func findIndexOfCity(name:String)->Int?
    {
        if cities.count==0{return nil}
        for index in 0...self.cities.count-1
        {

            if self.cities[index].name==name
            {
                return self.cities[index].id
            }
        }
        return nil
    }
    func addWeatherOnDay(weatherDict:NSDictionary,isCurrent:Bool,name:String)
    {
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let managedContext = appDelegate.managedObjectContext
        let weatherEntity =  NSEntityDescription.entityForName("WeatherEntity",inManagedObjectContext:managedContext)
        let weather = NSManagedObject(entity: weatherEntity!,insertIntoManagedObjectContext: managedContext) as? Weather
        weather?.saveWithWeatherDictionary(weatherDict as! [String : AnyObject], current: isCurrent, index:self.findIndexOfCity(name)!,inManagedObjectContext: managedContext)
        weatherArray.append(weather!)
        self.viewWillAppear()
    }
    func deleteWeatherOnDay(index:Int)
    {
        let appDel:AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let context:NSManagedObjectContext = appDel.managedObjectContext
        context.deleteObject(weatherArray[index])
        weatherArray.removeAtIndex(index)
        do
        {
            try context.save()
        }
        catch{}
        self.viewWillAppear()
    }
    func deleteWeatherOnWeek(indexOfCity:Int)
    {
        if self.weatherArray.count>0
        {
            let weatherIDs=self.weatherArray.map{$0.indexOfCity}
            if weatherIDs.contains(indexOfCity)
            {
            var amount=0
            while(amount<7)
            {
                var index=0
                if self.weatherArray[index].indexOfCity==indexOfCity
                {
                    self.deleteWeatherOnDay(index)
                    index=index-1
                    amount=amount+1
                }
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
        let fetchRequest = NSFetchRequest(entityName: "City")
        do
        {
            let results = try managedContext.executeFetchRequest(fetchRequest)
            cities = results as! [City]
        }
        catch  {}
        let fetchRequest2 = NSFetchRequest(entityName: "WeatherEntity")
        do
        {
            let results = try managedContext.executeFetchRequest(fetchRequest2)
            weatherArray = results as! [Weather]
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
    func getWeatherForCurrentCity(cityName:String)->[Weather]
    {
        var currentCityWeather=[Weather]()
        let indexOfCity=self.findIndexOfCity(cityName)
        for ind in 0...self.weatherArray.count-1
        {
            if self.weatherArray[ind].indexOfCity==indexOfCity
            {
                currentCityWeather.append(self.weatherArray[ind])
            }
        }
        return currentCityWeather
    }
}
