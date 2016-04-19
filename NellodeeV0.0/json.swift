//
//  json.swift
//  NellodeeV1.0
//
//  Created by ahmed moussa on 4/6/16.
//  Copyright © 2016 ahmed moussa. All rights reserved.
//

import Foundation

class json{
    var fileName = "test6"
    var documentsDirectoryPathString: String
    let documentsDirectoryPath: NSURL
    let jsonFilePath: NSURL
    
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
        
        fileName = "d\(day)m\(month)y\(year)"
        
        documentsDirectoryPathString = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true).first!
        documentsDirectoryPath = NSURL(string: documentsDirectoryPathString)!
        
        jsonFilePath = documentsDirectoryPath.URLByAppendingPathComponent("\(fileName).json")
        
        // creating a .json file in the Documents folder
        if !fileManager.fileExistsAtPath(jsonFilePath.absoluteString, isDirectory: &isDirectory) {
            let created = fileManager.createFileAtPath(jsonFilePath.absoluteString, contents: nil, attributes: nil)
            if created {
                print("File created ")
            } else {
                print("Couldn't create file for some reason")
            }
        } else {
            print("File already exists")
        }
    }
    func writeToFile(what: [String: [String]]){
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
            let file = try NSFileHandle(forWritingToURL: jsonFilePath)
            file.seekToEndOfFile()
            file.writeData(jsonData)
            print("JSON data was written to teh file successfully!")
        } catch let error as NSError {
            print("Couldn't write to file: \(error.localizedDescription)")
        }
    }
    
    func readFile() -> [String: [String]]{
        var jsonData = NSData()
        let dirs : [String] = NSSearchPathForDirectoriesInDomains(
            .DocumentDirectory,
            .UserDomainMask,
            true) as [String]
        
        if (dirs != [""]) {
            let directories: [String] = dirs
            let dir = directories[0]
            let path = dir.stringByAppendingString(fileName)
            do{
                try jsonData = NSData(contentsOfFile:path, options: NSDataReadingOptions.DataReadingMappedAlways)
                print("jsonData \(jsonData)") // This prints what looks to be JSON encoded data
            }
            catch{
                print("srsly tho idek know")
            }
        }
        
        

       // var json: Array!
        
        do{
            print("file exists: \(fileManager.fileExistsAtPath(jsonFilePath.absoluteString, isDirectory: &isDirectory))")
            jsonData = try NSData(contentsOfFile: jsonFilePath.absoluteString, options: NSDataReadingOptions.DataReadingMappedIfSafe)
            do {
                let json = try NSJSONSerialization.JSONObjectWithData(jsonData, options: NSJSONReadingOptions()) as! [String : AnyObject]
                if let interactionData = json[String(NSDate())] as? [String : AnyObject]{
                    if let pn = interactionData["New Page Number"] as? [String]! {
                        print("new page was \(pn[0])")
                    }
                }
                
                
            } catch {
                print(error)
            }
        }
        catch _ {
            print("idek know anymore")
        }
        return ["":[""]]
    }
    func writeTest(){
        
        // creating an array of test data
        
        var numbers = [String]()
        var numbers2 = [String]()
        for var i = 0; i < 3; i++ {
            numbers2.append("\(i*10)")
            numbers.append("\(i)")
        }
        var what: [String: [String]] = ["someList": numbers, "otherList": numbers2]
        
        writeToFile(what)
        
    }
    func writeChangedPage(newPageNumber: Int, direction: String){
        var numbers = [String]()
        numbers.append("\(newPageNumber)")
        let dictToWrite: [String: [String]] = ["at time:": [dateFormatter.stringFromDate(NSDate())], "New Page Number": numbers, "action: ": ["\(direction) Button Clicked"]]
        writeToFile(dictToWrite)
        
    }
    func writeSegueOutOfReader(desitination: String){
        let dictToWrite: [String: [String]] = ["\nat time:": [dateFormatter.stringFromDate(NSDate())], "action: ": ["Segued Out Of Reader To \(desitination)"]]
        writeToFile(dictToWrite)
        
    }
    func writeBurgerClicked(){
        let dictToWrite: [String: [String]] = ["at time:": [dateFormatter.stringFromDate(NSDate())], "Action: ": ["Burger Clicked"]]
        writeToFile(dictToWrite)
    }
    func writeGoalChangesSet(from: String, fromType: String, to: String, toType: String){
        let dictToWrite: [String: [String]] = ["From: ": [fromType, from], "To: ": [toType, to], "at time:": [dateFormatter.stringFromDate(NSDate())], "Action: ": ["Goal Changes Set"]]
        writeToFile(dictToWrite)
    }
    func writeApplicationStatus(status: String){
        let dictToWrite: [String: [String]] = ["at time:": [dateFormatter.stringFromDate(NSDate())], "Action: ": [status]]
        writeToFile(dictToWrite)
    }

}
var jsonLogger = json()