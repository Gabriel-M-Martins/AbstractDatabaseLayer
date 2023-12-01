//
//  AppDelegate.swift
//  AbstractDatabaseLayerPlayground
//
//  Created by Gabriel Medeiros Martins on 08/11/23.
//

import Foundation
import UIKit

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        
        Dependencies.register(CoreDataRepository<Recipe>("RecipeEntity"), for: (any Repository<Recipe>).self)
        Dependencies.register(CoreDataRepository<Step>("StepEntity"), for: (any Repository<Step>).self)
        Dependencies.register(CoreDataRepository<Placeholder>("PlaceholderEntity"), for: (any Repository<Placeholder>).self)
        Dependencies.register(CoreDataRepository<Tag>("TagEntity"), for: (any Repository<Tag>).self)
        Dependencies.register(CoreDataRepository<Cookbook>("CookbookEntity"), for: (any Repository<Cookbook>).self)
        
        return true
    }
}
