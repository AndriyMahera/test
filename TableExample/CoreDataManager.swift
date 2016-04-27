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
    var cities = [NSManagedObject]()
    var weatherArray = [NSManagedObject]()
    
    func addCity(name:String)
    {
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let managedContext = appDelegate.managedObjectContext
        let entity =  NSEntityDescription.entityForName("City",inManagedObjectContext:managedContext)
        let element = NSManagedObject(entity: entity!,insertIntoManagedObjectContext: managedContext)
        element.setValue(name, forKey: "name")
        do
        {
            try managedContext.save()
            cities.append(element)
        }
        catch let error as NSError
        {
            print("Could not save \(error), \(error.userInfo)")
        }
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
    }
    func findIndexOfCity(name:String)->Int?
    {
        if cities.count==0{return nil}
        for index in 0...self.cities.count-1
        {

            if self.cities[index].valueForKey("name") as? String==name
            {
                return index
            }
        }
        return nil
    }
    func addWeatherOnDay(weatherDict:NSDictionary,isCurrent:Bool)
    {
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let managedContext = appDelegate.managedObjectContext
        let weatherEntity =  NSEntityDescription.entityForName("WeatherEntity",inManagedObjectContext:managedContext)
        let weather = NSManagedObject(entity: weatherEntity!,insertIntoManagedObjectContext: managedContext) as? Weather
        weather?.saveWithWeatherDictionary(weatherDict as! [String : AnyObject], current: isCurrent, inManagedObjectContext: managedContext)
        weatherArray.append(weather!)
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
    }

    func viewWillAppear() {
        let appDelegate =
            UIApplication.sharedApplication().delegate as! AppDelegate
        let managedContext = appDelegate.managedObjectContext
        let fetchRequest = NSFetchRequest(entityName: "City")
        do
        {
            let results = try managedContext.executeFetchRequest(fetchRequest)
            cities = results as! [NSManagedObject]
        }
        catch  {}
        let fetchRequest2 = NSFetchRequest(entityName: "WeatherEntity")
        do
        {
            let results = try managedContext.executeFetchRequest(fetchRequest2)
            weatherArray = results as! [NSManagedObject]
        }
        catch  {}
    }

    


}
