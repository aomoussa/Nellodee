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
    var diff = 0 as CGFloat// difference in pixels between the bottom of the webview and the start of the progress (bottomView)
    var filler = UIView() // actual view that covers up the difference between the bottom of the webview and the start of the progress (bottomView)
    
    //colors
    let NellodeeMaroonColor = UIColor(red: 102/255, green: 51/255, blue: 51/255, alpha: 1)
    let NellodeeBottomBarGray = UIColor(red: 204/255, green: 204/255, blue: 204/255, alpha: 1)
    
    //from storyboard
    @IBOutlet var webView: UIWebView!
    /*
    @IBAction func nextDay(sender: UIButton) {
        if(glblLog.currentSession.numberOfDaysPassed < glblLog.currentSession.days.count-1){
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
        
    }
*/
    @IBOutlet var burger: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        jsonLogger.writeTest()
        
        webView.delegate = self
        webView.scrollView.delegate = self
        
        self.path = NSBundle.mainBundle().pathForResource("Frankenstein", ofType: "pdf")! //pdfBook2//Frankenstein//circuitsBook//cooperPDF
        self.url = NSURL.fileURLWithPath(path)
        self.webView.loadRequest(NSURLRequest(URL: url))
        self.webView.scrollView.maximumZoomScale = 5
        self.webView.scrollView.minimumZoomScale = 0.5
        self.webView.scrollView.userInteractionEnabled = true
        self.webView.scrollView.scrollEnabled = false
        self.webView.scalesPageToFit = true
        self.webView.contentMode = UIViewContentMode.ScaleAspectFit
        //self..webView.
        
        let pdf = CGPDFDocumentCreateWithURL(url)
        pdfPageCount = CGPDFDocumentGetNumberOfPages(pdf)
        
        
        let pdfName = CGPDFDictionaryGetString(CGPDFDocumentGetInfo(pdf), "Title", UnsafeMutablePointer.init())
        print("pdf name: ", pdfName)
        
        if(glblLog.numberOfPages != pdfPageCount){
            if(glblLog.timeAtPageIndex.count <= 1){
                glblLog.setBookNumOfPages(pdfPageCount)
            }
            else{
                glblLog.numberOfPages = pdfPageCount
            }
        }
        timer = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: "runTimedCode", userInfo: nil, repeats: true)
        
        burger.target = self.revealViewController()
        burger.action = Selector("revealToggle:")
        
        retrieveSavedData()
        
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateStyle = NSDateFormatterStyle.ShortStyle
        todaysDate = dateFormatter.stringFromDate(NSDate())
        let unit:NSCalendarUnit = NSCalendarUnit.Day
        /*
        if #available(iOS 8.0, *) {
            todaysDate = dateFormatter.stringFromDate(NSCalendar.currentCalendar().dateByAddingUnit(unit, value: glblLog.currentSession.numberOfDaysPassed, toDate: NSDate(), options: [])!)
        } else {
            print("device too old... datePicker mess up")
        }*/
        var currentSessionLastDateReached = todaysDate
        if(glblLog.currentSession.days.count > 0)
        {
            currentSessionLastDateReached = glblLog.currentSession.days[glblLog.currentSession.numberOfDaysPassed].date
        }
        print("today is \(todaysDate) and current session last date reached is \(currentSessionLastDateReached) comparision:")
        print(NSDate().compare(dateFormatter.dateFromString(currentSessionLastDateReached)!).rawValue)
        let dateComparison = dateFormatter.dateFromString(currentSessionLastDateReached)!.compare(NSDate()).rawValue
        /*
        print("currentSessionLastDateReached \(currentSessionLastDateReached)")
        print("today: \(NSDate())")
        print("todays date from calc: \(todaysDate)")*/
        if(currentSessionLastDateReached != todaysDate && dateComparison < 1){
            glblLog.currentSession.setNextDayStartPage()
            glblLog.currentSession.numberOfDaysPassed++
            print("numberOfDaysPassed added todays date: \(todaysDate) and session.days[numberOfDaysPassed - 1] = \(glblLog.currentSession.days[glblLog.currentSession.numberOfDaysPassed - 1].date)")
            updateProgressBar()
        }
        else{
            print("numberOfDaysPassed \(glblLog.currentSession.numberOfDaysPassed) \n added todays date: \(todaysDate) ")
            print(" \(glblLog.currentSession.toString())  ")
        }
        setTopBar()
    }
    func setTopBar(){
        //navigationItem.rightBarButtonItem?.image = UIImage(named: "logo.jpg")
        
        navigationItem.title = "Nellodee"
        

    }
    func webViewDidFinishLoad(webView: UIWebView) {
        self.webView.userInteractionEnabled = true
    }
    
    func scrollViewDidZoom(scrollView: UIScrollView) {
        if(scrollView.zoomScale <= 1){
            self.webView.scrollView.zoomScale = 1.01
        }
        if(diff > 0){
            let fillerHeightInc = pageHeight*(scrollView.zoomScale - 1)
            let fillerOldY = bottomView.frame.minY - diff
            if(diff - fillerHeightInc > 0){
                filler.frame = CGRect(x: 0, y: fillerOldY + fillerHeightInc, width: filler.frame.width, height: diff - fillerHeightInc)
            }
            else{
                filler.frame = CGRect(x: 0, y: bottomView.frame.minY, width: filler.frame.width, height: 0)
            }
        }
    }
    func scrollViewDidScroll(scrollView: UIScrollView) {
        let webViewHeight = self.webView.frame.size.height
        let screenHeight = self.view.frame.size.height
        var partSeen = pageHeight*scrollView.zoomScale
        if(screenHeight*0.837 < partSeen){
            partSeen = screenHeight*0.837
        }
        if(scrollDestinationUpdated && self.webView.loading == false && scrollView.zoomScale > 1){
            if(scrollView.contentOffset.y > (glblLog.scrollDestination + pageHeight)*scrollView.zoomScale  - partSeen){
                if let newY = (glblLog.scrollDestination + pageHeight)*scrollView.zoomScale  - partSeen as? CGFloat {
                    self.webView.scrollView.contentOffset.y = newY
                }
                //self.webView.scrollView.setContentOffset(CGPointMake(prevX, newY), animated: false)
            }
            else if(scrollView.contentOffset.y < glblLog.scrollDestination * scrollView.zoomScale ){
                if let newY = glblLog.scrollDestination*scrollView.zoomScale as? CGFloat {
                    self.webView.scrollView.contentOffset.y = newY
                }
                //self.webView.scrollView.setContentOffset(CGPointMake(prevX, newY), animated: false)
            }
        }
        NSThread.sleepForTimeInterval(0.001)
    }
    func buttonAction(sender: UIButton){
        webView.scrollView.setZoomScale(1.01, animated: true)
        let screenHeight = self.view.frame.size.height
        var partSeen = pageHeight
        if(screenHeight*0.837 < pageHeight){
            partSeen = screenHeight*0.837
        }
        self.webView.scrollView.setContentOffset(CGPointMake(0, glblLog.scrollDestination + (pageHeight - partSeen)/2), animated: false)
        if(glblLog.currentPageNumber > 0 && sender == self.prevPageButton){
            glblLog.currentPageNumber--
            glblLog.scrollDestination = glblLog.scrollDestination - pageHeight
            webView.scrollView.setContentOffset(CGPointMake(0, glblLog.scrollDestination), animated: false)
            jsonLogger.writeChangedPage(glblLog.currentPageNumber, direction: "Previous")
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
                webView.scrollView.setContentOffset(CGPointMake(0, glblLog.scrollDestination + 1000), animated: false)
                jsonLogger.writeChangedPage(glblLog.currentPageNumber, direction: "Next")
                updateProgressBar()
            }
            
        }
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        let screenWidth = view.frame.size.width
        let screenHeight = self.view.frame.size.height
        
        bottomView.backgroundColor = NellodeeBottomBarGray
        //navigationController.
        //UIColo.lightGrayColor()// rayColor()
        self.view.addSubview(bottomView)
        
        createNextAndPrevButtons()
        
        self.view.addSubview(button1)
        self.view.addSubview(button2)
        self.view.addSubview(guyView)
        let imageD = 50.0 as CGFloat
        
        guyView.setBackgroundImage(UIImage(named: "RunningMan_A.jpg"), forState: UIControlState.Normal)
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
        
        //colors
        startPageLabel.textColor = UIColor(red: 102/255, green: 51/255, blue: 51/255, alpha: 1)
        endPageLabel.textColor = UIColor(red: 102/255, green: 51/255, blue: 51/255, alpha: 1)
        currentPageLabel.textColor = UIColor(red: 102/255, green: 51/255, blue: 51/255, alpha: 1)
        button1.backgroundColor = UIColor(red: 102/255, green: 51/255, blue: 51/255, alpha: 1)
        button2.backgroundColor = UIColor(red: 51/255, green: 51/255, blue: 51/255, alpha: 1)
        webView.backgroundColor = UIColor(red: 51/255, green: 51/255, blue: 51/255, alpha: 1)
    }
    func createNextAndPrevButtons(){
        let screenWidth = view.frame.size.width
        let screenHeight = self.view.frame.size.height
        
        let buttonsWidth = screenWidth*0.07
        let distanceFromSides = screenWidth*0.03
        let distanceFromBottom = buttonsWidth + screenWidth*0.03
        
        self.prevPageButton.frame = CGRectMake(distanceFromSides, screenHeight - distanceFromBottom, buttonsWidth, buttonsWidth)
        //prevPageButton.setTitle("prev", forState: UIControlState.Normal)
        prevPageButton.addTarget(self, action: "buttonAction:", forControlEvents: UIControlEvents.TouchUpInside)
        prevPageButton.setBackgroundImage(UIImage(named: "leftArrow.jpg"), forState: UIControlState.Normal)
        
        self.nextPageButton.frame = CGRectMake(screenWidth - buttonsWidth - distanceFromSides, screenHeight - distanceFromBottom, buttonsWidth, buttonsWidth)
        //nextPageButton.setTitle("next", forState: UIControlState.Normal)
        nextPageButton.addTarget(self, action: "buttonAction:", forControlEvents: UIControlEvents.TouchUpInside)
        nextPageButton.setBackgroundImage(UIImage(named: "rightArrow.jpg"), forState: UIControlState.Normal)
        
        
        self.view.addSubview(nextPageButton)
        self.view.addSubview(prevPageButton)

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
                webView.frame = CGRectMake(0, webView.frame.minY, screenWidth, screenHeight*0.837 )
                bottomView.frame =  CGRectMake(0, webView.frame.maxY, screenWidth, screenHeight -  webView.frame.maxY)
                if(self.pageHeight < screenHeight*0.837){
                    diff = screenHeight*0.837 - self.pageHeight
                    filler = UIView(frame: CGRectMake(0, bottomView.frame.minY - diff, screenWidth, diff))
                    filler.backgroundColor = UIColor(red: 51/255, green: 51/255, blue: 51/255, alpha: 1)
                    self.view.addSubview(filler)
                }
                else{
                    
                }
                webView.scrollView.zoomScale = 1.01
                scrollDestinationUpdated = true
            }
            
        }
        if(glblLog.currentSession.days.count > 0){
            glblLog.currentSession.days[glblLog.currentSession.numberOfDaysPassed].time++
        }
        
        timeOnCurrentPage = glblLog.timeAtPageIndex[glblLog.currentPageNumber]
        
        if(timeOnCurrentPage == 0){
            guyView.setBackgroundImage(UIImage(named: "RunningMan_A.jpg"), forState: UIControlState.Normal)
        }
        else if(timeOnCurrentPage == 5){
            guyView.setBackgroundImage(UIImage(named: "RunningMan_B.jpg"), forState: UIControlState.Normal)
        }
        else if(timeOnCurrentPage == 10){
            guyView.setBackgroundImage(UIImage(named: "RunningMan_C.jpg"), forState: UIControlState.Normal)
        }
        
        glblLog.timeAtPageIndex[glblLog.currentPageNumber]++
    }
    
    
    
    func updateProgressBar(){
        let screenWidth = view.frame.size.width
        let screenHeight = self.view.frame.size.height
        let progressBarWidth = screenWidth - 200 as CGFloat
        var progress = 0.0 as CGFloat
        if(glblLog.currentSession.days.count > 0 && glblLog.currentSession.days.count > glblLog.currentSession.numberOfDaysPassed ){
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
        let buttonHeight = screenHeight*0.01 as CGFloat
        let guyHeight = screenHeight*0.04 as CGFloat
        let guyWidth = screenWidth/22
        let labelWidth = screenWidth/15
        let labelHeight = screenHeight/30
        
        button1.frame = CGRectMake(100, screenHeight - 2*buttonHeight - labelHeight, button1Width, buttonHeight)
        
        button2.frame = CGRectMake(100 + progress , screenHeight - 2*buttonHeight - labelHeight, button2Width, buttonHeight )
        
        if(glblLog.currentSession.days.count > 0){
            startPageLabel.text = "\(glblLog.currentSession.days[glblLog.currentSession.numberOfDaysPassed].startPage)"
            endPageLabel.text = "\(glblLog.currentSession.days[glblLog.currentSession.numberOfDaysPassed].endPage)"//"\(glblLog.startPage + glblLog.expectedPagesPerDay)"
        }
        currentPageLabel.frame = CGRectMake(100 + progress - 5, screenHeight - 2*buttonHeight - labelHeight, labelWidth, labelHeight )
        currentPageLabel.text = "\(glblLog.currentPageNumber)"
        if(currentPageLabel.text <= startPageLabel.text){
            startPageLabel.text = " "
        }
            /*
        else if let x = Int(endPageLabel.text!){
            if(Int(currentPageLabel.text!) >= x ){
            endPageLabel.text = " "
            }
        }*/
        guyView.frame = CGRectMake(100 + progress - guyWidth/2, screenHeight - 2*guyHeight - buttonHeight, guyWidth, guyHeight)
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
                endDate = "1/10/2016"
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
        //------------------------------ --------------- New day when opening app ---------------- -------------- -----------
        //let dateFormatter = NSDateFormatter()
        todaysDate = dateFormatter.stringFromDate(NSDate())
        var currentSessionLastDateReached = todaysDate
        if(glblLog.currentSession.days.count > 0)
        {
            currentSessionLastDateReached = glblLog.currentSession.days[glblLog.currentSession.numberOfDaysPassed].date
        }
        let dateComparison = dateFormatter.dateFromString(currentSessionLastDateReached)!.compare(NSDate()).rawValue
        if(currentSessionLastDateReached != todaysDate && dateComparison < 1){
            glblLog.currentSession.setNextDayStartPage()
            glblLog.currentSession.numberOfDaysPassed++
            print("numberOfDaysPassed added todays date: \(todaysDate) and session.days[numberOfDaysPassed - 1] = \(glblLog.currentSession.days[glblLog.currentSession.numberOfDaysPassed - 1].date)")
            updateProgressBar()
        }
        else{
            print("numberOfDaysPassed \n added todays date: \(todaysDate) ")
        }
        //------------------------------ --------------- New day when opening app ---------------- -------------- -----------
        
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

