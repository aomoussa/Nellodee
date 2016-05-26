//
//  session.swift
//  NellodeeV0.0
//
//  Created by ahmed moussa on 12/3/15.
//  Copyright © 2015 ahmed moussa. All rights reserved.
//

import Foundation
class session{
    var previousDays = [day]()
    var days = [day]()
    var pageStart = 0
    var startDate: String
    var endDate: String
    var numberOfDaysPassed = 0
    var expectedPagesPerDay: Int
    var expectedNumOfDays: Int
    let dateFormatter = NSDateFormatter()
    var state = "pagesPerDayState"//"completionDateState"
    
    init(){
        self.startDate = ""
        self.endDate = ""
        self.expectedPagesPerDay = 0
        self.expectedNumOfDays = 0
        
    }
    init(startDate: String, endDate: String, expectedPagesPerDay: Int, state: String, pageStart: Int){// numOfPagesRem: Int){
        self.startDate = startDate
        self.endDate = endDate
        self.expectedPagesPerDay = expectedPagesPerDay
        self.state = state
        self.expectedNumOfDays = 0
        self.pageStart = pageStart
        dateFormatter.dateStyle = NSDateFormatterStyle.ShortStyle
        let unit:NSCalendarUnit = NSCalendarUnit.Day
        var finishDate = dateFormatter.dateFromString("1/1/2015")! as NSDate
        var beginDate = dateFormatter.dateFromString("1/1/2015")! as NSDate
        if(startDate != "" && endDate != ""){
            if(dateFormatter.dateFromString(endDate) != nil && dateFormatter.dateFromString(startDate) != nil){
                finishDate = dateFormatter.dateFromString(endDate)! as NSDate
                beginDate = dateFormatter.dateFromString(startDate)! as NSDate
            }
            let comps = NSCalendar.currentCalendar().components(unit, fromDate: beginDate, toDate: finishDate, options: [])
            self.expectedNumOfDays = comps.day
        }
        var i = 0
        var startPage = pageStart
        var endPage = startPage + expectedPagesPerDay
        while(i <= expectedNumOfDays)
        {
            days.append(day(expectedNumOfPages: expectedPagesPerDay, startPage: startPage, endPage: endPage))
            startPage+=expectedPagesPerDay
            endPage+=expectedPagesPerDay
            if (endPage >= glblLog.numberOfPages){
                endPage = glblLog.numberOfPages
            }
            if #available(iOS 8.0, *) {
                days[i].date = dateFormatter.stringFromDate(NSCalendar.currentCalendar().dateByAddingUnit(NSCalendarUnit.Day, value: i, toDate: beginDate, options: [])!)
            } else {
                print("device too old... session class mess up")
            }
            i++
        }
    }
    init(endDate: String, expectedPagesPerDay: Int, state: String){// numOfPagesRem: Int){
        dateFormatter.dateStyle = NSDateFormatterStyle.ShortStyle
        let unit:NSCalendarUnit = NSCalendarUnit.Day
        if(endDate != ""){
            var finishDate = dateFormatter.dateFromString("1/1/2015")! as NSDate
            if(dateFormatter.dateFromString(endDate) != nil){
                finishDate = dateFormatter.dateFromString(endDate)! as NSDate
            }
            let comps = NSCalendar.currentCalendar().components(unit, fromDate: NSDate(), toDate: finishDate, options: [])
                self.expectedNumOfDays = comps.day + 1
        }
        else{
            self.expectedNumOfDays = 0
        }
        self.pageStart = glblLog.currentSession.pageStart
        if(glblLog.currentSession.previousDays.count > 0){
            self.pageStart = glblLog.currentPageNumber
        }
        
        self.startDate = dateFormatter.stringFromDate(NSDate())
        self.endDate = endDate
        self.expectedPagesPerDay = expectedPagesPerDay
        self.state = state
        var i = 0
        var startPage = 0
        if(glblLog.currentPageNumber >= 0){
            if(glblLog.currentSession.days.count > glblLog.currentSession.numberOfDaysPassed){
            startPage = glblLog.currentPageNumber - glblLog.currentSession.days[glblLog.currentSession.numberOfDaysPassed].pages.count
            pageStart = startPage
            }
        }
        var endPage = startPage + expectedPagesPerDay
        while(i <= expectedNumOfDays)
        {
            days.append(day(expectedNumOfPages: expectedPagesPerDay, startPage: startPage, endPage: endPage))
            startPage+=expectedPagesPerDay
            endPage+=expectedPagesPerDay
            if (endPage >= glblLog.numberOfPages){
                endPage = glblLog.numberOfPages
            }
            if #available(iOS 8.0, *) {
                days[i].date = dateFormatter.stringFromDate(NSCalendar.currentCalendar().dateByAddingUnit(NSCalendarUnit.Day, value: i, toDate: NSDate(), options: [])!)
            } else {
                print("device too old... session class mess up")
            }
            i++
        }
    }
    func setNextDayStartPage(latestPageNumber: Int){
        if(numberOfDaysPassed+1 < self.days.count){
        self.days[numberOfDaysPassed+1].setStartPage(latestPageNumber)
        }
    }
    func indexOfDate(date: NSDate) -> Int{
        var i = 0
        while(i<days.count){
            if(days[i].date == dateFormatter.stringFromDate(date)){
                return i
            }
            i++
        }
        return 0
    }
    func toString() -> String{
        var str = ""
        var i = 0
        str += "The session starting page is this: \(pageStart) \n"
        str += "------------- CURRENT SESSION DAYS ------------- \n"
        for temp in days{
            str += "Day \(i) \(temp.date)"
            str += "\n ---- from pages \(temp.startPage) to \(temp.endPage)"
            for tempPage in days[i].pages{
                str += "\n ----- page #\(tempPage.pageNumber ) time: \(tempPage.time)secs"
            }
            str += "\n"
            i += 1
        }
        i = 0
        str += "------------- PREVIOUS SESSIONS DAYS ------------- \n"
        for temp2 in previousDays{
            str += "Day \(i) \(temp2.date)"
            str += "\n ---- from pages \(temp2.startPage) to \(temp2.endPage)"
            for tempPage in previousDays[i].pages{
                str += "\n ----- page #\(tempPage.pageNumber ) time: \(tempPage.time)secs"
            }
            str += "\n"
            i += 1
        }

        return str
    }
}