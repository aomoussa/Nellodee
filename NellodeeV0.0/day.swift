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
