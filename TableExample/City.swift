//
//  City.swift
//  WeatherApp
//
//  Created by Admin on 27.04.16.
//  Copyright © 2016 Admin. All rights reserved.
//

import Foundation
import CoreData

class City:NSManagedObject
{
    @NSManaged var name:String
    @NSManaged var id:Int
    func saveCity(name:String,id:Int,inManagedObjectContext managedObjectContext: NSManagedObjectContext!)
    {
        self.name=name
        self.id=id 
        do{try managedObjectContext.save()}catch{}
    }
}
