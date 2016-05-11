//
//  json.swift
//  NellodeeV1.0
//
//  Created by ahmed moussa on 4/6/16.
//  Copyright © 2016 ahmed moussa. All rights reserved.
//

import Foundation

class json{
    var interactionFileName = "test6"
    var dataFileName = "dataFile"
    var documentsDirectoryPathString: String
    let documentsDirectoryPath: NSURL
    let interactionJsonFilePath: NSURL
    let dataJsonFilePath: NSURL
    
    let fileManager = NSFileManager.defaultManager()
    var isDirectory: ObjCBool = false
    
    let dateFormatter = NSDateFormatter()
    
    //let userInteractionContent =
    
    init(){
        dateFormatter.dateStyle = NSDateFormatterStyle.MediumStyle
        dateFormatter.timeStyle = NSDateFormatterStyle.ShortStyle
        
        let calendar = NSCalendar.currentCalendar()
        let components = calendar.components([.Day , .Month , .Year], fromDate: NSDate())
        
        let year =  components.year
        let month = components.month
        let day = components.day
        
        print(year)
        print(month)
        print(day)
        
        interactionFileName = "d\(day)m\(month)y\(year)"
        
        documentsDirectoryPathString = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true).first!
        documentsDirectoryPath = NSURL(string: documentsDirectoryPathString)!
        
        interactionJsonFilePath = documentsDirectoryPath.URLByAppendingPathComponent("\(interactionFileName).json")
        dataJsonFilePath = documentsDirectoryPath.URLByAppendingPathComponent("\(dataFileName).json")
        
        // creating a .json interaction file in the Documents folder
        if !fileManager.fileExistsAtPath(interactionJsonFilePath.absoluteString, isDirectory: &isDirectory) {
            let created = fileManager.createFileAtPath(interactionJsonFilePath.absoluteString, contents: nil, attributes: nil)
            if created {
                print("interaction File created ")
            } else {
                print("Couldn't create interaction file for some reason")
            }
        } else {
            print("interaction File already exists for this date")
        }
        
        // creating a .json data file in the Documents folder
        if !fileManager.fileExistsAtPath(dataJsonFilePath.absoluteString, isDirectory: &isDirectory) {
            let created = fileManager.createFileAtPath(dataJsonFilePath.absoluteString, contents: nil, attributes: nil)
            if created {
                print("data File created ")
            } else {
                print("Couldn't create data file for some reason")
            }
        } else {
            print("data File already exists")
        }
    }
    func writeToInteractionFile(what: [String: [String]]){
        //let contents: [String: AnyObject] = [String(NSDate()): [readFile(), what]]
        // creating JSON out of the above array
        var jsonData: NSData!
        do {
            jsonData = try NSJSONSerialization.dataWithJSONObject(what, options: NSJSONWritingOptions())
            //let jsonString = String(data: jsonData, encoding: NSUTF8StringEncoding)
            //print(jsonString)
        } catch let error as NSError {
            print("Array to JSON conversion failed: \(error.localizedDescription)")
        }
        do {
            let file = try NSFileHandle(forWritingToURL: interactionJsonFilePath)
            file.seekToEndOfFile()
            //let endl = "\n".dataUsingEncoding(NSStringEncoding)
            file.writeData(jsonData)
            //print("JSON data was written to teh file successfully!")
        } catch let error as NSError {
            print("Couldn't write to file: \(error.localizedDescription)")
        }
    }
    func writeToDataFile(what: [String: AnyObject]){
        //let contents: [String: AnyObject] = [String(NSDate()): [readFile(), what]]
        // creating JSON out of the above array
        var jsonData: NSData!
        do {
            jsonData = try NSJSONSerialization.dataWithJSONObject(what, options: NSJSONWritingOptions())
            //let jsonString = String(data: jsonData, encoding: NSUTF8StringEncoding)
            //print(jsonString)
        } catch let error as NSError {
            print("Array to JSON conversion failed: \(error.localizedDescription)")
        }
        do {
            let file = try NSFileHandle(forWritingToURL: dataJsonFilePath)
            let text = ""
            file.truncateFileAtOffset(0)
            file.writeData(jsonData)
            //print("JSON data was written to teh file successfully!")
        } catch let error as NSError {
            print("Couldn't write to file: \(error.localizedDescription)")
        }
    }
    func writeChangedPage(newPageNumber: Int, direction: String){
        var numbers = [String]()
        numbers.append("\(newPageNumber)")
        let dictToWrite: [String: [String]] = ["Action: ": ["\(direction) Button Clicked"], "at time:": [dateFormatter.stringFromDate(NSDate())], "New Page Number": numbers]
        writeToInteractionFile(dictToWrite)
        
    }
    func writeSegue(desitination: String){
        let dictToWrite: [String: [String]] = ["Action: ": ["Segued To \(desitination)"], "at time:": [dateFormatter.stringFromDate(NSDate())]]
        writeToInteractionFile(dictToWrite)
        
    }
    func writeBurgerClicked(){
        let dictToWrite: [String: [String]] = ["Action: ": ["Burger Clicked"], "at time:": [dateFormatter.stringFromDate(NSDate())]]
        writeToInteractionFile(dictToWrite)
    }
    func writeGoalChangesSet(from: String, fromType: String, to: String, toType: String){
        let dictToWrite: [String: [String]] = ["Action: ": ["Goal Changes Set"], "From: ": [fromType, from], "To: ": [toType, to], "at time:": [dateFormatter.stringFromDate(NSDate())]]
        writeToInteractionFile(dictToWrite)
    }
    func writeApplicationStatus(status: String){
        let dictToWrite: [String: [String]] = ["Action: ": [status], "at time:": [dateFormatter.stringFromDate(NSDate())]]
        writeToInteractionFile(dictToWrite)
    }
    
    func writeSession(session1: session){
        var dictToWrite = [String: AnyObject]()
        var daysJSON = [String: AnyObject]()
        var prevDaysJSON = [String: AnyObject]()
        var currentSessionInfoJSON = [String: AnyObject]()
        currentSessionInfoJSON["type"] = session1.state
        currentSessionInfoJSON["expected finish date"] = session1.endDate
        currentSessionInfoJSON["start date"] = session1.startDate
        currentSessionInfoJSON["expected pages per day"] = session1.expectedPagesPerDay
        
        //-------------- previous days
        for tempPrevDay in session1.previousDays{
            var prevPagesJSON = [String: AnyObject]()
            var actualPagesReadJSON = [String: AnyObject]()
            for tempPages in tempPrevDay.pages{
                actualPagesReadJSON["\(tempPages.pageNumber)"] = ["time": "\(glblLog.timeAtPageIndex[tempPages.pageNumber])"]
            }
            prevPagesJSON["actual"] = actualPagesReadJSON
            prevPagesJSON["expected"] = ["start": tempPrevDay.startPage, "end": tempPrevDay.endPage]
            prevDaysJSON[tempPrevDay.date] = prevDaysJSON
        }
        //----------------------- current session days
        for tempDay in session1.days{
            var pagesJSON = [String: AnyObject]()
            var actualPagesReadJSON = [String: AnyObject]()
            for tempPages in tempDay.pages{
                actualPagesReadJSON["\(tempPages.pageNumber)"] = ["time": "\(glblLog.timeAtPageIndex[tempPages.pageNumber])"]
            }
            pagesJSON["actual"] = actualPagesReadJSON
            pagesJSON["expected"] = ["start": tempDay.startPage, "end": tempDay.endPage]
            daysJSON[tempDay.date] = pagesJSON
        }
        dictToWrite["prev days"] = prevDaysJSON
        dictToWrite["days"] = daysJSON
        dictToWrite["session info"] = currentSessionInfoJSON
        writeToDataFile(dictToWrite)
    }
    func readDataFile() {
        // finding file
        if fileManager.fileExistsAtPath(dataJsonFilePath.absoluteString, isDirectory: &isDirectory) {
            print("Data File already exists")
            
            if let jsonData = NSData(contentsOfMappedFile: dataJsonFilePath.absoluteString) {
                //print("jsonData \(jsonData)")
                processDataFile(jsonData)
            }
            else{
                print("some error")
            }
            //NSData(contentsOfFile:dataJsonFilePath.absoluteString, options: nil, error: nil)
            
        } else {
            print("Data File doesn't exist")
        }
    }
    func processDataFile(jsonData: NSData){
        let dateFormatter1 = NSDateFormatter()
        dateFormatter1.dateStyle = NSDateFormatterStyle.ShortStyle
        //dateFormatter1.dateStyle = NSDateFormatterStyle.MediumStyle
        var session1 = session()
        var latestMaxDay = 0
        do {
            let jsonResult: NSDictionary = try NSJSONSerialization.JSONObjectWithData(jsonData, options: NSJSONReadingOptions.MutableContainers) as! NSDictionary
            print(jsonResult)
            
            if let seshInfo = jsonResult["session info"] as? [String: AnyObject] {
                var state = "pagesPerDayState"
                var finishDate = "1/1/17"
                var startDate = "1/1/16"
                var pagesPerDay = 10
                if let type = seshInfo["type"] as? String{
                    state = type
                }
                if let ppd = seshInfo["expected pages per day"] as? Int{
                    pagesPerDay = ppd
                }
                if let start = seshInfo["start date"] as? String{
                    startDate = start
                }
                if let finish = seshInfo["expected finish date"] as? String{
                    finishDate = finish
                }
                session1 = session(startDate: startDate, endDate: finishDate, expectedPagesPerDay: pagesPerDay, state: state, numberOfDaysPassed: 0)
            }
            if let days = jsonResult["days"] as? [String: AnyObject] {
                //print("days \(days)")
                for dayElement in session1.days{
                    for(date, stuff) in days{
                        if(dayElement.date == date){
                            print("dates: \(date)")
                            if let expected = stuff["expected"]{
                                //print("expected: \(expected!)")
                                var start = 0
                                var end = 0
                                if let startPage = expected!["start"] as? Int {
                                    start = startPage
                                    print("start: \(start)")
                                }
                                if let endPage = expected!["end"] as? Int {
                                    end = endPage
                                    print("end: \(end)")
                                }
                            }
                            
                            if let actual = stuff["actual"] as? [String: AnyObject]{
                                for(page1, time) in actual{
                                    print("page: \(page1)")
                                    if let time = time["time"]{
                                        print("time: \(time)")
                                        
                                        if let pageNumber = Int(page1)! as? Int{
                                            dayElement.pages.append(page(pageNumber: pageNumber, time: 0))
                                            if(latestMaxDay < pageNumber){
                                                latestMaxDay = pageNumber
                                            }
                                        }
                                    }
                                }
                            }
                            print("todays date: \(dateFormatter1.stringFromDate(NSDate())) and this date is \(date)")
                            if(dateFormatter1.dateFromString(date) != nil){
                                
                                let dateComparison = dateFormatter1.dateFromString(date)!.compare(NSDate()).rawValue
                                if(dateComparison<1){
                                    session1.setNextDayStartPage(latestMaxDay)
                                    session1.numberOfDaysPassed += 1
                                }
                            }
                        }
                        
                    }
                }
                
            }
            
            print(session1.toString())
        } catch {
            print("error in processDataFile")
        }
        
    }
    
}
var jsonLogger = json()