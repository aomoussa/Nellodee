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
    init(startDate: String, endDate: String, expectedPagesPerDay: Int, state: String){// numOfPagesRem: Int){
        dateFormatter.dateStyle = NSDateFormatterStyle.ShortStyle
        let unit:NSCalendarUnit = NSCalendarUnit.Day
        if(startDate != "" && endDate != ""){
            var finishDate = dateFormatter.dateFromString("1/1/2015")! as NSDate
            if(dateFormatter.dateFromString(endDate) != nil){
                finishDate = dateFormatter.dateFromString(endDate)! as NSDate
            }
            let comps = NSCalendar.currentCalendar().components(unit, fromDate: NSDate(), toDate: finishDate, options: [])
                self.expectedNumOfDays = comps.day
        }
        else{
            self.expectedNumOfDays = 0
        }
        self.startDate = startDate
        self.endDate = endDate
        self.expectedPagesPerDay = expectedPagesPerDay
        self.state = state
        var i = 0
        var startPage = 0
        if(glblLog.currentPageNumber >= 0){
            if(glblLog.currentSession.days.count > 0){
            startPage = glblLog.currentPageNumber - glblLog.currentSession.days[glblLog.currentSession.numberOfDaysPassed].pages.count
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
    func setNextDayStartPage(){
        if(numberOfDaysPassed+1 < self.days.count){
        self.days[numberOfDaysPassed+1].setStartPage(glblLog.currentPageNumber)
        }
    }
    func toString() -> String{
        var str = ""
        var i = 0
        for temp in days{
            str += "Day \(i) \(temp.date)"
            str += "\n ---- from pages \(temp.startPage) to \(temp.endPage)"
            for tempPage in days[i].pages{
                str += "\n ----- page #\(tempPage.pageNumber ) time: \(tempPage.time)secs"
            }
            str += "\n"
            i++
        }
        return str
    }
}