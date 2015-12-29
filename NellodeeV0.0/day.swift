//
//  day.swift
//  NellodeeV0.0
//
//  Created by ahmed moussa on 12/3/15.
//  Copyright © 2015 ahmed moussa. All rights reserved.
//

import Foundation
class day{
    //local variables
    var date: String
    var pages = [page]()
    var startPage: Int
    var endPage: Int
    var time = 0
    var expectedPages: Int
    let dateFormatter = NSDateFormatter()
    
    
    init(d: String, expectedNumOfPages: Int, startPage: Int, endPage: Int){
        dateFormatter.dateStyle = NSDateFormatterStyle.ShortStyle
        date = d
        self.startPage = startPage
        self.endPage = endPage
        self.expectedPages = endPage - startPage
    }
    init(expectedNumOfPages: Int, startPage: Int, endPage: Int){
        dateFormatter.dateStyle = NSDateFormatterStyle.ShortStyle
        date = dateFormatter.stringFromDate(NSDate())
        self.startPage = startPage
        self.endPage = endPage
        
        self.expectedPages = endPage - startPage
    }
    func setStartPage(startPage: Int){
        if(startPage < self.startPage){
            self.startPage = startPage
            self.expectedPages = endPage - startPage
        }
        else{
            let extraPagesRead = glblLog.currentPageNumber - self.startPage
            self.startPage = startPage
            self.endPage = self.startPage + self.expectedPages
            /*var i = 0
            var startPage = 0
            if(glblLog.currentPageNumber >= 0){
            startPage = glblLog.currentPageNumber
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
            }*/
            var i = glblLog.currentSession.numberOfDaysPassed + 1
            while(i<glblLog.currentSession.days.count){
                glblLog.currentSession.days[i].startPage += extraPagesRead
                glblLog.currentSession.days[i].endPage += extraPagesRead
                i++
            }
        }
    }
    func addPage(pg: page) -> Bool{
        for temp in pages{
            if(pg.pageNumber == temp.pageNumber){
                return false
            }
        }
        pages.append(pg)
        return true
        
    }
    func addPage(pageNumber: Int, timeOnPage: Int) -> Bool{
        for temp in pages{
            if(pageNumber == temp.pageNumber){
                return false
            }
        }
        pages.append(page(pageNumber: pageNumber, time: timeOnPage))
        return true
    }
    func getPageIndex(pageNumber: Int) -> Int{
        var i = 0
        for temp in pages{
            if(temp.pageNumber == pageNumber){
                return i
            }
            i++
        }
        return -1
    }
}
