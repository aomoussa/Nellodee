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
    var pageHeight = 0 as CGFloat
    var currentSession = session()
    var currentPageNumber = 1
    var numberOfPages = 0//total number of pages in book
    
    var maxPageReached = 1//last page you ever reached while reading the book, this is the number of bars in the trendView
    var scrollDestination = 0.0 as CGFloat
    
    var timeAtPageIndex = [Int]()
    
    let dateFormatter = NSDateFormatter()
    
    
    init(){
        dateFormatter.dateStyle = NSDateFormatterStyle.ShortStyle
        
        if let CPN: Optional = self.defaults.integerForKey("currentPageNumber")
        {
            currentPageNumber = CPN! as Int!
            maxPageReached = currentPageNumber
        }
        if let TAPI: Optional = self.defaults.stringArrayForKey("timeAtPageIndex")
        {
            if(TAPI != nil){
                for temp in TAPI!{
                    timeAtPageIndex.append(Int(temp)!)
                }
            }
        }
        else{
            glblLog.timeAtPageIndex.append(0)
        }
    }
    
    func addSession(sesh: session){
        if(true){
            var i = currentSession.days.count - 1
            while(i >= 0){
                if(currentSession.days[i].pages.count < 1){
                    currentSession.days.removeAtIndex(i)
                }
                else{
                    sesh.days[0].pages = currentSession.days[i].pages
                    currentSession.days.removeAtIndex(i)
                    break
                }
                i -= 1
            }
            sesh.previousDays = currentSession.previousDays
            for tempDay in currentSession.days{
                sesh.previousDays.append(tempDay)
            }
        }
        currentSession = sesh
    }
    func setBookNumOfPages(numOfPages: Int){
        numberOfPages = numOfPages
        var i = 0
        while(i < numOfPages){
            timeAtPageIndex.append(0)
            i += 1
        }
    }
}
let glblLog = log()