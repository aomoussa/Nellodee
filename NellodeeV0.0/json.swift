//
//  json.swift
//  NellodeeV1.0
//
//  Created by ahmed moussa on 4/6/16.
//  Copyright © 2016 ahmed moussa. All rights reserved.
//

import Foundation

class json{
    let fileName = "test6"
    var documentsDirectoryPathString: String
    let documentsDirectoryPath: NSURL
    let jsonFilePath: NSURL
    
    let fileManager = NSFileManager.defaultManager()
    var isDirectory: ObjCBool = false
    
    let dateFormatter = NSDateFormatter()
    
    //let userInteractionContent =
    
    init(){
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
        dateFormatter.dateStyle = NSDateFormatterStyle.ShortStyle
        dateFormatter.timeStyle = NSDateFormatterStyle.ShortStyle
    }
    func writeToFile(what: [String: [String]]){
        // creating JSON out of the above array
        var jsonData: NSData!
        do {
            jsonData = try NSJSONSerialization.dataWithJSONObject(what, options: NSJSONWritingOptions())
            let jsonString = String(data: jsonData, encoding: NSUTF8StringEncoding)
            print(jsonString)
        } catch let error as NSError {
            print("Array to JSON conversion failed: \(error.localizedDescription)")
        }
        do {
            let file = try NSFileHandle(forWritingToURL: jsonFilePath)
            file.writeData(jsonData)
            print("JSON data was written to teh file successfully!")
        } catch let error as NSError {
            print("Couldn't write to file: \(error.localizedDescription)")
        }
    }
    /*
    func readFile(){
        if let jsonData = NSData(contentsOfFile: jsonFilePath, options: NSDataReadingOptions.DataReadingMappedIfSafe, error: nil)
        {
            if let jsonResult: NSDictionary = NSJSONSerialization.JSONObjectWithData(jsonData, options: NSJSONReadingOptions.MutableContainers, error: nil) as? NSDictionary
            {
                if let persons : NSArray = jsonResult["person"] as? NSArray
                {
                    // Do stuff
                }
            }
        }
    }*/
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
        let what: [String: [String]] = ["at time:": [dateFormatter.stringFromDate(NSDate())], "New Page Number": numbers, "\(direction) Button Clicked": [String]()]
        
        writeToFile(what)
        
    }
    func writeSegueOutOfReader(desitination: String){
        let dictToWrite: [String: [String]] = ["at time:": [dateFormatter.stringFromDate(NSDate())], "Segued Out Of Reader To \(desitination)": [String]()]
        
        writeToFile(dictToWrite)
        
    }
    func writeBurgerClicked(){
        let dictToWrite: [String: [String]] = ["at time:": [dateFormatter.stringFromDate(NSDate())], "Burger Clicked": [String]()]
        
        writeToFile(dictToWrite)
        
    }
    
}
var jsonLogger = json()