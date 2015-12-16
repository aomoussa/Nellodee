//
//  day.swift
//  NellodeeV0.0
//
//  Created by ahmed moussa on 12/3/15.
//  Copyright © 2015 ahmed moussa. All rights reserved.
//

import Foundation
class day{
    var date: String
    var pages = [page]()
    var expectedPages: Int
    let dateFormatter = NSDateFormatter()
    init(d: String, expectedNumOfPages: Int){
        dateFormatter.dateStyle = NSDateFormatterStyle.ShortStyle
        date = d
        
        self.expectedPages = expectedNumOfPages
    }
    init(expectedNumOfPages: Int){
        dateFormatter.dateStyle = NSDateFormatterStyle.ShortStyle
        date = dateFormatter.stringFromDate(NSDate())
        
        self.expectedPages = expectedNumOfPages
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
    func addTime(){
        if(pages.count != 0){
            pages[pages.count-1].addTime()
        }
    }
}
