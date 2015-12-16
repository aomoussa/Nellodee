//
//  page.swift
//  NellodeeV0.0
//
//  Created by ahmed moussa on 12/3/15.
//  Copyright © 2015 ahmed moussa. All rights reserved.
//

import Foundation

class page{
    var pageNumber: Int
    var time: Int
    
    init(pageNumber: Int, time: Int){
        self.pageNumber = pageNumber
        self.time = time
    }
    func addTime(){
        time++
    }
}
