//
//  AppDelegate.swift
//  NellodeeV0.0
//
//  Created by ahmed moussa on 11/12/15.
//  Copyright © 2015 ahmed moussa. All rights reserved.
//

import UIKit
import CoreData

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    let defaults = NSUserDefaults.standardUserDefaults()
    
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Override point for customization after application launch.
        //-------------------- ----------------- set number of pages of book
        let path = NSBundle.mainBundle().pathForResource("Frankenstein", ofType: "pdf")! //pdfBook2//Frankenstein//circuitsBook//cooperPDF
        let url = NSURL.fileURLWithPath(path)
        let pdf = CGPDFDocumentCreateWithURL(url)
        glblLog.numberOfPages = CGPDFDocumentGetNumberOfPages(pdf)
        //-------------------- -------------- ends
        
        
        retrieveSavedData()
        jsonLogger.readDataFile()
        jsonLogger.writeApplicationStatus("Nellodee Finished Launching")
        return true
    }
    
    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
        jsonLogger.writeApplicationStatus("Nellodee Became inactive")
    }
    
    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
        print(glblLog.currentSession.toString())
        self.saveData()
        jsonLogger.writeApplicationStatus("Nellodee Entered Background")
        jsonLogger.writeSession(glblLog.currentSession)
    }
    
    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
        
        jsonLogger.writeApplicationStatus("Nellodee Entered Foreground")
    }
    
    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        
        jsonLogger.writeApplicationStatus("Nellodee Became Active")
    }
    
    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        // Saves changes in the application's managed object context before the application terminates.
        
        jsonLogger.writeApplicationStatus("Nellodee Closed")
        jsonLogger.writeSession(glblLog.currentSession)
        self.saveData()
        self.saveContext()
    }
    
    // MARK: - Core Data stack
    
    lazy var applicationDocumentsDirectory: NSURL = {
        // The directory the application uses to store the Core Data store file. This code uses a directory named "com.example.NellodeeV0_0" in the application's documents Application Support directory.
        let urls = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)
        return urls[urls.count-1]
    }()
    
    lazy var managedObjectModel: NSManagedObjectModel = {
        // The managed object model for the application. This property is not optional. It is a fatal error for the application not to be able to find and load its model.
        let modelURL = NSBundle.mainBundle().URLForResource("NellodeeV0_0", withExtension: "momd")!
        return NSManagedObjectModel(contentsOfURL: modelURL)!
    }()
    
    lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator = {
        // The persistent store coordinator for the application. This implementation creates and returns a coordinator, having added the store for the application to it. This property is optional since there are legitimate error conditions that could cause the creation of the store to fail.
        // Create the coordinator and store
        let coordinator = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
        let url = self.applicationDocumentsDirectory.URLByAppendingPathComponent("SingleViewCoreData.sqlite")
        var failureReason = "There was an error creating or loading the application's saved data."
        do {
            try coordinator.addPersistentStoreWithType(NSSQLiteStoreType, configuration: nil, URL: url, options: nil)
        } catch {
            // Report any error we got.
            var dict = [String: AnyObject]()
            dict[NSLocalizedDescriptionKey] = "Failed to initialize the application's saved data"
            dict[NSLocalizedFailureReasonErrorKey] = failureReason
            
            dict[NSUnderlyingErrorKey] = error as NSError
            let wrappedError = NSError(domain: "YOUR_ERROR_DOMAIN", code: 9999, userInfo: dict)
            // Replace this with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog("Unresolved error \(wrappedError), \(wrappedError.userInfo)")
            abort()
        }
        
        return coordinator
    }()
    
    lazy var managedObjectContext: NSManagedObjectContext = {
        // Returns the managed object context for the application (which is already bound to the persistent store coordinator for the application.) This property is optional since there are legitimate error conditions that could cause the creation of the context to fail.
        let coordinator = self.persistentStoreCoordinator
        var managedObjectContext = NSManagedObjectContext(concurrencyType: .MainQueueConcurrencyType)
        managedObjectContext.persistentStoreCoordinator = coordinator
        return managedObjectContext
    }()
    
    // MARK: - Core Data Saving support
    
    func saveContext () {
        if managedObjectContext.hasChanges {
            do {
                try managedObjectContext.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                NSLog("Unresolved error \(nserror), \(nserror.userInfo)")
                abort()
            }
        }
    }
    func retrieveSavedData(){
        //jsonLogger.writeApplicationStatus("Nellodee Opened")
        //retrieveAllSessions()
        var startDate = ""
        var endDate = ""
        var currentSessionSelectorState = ""
        var currentSessionNumberOfDaysPassed = 0
        var currentSessionExpectedPagesPerDay = 10
        var timePerDay = [Int]()
        var startPages = [Int]()
        var endPages = [Int]()
        var actualPagesPerDay = [[Int]]()
        //-------------------------------------------------------------------> startDate retrieval
        if let SD: Optional = self.defaults.stringForKey("currentSessionStartDate")
        {
            if(SD != nil){
                startDate = SD!
            }
        }
        else{
            startDate = "1/1/2016"
        }
        //------------------------------------------------------------------> endDate retrieval
        if let ED: Optional = self.defaults.stringForKey("currentSessionEndDate")
        {
            if(ED != nil){
                endDate = ED!
            }
        }
        else{
            endDate = "1/10/2016"
        }
        //------------------------------------------------------------------> currentSessionSelectorState retrieval
        if let SS: Optional = self.defaults.stringForKey("currentSessionSelectorState")
        {
            if(SS != nil){
                currentSessionSelectorState = SS!
            }
        }
        else{
            currentSessionSelectorState = "pagesPerDay"
        }
        //------------------------------------------------------------------> currentSessionSelectorState retrieval
        if let EPPD: Optional = self.defaults.integerForKey("currentSessionExpectedPagesPerDay")
        {
            if(EPPD != nil && EPPD! > 0){
                currentSessionExpectedPagesPerDay = EPPD!
            }
        }
        
        //------------------------------------------------------------------> currentSession initiation
        glblLog.addSession(session(startDate: startDate, endDate: endDate, expectedPagesPerDay: currentSessionExpectedPagesPerDay, state: currentSessionSelectorState, numberOfDaysPassed: 0))
        //------------------------------------------------------------------> currentSessionNumberOfDaysPassed retrieval
        if let ND: Optional = self.defaults.integerForKey("currentSessionNumberOfDaysPassed")
        {
            if(ND != 0){
                currentSessionNumberOfDaysPassed = ND!
            }
        }
        
        
        //------------------------------------------------------------------> timePerDay retrieval
        if let TPD: Optional = self.defaults.stringArrayForKey("timePerDay")
        {
            if(TPD != nil){
                for temp in TPD!{
                    timePerDay.append(Int(temp)!)
                }
            }
        }
        else{
            timePerDay.append(0)
        }
        
        //------------------------------------------------------------------> startDaysStringArray retrieval
        if let SP: Optional = self.defaults.stringArrayForKey("startPagesStringArray")
        {
            if(SP != nil){
                for temp in SP!{
                    startPages.append(Int(temp)!)
                }
            }
        }
        else{
            startPages.append(0)
        }
        
        //------------------------------------------------------------------> endPagesStringArray retrieval
        if let EP: Optional = self.defaults.stringArrayForKey("endPagesStringArray")
        {
            if(EP != nil){
                for temp in EP!{
                    endPages.append(Int(temp)!)
                }
            }
        }
        else{
            endPages.append(0)
        }
        
        //------------------------------------------------------------------> actualPagesPerDay retrieval
        var j = 0
        while(j <= currentSessionNumberOfDaysPassed){
            actualPagesPerDay.append([Int]())
            if let APPD: Optional = self.defaults.stringArrayForKey("actualPagesPerDay\(j)")
            {
                if(APPD != nil){
                    for temp in APPD!{
                        actualPagesPerDay[j].append(Int(temp)!)
                    }
                }
            }
            j++
        }
        
        //------------------------------------------------------------------> setting the current Session Data
        if(timePerDay.count == glblLog.currentSession.days.count){
            glblLog.currentSession.numberOfDaysPassed = currentSessionNumberOfDaysPassed
            
            var i = 0
            for temp in glblLog.currentSession.days{
                temp.startPage = startPages[i]
                temp.endPage = endPages[i]
                temp.expectedPages = temp.endPage - temp.startPage
                temp.time = timePerDay[i]
                if(i <= currentSessionNumberOfDaysPassed){
                    for tempPages in actualPagesPerDay[i]{
                        temp.pages.append(page(pageNumber: tempPages, time: 0))
                    }
                }
                i++
            }
        }
        retrievePreviousDays()
        
        
    }
    func retrievePreviousDays(){
        var previousDaysStartPagesString = [Int]()
        var previousDaysEndPagesString = [Int]()
        var previousDaysTimeOnDay = [Int]()
        var previousDaysPagesReadAtIndexDay = [[Int]]()
        var previousDaysCount = 0
        //------------------------------------------------------------------> previousDaysCount retrieval
        if let ND: Optional = self.defaults.integerForKey("previousDaysCount")
        {
            if(ND != 0){
                previousDaysCount = ND!
            }
        }
        
        //------------------------------------------------------------------> timePerDay retrieval
        if let TPD: Optional = self.defaults.stringArrayForKey("previousDaysTimeOnDay")
        {
            if(TPD != nil){
                for temp in TPD!{
                    previousDaysTimeOnDay.append(Int(temp)!)
                }
            }
        }
        else{
            previousDaysTimeOnDay.append(0)
        }
        
        //------------------------------------------------------------------> startDaysStringArray retrieval
        if let SP: Optional = self.defaults.stringArrayForKey("previousDaysStartPagesString")
        {
            if(SP != nil){
                for temp in SP!{
                    previousDaysStartPagesString.append(Int(temp)!)
                }
            }
        }
        else{
            previousDaysStartPagesString.append(0)
        }
        
        //------------------------------------------------------------------> endPagesStringArray retrieval
        if let EP: Optional = self.defaults.stringArrayForKey("previousDaysEndPagesString")
        {
            if(EP != nil){
                for temp in EP!{
                    previousDaysEndPagesString.append(Int(temp)!)
                }
            }
        }
        else{
            previousDaysEndPagesString.append(0)
        }
        
        //------------------------------------------------------------------> actualPagesPerDay retrieval
        var j = 0
        while(j <= previousDaysCount){
            previousDaysPagesReadAtIndexDay.append([Int]())
            if let APPD: Optional = self.defaults.stringArrayForKey("PreviousDaysActualPagesPerDay\(j)")
            {
                if(APPD != nil){
                    for temp in APPD!{
                        previousDaysPagesReadAtIndexDay[j].append(Int(temp)!)
                    }
                }
            }
            j++
        }
        
        //------------------------------------------------------------------> setting the previous days Data
        var i = 0
        while(i < previousDaysCount){
            let temp = day(expectedNumOfPages: (previousDaysEndPagesString[i] - previousDaysStartPagesString[i]), startPage: previousDaysStartPagesString[i], endPage: previousDaysEndPagesString[i])
            temp.time = previousDaysTimeOnDay[i]
            if(i <= previousDaysCount){
                for tempPages in previousDaysPagesReadAtIndexDay[i]{
                    temp.pages.append(page(pageNumber: tempPages, time: 0))
                }
            }
            glblLog.currentSession.previousDays.append(temp)
            i++
        }
        i = previousDaysCount - 1
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateStyle = NSDateFormatterStyle.ShortStyle
        while(i>0){
            if #available(iOS 8.0, *) {
                glblLog.currentSession.previousDays[i].date = dateFormatter.stringFromDate(NSCalendar.currentCalendar().dateByAddingUnit(NSCalendarUnit.Day, value: i, toDate: NSDate(), options: [])!)
            } else {
                // Fallback on earlier versions
            }
            i--
        }
        /*
        //------------------------------ --------------- New day when opening app ---------------- -------------- -----------
        //let dateFormatter = NSDateFormatter()
        let todaysDate = dateFormatter.stringFromDate(NSDate())
        var currentSessionLastDateReached = todaysDate
        if(glblLog.currentSession.days.count > 0)
        {
            currentSessionLastDateReached = glblLog.currentSession.days[glblLog.currentSession.numberOfDaysPassed].date
        }
        let dateComparison = dateFormatter.dateFromString(currentSessionLastDateReached)!.compare(NSDate()).rawValue
        if(currentSessionLastDateReached != todaysDate && dateComparison < 1){
            glblLog.currentSession.setNextDayStartPage(glblLog.currentPageNumber)
            glblLog.currentSession.numberOfDaysPassed++
            print("numberOfDaysPassed added todays date: \(todaysDate) and session.days[numberOfDaysPassed - 1] = \(glblLog.currentSession.days[glblLog.currentSession.numberOfDaysPassed - 1].date)")
        }
        else{
            print("numberOfDaysPassed \n added todays date: \(todaysDate) ")
        }
        //------------------------------ --------------- New day when opening app ---------------- -------------- -----------
        */
        //days[i].date = dateFormatter.stringFromDate(NSCalendar.currentCalendar().dateByAddingUnit(NSCalendarUnit.Day, value: i, toDate: NSDate(), options: [])!)
    }
    func saveData(){
        defaults.setObject(glblLog.currentPageNumber, forKey: "currentPageNumber")
        let stringArray2 = glblLog.timeAtPageIndex.map({
            (number: Int) -> String in
            return String(number)
        })
        defaults.setObject(stringArray2, forKey: "timeAtPageIndex")
        
        
        defaults.setObject(glblLog.currentSession.numberOfDaysPassed, forKey: "currentSessionNumberOfDaysPassed")
        defaults.setObject(glblLog.currentSession.state, forKey: "currentSessionSelectorState")
        defaults.setObject(glblLog.currentSession.startDate, forKey: "currentSessionStartDate")
        defaults.setObject(glblLog.currentSession.endDate, forKey: "currentSessionEndDate")
        defaults.setObject(glblLog.currentSession.expectedPagesPerDay, forKey: "currentSessionExpectedPagesPerDay")
        
        var startPagesString = [String]()
        var endPagesString = [String]()
        var timeOnDay = [String]()
        var pagesReadAtIndexDay = [[String]]()
        var i = 0
        var j = 0
        for temp in glblLog.currentSession.days{
            startPagesString.append("\(temp.startPage)")
            endPagesString.append("\(temp.endPage)")
            timeOnDay.append("\(temp.time)")
            pagesReadAtIndexDay.append([String]())
            for tempPage in temp.pages{
                
                pagesReadAtIndexDay[i].append("\(tempPage.pageNumber)")
                j++
            }
            defaults.setObject(pagesReadAtIndexDay[i], forKey: "actualPagesPerDay\(i)")
            i++
        }
        defaults.setObject(timeOnDay, forKey: "timePerDay")
        defaults.setObject(startPagesString, forKey: "startPagesStringArray")
        defaults.setObject(endPagesString, forKey: "endPagesStringArray")
        //-----------------------------Saving previous days--------------------------------/
        defaults.setObject(glblLog.currentSession.previousDays.count, forKey: "previousDaysCount")
        if(glblLog.currentSession.previousDays.count > 0){
            var previousDaysStartPagesString = [String]()
            var previousDaysEndPagesString = [String]()
            var previousDaysTimeOnDay = [String]()
            var previousDaysPagesReadAtIndexDay = [[String]]()
            var i = 0
            var j = 0
            
            for temp in glblLog.currentSession.previousDays{
                previousDaysStartPagesString.append("\(temp.startPage)")
                previousDaysEndPagesString.append("\(temp.endPage)")
                previousDaysTimeOnDay.append("\(temp.time)")
                previousDaysPagesReadAtIndexDay.append([String]())
                for tempPage in temp.pages{
                    
                    previousDaysPagesReadAtIndexDay[i].append("\(tempPage.pageNumber)")
                    j++
                }
                defaults.setObject(previousDaysPagesReadAtIndexDay[i], forKey: "PreviousDaysActualPagesPerDay\(i)")
                i++
            }
            defaults.setObject(previousDaysTimeOnDay, forKey: "previousDaysTimeOnDay")
            defaults.setObject(previousDaysStartPagesString, forKey: "previousDaysStartPagesString")
            defaults.setObject(previousDaysEndPagesString, forKey: "previousDaysEndPagesString")
        }
        //-----------------------------Saving previous days--------------------------------/
        
    }

}

