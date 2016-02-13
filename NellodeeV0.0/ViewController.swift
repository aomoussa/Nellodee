//
//  ViewController.swift
//  NellodeeV0.0
//
//  Created by ahmed moussa on 11/12/15.
//  Copyright © 2015 ahmed moussa. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UIWebViewDelegate, UIScrollViewDelegate {
    //local variables
    let defaults = NSUserDefaults.standardUserDefaults()
    var todaysDate = "12/30/15"
    var pageHeight = 0 as CGFloat
    var path = ""
    var url = NSURL()
    var pdfPageCount = 0
    var timeOnCurrentPage = 0
    var timer = NSTimer()
    var scrollDestinationUpdated = false
    
    //UI stuff
    let bottomView = UIView()
    let guyView = UIButton()
    let currentPageLabel = UILabel()
    let startPageLabel = UILabel()
    let endPageLabel = UILabel()
    let button1 = UIButton()
    let button2 = UIButton()
    let nextPageButton = UIButton()
    let prevPageButton = UIButton()
    
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
        self.url = NSURL.fileURLWithPath(path)
        self.webView.loadRequest(NSURLRequest(URL: url))
        self.webView.scalesPageToFit = true
        
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
        webView.scrollView.delegate = self
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
    func webViewDidFinishLoad(webView: UIWebView) {
        self.webView.userInteractionEnabled = true
    }
    func scrollViewDidScroll(scrollView: UIScrollView) {
        print("zoom scale rn \(scrollView.zoomScale)")
        if(scrollView.zoomScale < 1){
            self.webView.scrollView.zoomScale = 1
        }
        else if(scrollView.zoomScale == 1){
            if(scrollView.contentOffset.y > glblLog.scrollDestination || scrollView.contentOffset.y < glblLog.scrollDestination){
                self.webView.scrollView.setContentOffset(CGPointMake(0, glblLog.scrollDestination), animated: false)
            }
        }
        else{
            if(scrollView.contentOffset.y > (glblLog.scrollDestination + self.pageHeight)*scrollView.zoomScale  - self.pageHeight){
                self.webView.scrollView.setContentOffset(CGPointMake(scrollView.contentOffset.x, (glblLog.scrollDestination + self.pageHeight)*scrollView.zoomScale  - self.pageHeight), animated: false)
            }
            else if(scrollView.contentOffset.y < glblLog.scrollDestination * scrollView.zoomScale ){
                self.webView.scrollView.setContentOffset(CGPointMake(scrollView.contentOffset.x, glblLog.scrollDestination*scrollView.zoomScale), animated: false)
            }
            
        }
    }
    func buttonAction(sender: UIButton){
        self.webView.scrollView.zoomScale = 1.0
        if(sender == self.prevPageButton){
            glblLog.currentPageNumber--
            glblLog.scrollDestination = glblLog.scrollDestination - pageHeight
            webView.scrollView.setContentOffset(CGPointMake(0, glblLog.scrollDestination), animated: false)
            updateProgressBar()
        }
        if(sender == self.nextPageButton){
            if(glblLog.maxPageReached == glblLog.currentPageNumber && glblLog.currentSession.days.count > glblLog.currentSession.numberOfDaysPassed){
                glblLog.currentSession.days[glblLog.currentSession.numberOfDaysPassed].pages.append(page(pageNumber: glblLog.currentPageNumber+1, time: 0))
            }
            
            
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
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        let screenWidth = view.frame.size.width
        let screenHeight = self.view.frame.size.height
        
        bottomView.backgroundColor = UIColor.grayColor()
        self.view.addSubview(bottomView)
        
        let buttonsHeight = screenHeight*0.1
        let buttonsWidth = screenWidth*0.1
        
        self.prevPageButton.frame = CGRectMake(0, screenHeight - buttonsHeight, buttonsWidth, buttonsWidth)
        prevPageButton.backgroundColor = UIColor.blueColor()
        prevPageButton.setTitle("prev", forState: UIControlState.Normal)
        prevPageButton.addTarget(self, action: "buttonAction:", forControlEvents: UIControlEvents.TouchUpInside)
        
        self.nextPageButton.frame = CGRectMake(screenWidth - buttonsWidth, screenHeight - buttonsHeight, buttonsWidth, buttonsWidth)
        nextPageButton.backgroundColor = UIColor.blueColor()
        nextPageButton.setTitle("next", forState: UIControlState.Normal)
        nextPageButton.addTarget(self, action: "buttonAction:", forControlEvents: UIControlEvents.TouchUpInside)
        
        
        self.view.addSubview(nextPageButton)
        self.view.addSubview(prevPageButton)
        self.view.addSubview(button1)
        self.view.addSubview(button2)
        self.view.addSubview(guyView)
        let imageD = 50.0 as CGFloat
        
        guyView.frame = CGRectMake(100 + imageD/2, screenHeight - 2*imageD, imageD, imageD)
        updateProgressBar()
        
        let labelWidth = screenWidth/15
        let labelHeight = screenHeight/30
        
        startPageLabel.frame = CGRectMake(100, screenHeight - 1.5*labelHeight, labelWidth, labelHeight )
        self.view.addSubview(startPageLabel)
        
        endPageLabel.frame = CGRectMake(screenWidth - labelWidth/2 - 100, screenHeight - 1.5*labelHeight, labelWidth, labelHeight)
        self.view.addSubview(endPageLabel)
        
        //currentPageLabel.frame = CGRectMake(100 +  labelWidth/2, screenHeight - labelHeight - (2 * screenHeight/25), labelWidth, labelHeight )
        currentPageLabel.text = "\(glblLog.currentPageNumber)"
        self.view.addSubview(currentPageLabel)
        
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
            //--------- ----------- zoom stuff trials
            //webView.scrollView.maximumZoomScale
            //--------- ----------- zoom stuff trials
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
        let screenWidth = self.view.frame.width
        let screenHeight = self.view.frame.height
        
        if(!scrollDestinationUpdated){
            if(self.webView.scrollView.contentSize.height > 0){
                self.pageHeight = self.webView.scrollView.contentSize.height / CGFloat(glblLog.numberOfPages)
            }
            else{
                self.pageHeight = 0
            }
            if(self.pageHeight > screenHeight*0.6){
                glblLog.scrollDestination = CGFloat(glblLog.currentPageNumber)*pageHeight
                webView.scrollView.setContentOffset(CGPointMake(0, glblLog.scrollDestination), animated: false)
                webView.frame = CGRectMake(0, webView.frame.minY, screenWidth, self.pageHeight )
                bottomView.frame =  CGRectMake(0, webView.frame.maxY, screenWidth, screenHeight -  webView.frame.maxY)
                scrollDestinationUpdated = true
            }
            
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
            //retrieveAllSessions()
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
            while(j <= currentSessionNumberOfDaysPassed){
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
                    if(i <= currentSessionNumberOfDaysPassed){
                        for tempPages in actualPagesPerDay[i]{
                            temp.pages.append(page(pageNumber: tempPages, time: 0))
                        }
                    }
                    i++
                }
            }
            retrievePreviousDays()
            
        }
    }
    func retrievePreviousDays(){
        var previousDaysStartPagesString = [Int]()
        var previousDaysEndPagesString = [Int]()
        var previousDaysTimeOnDay = [Int]()
        var previousDaysPagesReadAtIndexDay = [[Int]]()
        var previousDaysCount = 0
        //------------------------------------------------------------------> previousDaysCount retrieval
        if let ND: Optional = self.defaults.integerForKey("previousDaysCount")
        {
            if(ND != 0){
                previousDaysCount = ND!
            }
        }
        
        //------------------------------------------------------------------> timePerDay retrieval
        if let TPD: Optional = self.defaults.stringArrayForKey("previousDaysTimeOnDay")
        {
            if(TPD != nil){
                for temp in TPD!{
                    previousDaysTimeOnDay.append(Int(temp)!)
                }
            }
        }
        else{
            previousDaysTimeOnDay.append(0)
        }
        
        //------------------------------------------------------------------> startDaysStringArray retrieval
        if let SP: Optional = self.defaults.stringArrayForKey("previousDaysStartPagesString")
        {
            if(SP != nil){
                for temp in SP!{
                    previousDaysStartPagesString.append(Int(temp)!)
                }
            }
        }
        else{
            previousDaysStartPagesString.append(0)
        }
        
        //------------------------------------------------------------------> endPagesStringArray retrieval
        if let EP: Optional = self.defaults.stringArrayForKey("previousDaysEndPagesString")
        {
            if(EP != nil){
                for temp in EP!{
                    previousDaysEndPagesString.append(Int(temp)!)
                }
            }
        }
        else{
            previousDaysEndPagesString.append(0)
        }
        
        //------------------------------------------------------------------> actualPagesPerDay retrieval
        var j = 0
        while(j <= previousDaysCount){
            previousDaysPagesReadAtIndexDay.append([Int]())
            if let APPD: Optional = self.defaults.stringArrayForKey("PreviousDaysActualPagesPerDay\(j)")
            {
                if(APPD != nil){
                    for temp in APPD!{
                        previousDaysPagesReadAtIndexDay[j].append(Int(temp)!)
                    }
                }
            }
            j++
        }
        
        //------------------------------------------------------------------> setting the previous days Data
        var i = 0
        while(i < previousDaysCount){
            let temp = day(expectedNumOfPages: (previousDaysEndPagesString[i] - previousDaysStartPagesString[i]), startPage: previousDaysStartPagesString[i], endPage: previousDaysEndPagesString[i])
            temp.time = previousDaysTimeOnDay[i]
            if(i <= previousDaysCount){
                for tempPages in previousDaysPagesReadAtIndexDay[i]{
                    temp.pages.append(page(pageNumber: tempPages, time: 0))
                }
            }
            glblLog.currentSession.previousDays.append(temp)
            i++
        }
        i = previousDaysCount - 1
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateStyle = NSDateFormatterStyle.ShortStyle
        while(i>0){
            if #available(iOS 8.0, *) {
                glblLog.currentSession.previousDays[i].date = dateFormatter.stringFromDate(NSCalendar.currentCalendar().dateByAddingUnit(NSCalendarUnit.Day, value: i, toDate: NSDate(), options: [])!)
            } else {
                // Fallback on earlier versions
            }
            i--
        }
        //days[i].date = dateFormatter.stringFromDate(NSCalendar.currentCalendar().dateByAddingUnit(NSCalendarUnit.Day, value: i, toDate: NSDate(), options: [])!)
    }
    /*
    func retrieveAllSessions(){
    //------------------------------------------------------------------> currentSessionNumberOfDaysPassed retrieval
    if let numberOfSessions: Optional = self.defaults.integerForKey("numberOfSessions")
    {
    if(numberOfSessions == 0){
    print("something's gone terribly wrong")
    }
    //------------------------------------------------------------------> currentSession initiation
    var tmpSession = session()
    var i = 0
    while(i < numberOfSessions! - 1){
    var startDate = ""
    var endDate = ""
    var selectorState = ""
    var numberOfDaysPassed = 0
    var expectedPagesPerDay = 10
    var timePerDay = [Int]()
    var startPages = [Int]()
    var endPages = [Int]()
    var actualPagesPerDay = [[Int]]()
    //-------------------------------------------------------------------> startDate retrieval
    if let SD: Optional = self.defaults.stringForKey("startDateSession\(i)")
    {
    if(SD != nil){
    startDate = SD!
    }
    }
    else{
    startDate = "1/1/2016"
    }
    //------------------------------------------------------------------> endDate retrieval
    if let ED: Optional = self.defaults.stringForKey("endDateSession\(i)")
    {
    if(ED != nil){
    endDate = ED!
    }
    }
    else{
    endDate = "1/1/2016"
    }
    tmpSession.endDate = endDate
    //------------------------------------------------------------------> currentSessionSelectorState retrieval
    if let SS: Optional = self.defaults.stringForKey("selectorStateSession\(i)")
    {
    if(SS != nil){
    selectorState = SS!
    }
    }
    else{
    selectorState = "pagesPerDay"
    }
    tmpSession.state = selectorState
    //------------------------------------------------------------------> currentSessionSelectorState retrieval
    if let EPPD: Optional = self.defaults.integerForKey("expectedPagesPerDaySession\(i)")
    {
    if(EPPD != nil && EPPD! > 0){
    expectedPagesPerDay = EPPD!
    }
    }
    
    
    //------------------------------------------------------------------> currentSessionNumberOfDaysPassed retrieval
    if let ND: Optional = self.defaults.integerForKey("numberOfDaysPassedSession\(i)")
    {
    if(ND != 0){
    numberOfDaysPassed = ND!
    }
    }
    
    
    //------------------------------------------------------------------> timePerDay retrieval
    if let TPD: Optional = self.defaults.stringArrayForKey("timePerDaySession\(i)")
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
    if let SP: Optional = self.defaults.stringArrayForKey("startPagesStringArraySession\(i)")
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
    if let EP: Optional = self.defaults.stringArrayForKey("endPagesStringArraySession\(i)")
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
    while(j <= numberOfDaysPassed){
    actualPagesPerDay.append([Int]())
    if let APPD: Optional = self.defaults.stringArrayForKey("actualPagesPerDay\(j)onSession\(i)")
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
    if(timePerDay.count == tmpSession.days.count){
    tmpSession.numberOfDaysPassed = numberOfDaysPassed
    
    var i = 0
    for temp in tmpSession.days{
    temp.startPage = startPages[i]
    temp.endPage = endPages[i]
    temp.expectedPages = temp.endPage - temp.startPage
    temp.time = timePerDay[i]
    if(i <= numberOfDaysPassed){
    for tempPages in actualPagesPerDay[i]{
    temp.pages.append(page(pageNumber: tempPages, time: 0))
    }
    }
    i++
    }
    }
    i++
    }
    }
    }*/
}

