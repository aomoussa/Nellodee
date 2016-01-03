//
//  ViewController.swift
//  NellodeeV0.0
//
//  Created by ahmed moussa on 11/12/15.
//  Copyright © 2015 ahmed moussa. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UIWebViewDelegate {
    //local variables
    let defaults = NSUserDefaults.standardUserDefaults()
    var todaysDate = "12/30/15"
    var pageHeight = 841.8 as CGFloat
    var path = ""
    var pdfPageCount = 0
    var timeOnCurrentPage = 0
    var timer = NSTimer()
    var scrollDestinationUpdated = false
    
    //UI stuff
    let guyView = UIButton()
    let currentPageLabel = UILabel()
    let startPageLabel = UILabel()
    let endPageLabel = UILabel()
    let button1 = UIButton()
    let button2 = UIButton()
    
    //from storyboard
    @IBOutlet var webView: UIWebView!
    @IBAction func nextDay(sender: UIButton) {
        glblLog.currentSession.setNextDayStartPage()
        
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateStyle = NSDateFormatterStyle.ShortStyle
        let startDate = dateFormatter.stringFromDate(NSDate())
        todaysDate = startDate
        let unit:NSCalendarUnit = NSCalendarUnit.Day
        if #available(iOS 8.0, *) {
            todaysDate = dateFormatter.stringFromDate(NSCalendar.currentCalendar().dateByAddingUnit(unit, value: glblLog.currentSession.numberOfDaysPassed++, toDate: NSDate(), options: [])!)
        } else {
            print("device too old... datePicker mess up")
        }
        
        updateProgressBar()
    }
    @IBOutlet var burger: UIBarButtonItem!
    @IBOutlet var paceLabel: UILabel!
    @IBOutlet var timerLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.path = NSBundle.mainBundle().pathForResource("pdfBook", ofType: "pdf")!
        let url = NSURL.fileURLWithPath(path)
        self.webView.loadRequest(NSURLRequest(URL: url))
        
        let pdf = CGPDFDocumentCreateWithURL(url)
        pdfPageCount = CGPDFDocumentGetNumberOfPages(pdf)
        
        if(glblLog.numberOfPages != pdfPageCount){
            if(glblLog.timeAtPageIndex.count <= 1){
                glblLog.setBookNumOfPages(pdfPageCount)
            }
            else{
                glblLog.numberOfPages = pdfPageCount
            }
        }
        webView.delegate = self
        
        timer = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: "runTimedCode", userInfo: nil, repeats: true)
        
        burger.target = self.revealViewController()
        burger.action = Selector("revealToggle:")
        
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateStyle = NSDateFormatterStyle.ShortStyle
        todaysDate = dateFormatter.stringFromDate(NSDate())
        let unit:NSCalendarUnit = NSCalendarUnit.Day
        if #available(iOS 8.0, *) {
            todaysDate = dateFormatter.stringFromDate(NSCalendar.currentCalendar().dateByAddingUnit(unit, value: glblLog.currentSession.numberOfDaysPassed, toDate: NSDate(), options: [])!)
        } else {
            print("device too old... datePicker mess up")
        }
        var currentSessionLastDateReached = todaysDate
        if(glblLog.currentSession.days.count > 0)
        {
            currentSessionLastDateReached = glblLog.currentSession.days[glblLog.currentSession.numberOfDaysPassed].date
        }
        if(currentSessionLastDateReached != todaysDate){
            glblLog.currentSession.setNextDayStartPage()
            glblLog.currentSession.numberOfDaysPassed++
            print("numberOfDaysPassed added todays date: \(todaysDate) and session.days[numberOfDaysPassed - 1] = \(glblLog.currentSession.days[glblLog.currentSession.numberOfDaysPassed - 1].date)")
        }
        else{
            print("numberOfDaysPassed \n added todays date: \(todaysDate) ")
        }
        retrieveSavedData()
    }
    @IBAction func nextPageButton(sender: UIButton) {
        glblLog.currentSession.days[glblLog.currentSession.numberOfDaysPassed].pages.append(page(pageNumber: glblLog.currentPageNumber+1, time: 0))
        if(glblLog.currentPageNumber < glblLog.numberOfPages){
            if(glblLog.currentPageNumber == glblLog.maxPageReached){
                glblLog.maxPageReached++
            }
            glblLog.currentPageNumber++
            
            glblLog.scrollDestination = pageHeight + glblLog.scrollDestination
            webView.scrollView.setContentOffset(CGPointMake(0, glblLog.scrollDestination), animated: false)
            updateProgressBar()
        }
    }
    @IBAction func prevPageButton(sender: UIButton) {
        glblLog.currentPageNumber--
        glblLog.scrollDestination = glblLog.scrollDestination - pageHeight
        webView.scrollView.setContentOffset(CGPointMake(0, glblLog.scrollDestination), animated: false)
        updateProgressBar()
    }
    
    func runTimedCode() {
        if(!scrollDestinationUpdated){
            webView.scrollView.setContentOffset(CGPointMake(0, glblLog.scrollDestination), animated: false)
        }
        if(glblLog.currentSession.days.count > 0){
            glblLog.currentSession.days[glblLog.currentSession.numberOfDaysPassed].time++
        }
        
        timeOnCurrentPage = glblLog.timeAtPageIndex[glblLog.currentPageNumber]
        timerLabel.text = "\(timeOnCurrentPage)"
        
        if(timeOnCurrentPage == 0){
            guyView.setBackgroundImage(UIImage(named: "a.jpg"), forState: UIControlState.Normal)
        }
        else if(timeOnCurrentPage == 5){
            guyView.setBackgroundImage(UIImage(named: "b.jpg"), forState: UIControlState.Normal)
        }
        else if(timeOnCurrentPage == 10){
            guyView.setBackgroundImage(UIImage(named: "a.jpg"), forState: UIControlState.Normal)
        }
        
        if(timeOnCurrentPage < 5){
            paceLabel.text = "fast"
        }
        else if(timeOnCurrentPage < 10){
            paceLabel.text = "arright"
        }
        else {
            paceLabel.text = "sloww"
        }
        glblLog.timeAtPageIndex[glblLog.currentPageNumber]++
    }
    
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        let screenWidth = view.frame.size.width
        let screenHeight = self.view.frame.size.height
        webView.scrollView.setContentOffset(CGPointMake(0, glblLog.scrollDestination), animated: false)
        webView.frame = CGRectMake(0, webView.frame.minY, screenWidth, pageHeight )
        
        self.view.addSubview(button1)
        self.view.addSubview(button2)
        self.view.addSubview(guyView)
        updateProgressBar()
        
        let labelWidth = screenWidth/15
        let labelHeight = screenHeight/30
        
        startPageLabel.frame = CGRectMake(100, screenHeight - 1.5*labelHeight, labelWidth, labelHeight )
        self.view.addSubview(startPageLabel)
        
        endPageLabel.frame = CGRectMake(screenWidth - labelWidth/2 - 100, screenHeight - 1.5*labelHeight, labelWidth, labelHeight)
        self.view.addSubview(endPageLabel)
        
        currentPageLabel.frame = CGRectMake(100 +  labelWidth/2, screenHeight - labelHeight - (2 * screenHeight/25), labelWidth, labelHeight )
        currentPageLabel.text = "\(glblLog.currentPageNumber)"
        self.view.addSubview(currentPageLabel)
        
    }
    func updateProgressBar(){
        let screenWidth = view.frame.size.width
        let screenHeight = self.view.frame.size.height
        let progressBarWidth = screenWidth - 200 as CGFloat
        var progress = 0.0 as CGFloat
        if(glblLog.currentSession.days.count > 0 ){
            progress = CGFloat(glblLog.currentPageNumber - glblLog.currentSession.days[glblLog.currentSession.numberOfDaysPassed].startPage)/CGFloat(glblLog.currentSession.days[glblLog.currentSession.numberOfDaysPassed].expectedPages) * progressBarWidth
        }
        if(progress > progressBarWidth){
            progress = progressBarWidth
        }
        if(progress < 0){
            progress = 0
        }
        
        let button1Width = progress
        let button2Width = progressBarWidth - progress
        let buttonHeight = screenHeight/25 as CGFloat
        let imageWidth = screenWidth/22
        
        button1.frame = CGRectMake(100, screenHeight - 2*buttonHeight, button1Width, buttonHeight)
        button1.backgroundColor = UIColor.greenColor()
        
        button2.frame = CGRectMake(100 + progress , screenHeight - 2*buttonHeight, button2Width, buttonHeight )
        button2.backgroundColor = UIColor.redColor()
        
        let labelWidth = screenWidth/15
        let labelHeight = screenHeight/30
        
        if(glblLog.currentSession.days.count > 0){
            startPageLabel.text = "\(glblLog.currentSession.days[glblLog.currentSession.numberOfDaysPassed].startPage)"
            endPageLabel.text = "\(glblLog.currentSession.days[glblLog.currentSession.numberOfDaysPassed].endPage)"//"\(glblLog.startPage + glblLog.expectedPagesPerDay)"
        }
        currentPageLabel.frame = CGRectMake(100 + progress - 5, screenHeight - labelHeight - 2*buttonHeight, labelWidth, labelHeight )
        currentPageLabel.text = "\(glblLog.currentPageNumber)"
        
        guyView.frame = CGRectMake(100 + progress - imageWidth/2, screenHeight - 2*buttonHeight, imageWidth, buttonHeight)
        
    }
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        timer.invalidate()
    }
    func retrieveSavedData(){
        if(glblLog.allSessions.count < 1){
            var startDate = ""
            var endDate = ""
            var currentSessionSelectorState = ""
            var currentSessionNumberOfDaysPassed = 0
            var currentSessionExpectedPagesPerDay = 10
            var timePerDay = [Int]()
            var startPages = [Int]()
            var endPages = [Int]()
            var actualPagesPerDay = [[Int]]()
            //-------------------------------------------------------------------> startDate retrieval
            if let SD: Optional = self.defaults.stringForKey("currentSessionStartDate")
            {
                if(SD != nil){
                    startDate = SD!
                }
            }
            else{
                startDate = "1/1/2016"
            }
            //------------------------------------------------------------------> endDate retrieval
            if let ED: Optional = self.defaults.stringForKey("currentSessionEndDate")
            {
                if(ED != nil){
                    endDate = ED!
                }
            }
            else{
                endDate = "1/1/2016"
            }
            //------------------------------------------------------------------> currentSessionSelectorState retrieval
            if let SS: Optional = self.defaults.stringForKey("currentSessionSelectorState")
            {
                if(SS != nil){
                    currentSessionSelectorState = SS!
                }
            }
            else{
                currentSessionSelectorState = "pagesPerDay"
            }
            //------------------------------------------------------------------> currentSessionSelectorState retrieval
            if let EPPD: Optional = self.defaults.integerForKey("currentSessionExpectedPagesPerDay")
            {
                if(EPPD != nil && EPPD! > 0){
                    currentSessionExpectedPagesPerDay = EPPD!
                }
            }
            
            //------------------------------------------------------------------> currentSession initiation
            glblLog.addSession(session(startDate: startDate, endDate: endDate, expectedPagesPerDay: currentSessionExpectedPagesPerDay, state: currentSessionSelectorState))
            print(glblLog.currentSession.toString())
            //------------------------------------------------------------------> currentSessionNumberOfDaysPassed retrieval
            if let ND: Optional = self.defaults.integerForKey("currentSessionNumberOfDaysPassed")
            {
                if(ND != 0){
                    currentSessionNumberOfDaysPassed = ND!
                }
            }
            
            
            //------------------------------------------------------------------> timePerDay retrieval
            if let TPD: Optional = self.defaults.stringArrayForKey("timePerDay")
            {
                if(TPD != nil){
                    for temp in TPD!{
                        timePerDay.append(Int(temp)!)
                    }
                }
            }
            else{
                timePerDay.append(0)
            }
            
            //------------------------------------------------------------------> startDaysStringArray retrieval
            if let SP: Optional = self.defaults.stringArrayForKey("startPagesStringArray")
            {
                if(SP != nil){
                    for temp in SP!{
                        startPages.append(Int(temp)!)
                    }
                }
            }
            else{
                startPages.append(0)
            }
            
            //------------------------------------------------------------------> endPagesStringArray retrieval
            if let EP: Optional = self.defaults.stringArrayForKey("endPagesStringArray")
            {
                if(EP != nil){
                    for temp in EP!{
                        endPages.append(Int(temp)!)
                    }
                }
            }
            else{
                endPages.append(0)
            }
            
            //------------------------------------------------------------------> actualPagesPerDay retrieval
            var j = 0
            while(j < currentSessionNumberOfDaysPassed){
                actualPagesPerDay.append([Int]())
                if let APPD: Optional = self.defaults.stringArrayForKey("actualPagesPerDay\(j)")
                {
                    if(APPD != nil){
                        for temp in APPD!{
                            actualPagesPerDay[j].append(Int(temp)!)
                        }
                    }
                }
                j++
            }
            
            //------------------------------------------------------------------> setting the current Session Data
            if(timePerDay.count == glblLog.currentSession.days.count){
                glblLog.currentSession.numberOfDaysPassed = currentSessionNumberOfDaysPassed
                
                var i = 0
                for temp in glblLog.currentSession.days{
                    temp.startPage = startPages[i]
                    temp.endPage = endPages[i]
                    temp.expectedPages = temp.endPage - temp.startPage
                    temp.time = timePerDay[i]
                    if(i < currentSessionNumberOfDaysPassed){
                        for tempPages in actualPagesPerDay[i]{
                            temp.pages.append(page(pageNumber: tempPages, time: 0))
                        }
                    }
                    i++
                }
            }
        }
    }
}

