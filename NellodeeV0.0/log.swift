//
//  log.swift
//  NellodeeV0.0
//
//  Created by ahmed moussa on 11/14/15.
//  Copyright © 2015 ahmed moussa. All rights reserved.
//

import Foundation
class log{
    let defaults = NSUserDefaults.standardUserDefaults()
    var pageHeight = 841.8 as CGFloat
    var allSessions = [session]()
    var currentSession = session()
    var currentPageNumber = 1
    var numberOfPages = 0//total number of pages in book
    
    var maxPageReached = 1//last page you ever reached while reading the book, this is the number of bars in the trendView
    var scrollDestination = 0.0 as CGFloat
    
    var timeAtPageIndex = [Int]()

    var currentState = "pagesPerDayState"//"completionDateState"
    
    let dateFormatter = NSDateFormatter()

    
    init(){
        dateFormatter.dateStyle = NSDateFormatterStyle.ShortStyle
        
        if let CPN: Optional = self.defaults.integerForKey("currentPageNumber")
        {
            currentPageNumber = CPN! as Int!
            scrollDestination = CGFloat(currentPageNumber)*pageHeight
            maxPageReached = currentPageNumber
        }
        if let TAPI: Optional = self.defaults.stringArrayForKey("timeAtPageIndex")
        {
            //var i = 0
            if(TAPI != nil){
                for temp in TAPI!{
                    timeAtPageIndex.append(Int(temp)!)
                    //print(" time at page index saving: \(i++) \(Int(temp)!) existing array count: \(timeAtPageIndex.count)")
                }
            }
            
        }
        else{
            glblLog.timeAtPageIndex.append(0)
        }
        /*
        if let SD: Optional = self.defaults.stringForKey("startDate")
        {
            if(SD != nil){
            startDate = SD!
            }
        }
        else{
            startDate = dateFormatter.stringFromDate(NSDate())
        }
        
        if let ED: Optional = self.defaults.stringForKey("finishDate")
        {
            if(ED != nil){
                finishDate = ED!
            }
        }
        else{
            finishDate = "1/1/2016"
        }
        
        if let DR: Optional = self.defaults.stringArrayForKey("daysRead")
        {
            if(DR != nil){
                daysRead = DR!
            }
        }
        else{
            daysRead.append("1/1/2016")
        }
        if let EPPD: Optional = self.defaults.stringArrayForKey("expectedPagesPerDay1")
        {
            if(EPPD != nil){
            for temp in EPPD!{
                //print(Int(temp)!)
                expectedPagesPerDay1.append(Int(temp)!)
            }
            }
        }
        else{
            expectedPagesPerDay1.append(10)
        }
        
        
        
        var numberOfDaysRead = 0
        if let APPDC: Optional = self.defaults.integerForKey("actualPagesPerDay.count")
        {
            numberOfDaysRead = APPDC!
            //print(APPDC)
        }
        
        var i = 0
        while(i < numberOfDaysRead){
            actualPagesPerDay.append([Int]())
            if let APPD: Optional = self.defaults.stringArrayForKey("actualPagesPerDay\(i)")
            {
                //var j = 0
                if(APPD != nil){
                    for temp in APPD!{
                        actualPagesPerDay[i].append(Int(temp)!)
                        //print(" actualPagesPerDay saving: \(j++) \(Int(temp)!) existing array count: \(actualPagesPerDay[i].count)")
                    }
                }
                
            }
            else{
                actualPagesPerDay[i].append(0)
            }
            
            i++
        }

        //addSession(session(startDate: startDate, endDate: finishDate, expectedPagesPerDay: 0, state: "glblLog initiation"))
        i = 0
        while (i < currentSession.days.count){
            //currentSession.days[i].expectedPages = expectedPagesPerDay1[i]
            i++
        }*/
    }
    
    func addSession(sesh: session){
        currentSession = sesh
        allSessions.append(sesh)
    }
    func setBookNumOfPages(numOfPages: Int){
        numberOfPages = numOfPages
        var i = 0
        while(i < numOfPages){
            timeAtPageIndex.append(0)
            i++
        }
    }
}
let glblLog = log()