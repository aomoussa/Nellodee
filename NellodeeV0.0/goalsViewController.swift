//
//  goalsViewController.swift
//  NellodeeV0.0
//
//  Created by ahmed moussa on 11/21/15.
//  Copyright © 2015 ahmed moussa. All rights reserved.
//

import UIKit

class goalsViewController: UIViewController {
    //local variables
    let defaults = NSUserDefaults.standardUserDefaults()
    let dateFormatter = NSDateFormatter()
    var goalSession = session()
    var barGraphStartIndex = 0
    var sessionIndex = glblLog.allSessions.count - 1
    var displaySession = session()
    var daysToDisplay = [day]()
    
    //UI stuff
    var bottomPrevButton = UIButton()
    var bottomNextButton = UIButton()
    var bars = [UIButton]()
    var expectedBars = [UIButton]()
    var dayLabelButtons = [UIButton]()
    var pagesPerDayLabels = [UILabel]()
    var expectedPagesPerDayLabels = [UILabel]()
    var segmentedControl = UISegmentedControl(items: ["Pages per Day", "Completion Date"])
    
    
    @IBAction func setChanges(sender: UIButton) {
        glblLog.maxPageReached = glblLog.currentPageNumber
        glblLog.addSession(goalSession)
        displaySession = glblLog.allSessions[++sessionIndex]
        if(displaySession.previousDays.count > 5){
           barGraphStartIndex = displaySession.previousDays.count - 5
        }
        
        refreshBarGraphs(barGraphStartIndex)
    }
    @IBOutlet var nextButton: UIButton!
    @IBOutlet var prevButton: UIButton!
    
    
    @IBOutlet var datePicker: UIDatePicker!
    var currentState = "date"//"pages"
    
    @IBAction func pagesSelectorEdited(sender: UIStepper) {
        segmentedControl.selectedSegmentIndex = 0
        
        let pagesPerDay = Int(sender.value).description
        pagesSelectorLabel.text = pagesPerDay
        
        let expectedPagesPerDay = Int(pagesPerDay)!
        var numOfDays = 0
        if(expectedPagesPerDay > 0 && glblLog.numberOfPages > 0){
            numOfDays = (glblLog.numberOfPages-glblLog.currentPageNumber)/expectedPagesPerDay + 1
        }
        let startDate = dateFormatter.stringFromDate(NSDate())
        var finishDate = startDate
        let unit:NSCalendarUnit = NSCalendarUnit.Day
        if #available(iOS 8.0, *) {
            finishDate = dateFormatter.stringFromDate(NSCalendar.currentCalendar().dateByAddingUnit(unit, value: numOfDays, toDate: NSDate(), options: [])!)
        } else {
            print("device too old... datePicker mess up")
        }
        goalSession = session(startDate: startDate, endDate: finishDate, expectedPagesPerDay: expectedPagesPerDay, state: "pagesPerDayState")
    }
    @IBOutlet var pagesSelector: UIStepper!
    @IBOutlet var currentStateLabel: UILabel!
    @IBOutlet var pagesSelectorLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        dateFormatter.dateStyle = NSDateFormatterStyle.ShortStyle
        
        datePicker.minimumDate = NSDate()
        datePicker.addTarget(self, action: Selector("datePickerChanged"), forControlEvents: UIControlEvents.ValueChanged)
        
        pagesSelector.autorepeat = true
        pagesSelector.maximumValue = 100
        
        if(glblLog.currentSession.state == "pagesPerDayState"){
            segmentedControl.selectedSegmentIndex = 0
        }
        else{
            segmentedControl.selectedSegmentIndex = 1
        }
        
        
        //----------------------------multiple session display array creation--------------------begin
        displaySession = glblLog.allSessions[sessionIndex]
        daysToDisplay = displaySession.previousDays
        for temp in displaySession.days{
            daysToDisplay.append(temp)
        }
        
        //----------------------------multiple session display array creation--------------------end
        //print("displaySession.previousDays.count \(displaySession.previousDays.count)")
        if(displaySession.previousDays.count + displaySession.numberOfDaysPassed > 5){
            barGraphStartIndex = displaySession.previousDays.count + displaySession.numberOfDaysPassed - 5
            if(barGraphStartIndex > daysToDisplay.count - 10){
                barGraphStartIndex = daysToDisplay.count - 10
            }
            
        }
    }
    
    
    
    func datePickerChanged(){
        segmentedControl.selectedSegmentIndex = 1
        
        let strDate = dateFormatter.stringFromDate(datePicker.date)
        let unit:NSCalendarUnit = NSCalendarUnit.Day
        let comps = NSCalendar.currentCalendar().components(unit, fromDate: NSDate(), toDate: datePicker.date, options: [])
        
        if(comps.day > 0 && glblLog.numberOfPages > 0){
            goalSession = session(startDate: dateFormatter.stringFromDate(NSDate()), endDate: strDate, expectedPagesPerDay: (glblLog.numberOfPages-glblLog.currentPageNumber) / comps.day, state: "completionDateState")
        }
        else{
            print("date edit failed ")
        }
    }
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        createLines()
        createPrevAndNextButtons()
        createLabels()
        createBarGraphs()
        
    }
    func buttonAction(sender: UIButton){
        
        if(sender == self.bottomPrevButton){
            if(barGraphStartIndex > 0){
                barGraphStartIndex--
                refreshBarGraphs(barGraphStartIndex)
            }
                //----------------------------multiple session display--------------------begin
/*
            else{
                if(sessionIndex>0){
                    sessionIndex--
                    displaySession = glblLog.allSessions[sessionIndex]
                    if(displaySession.days.count>10){
                        barGraphStartIndex = displaySession.days.count - 10
                    }
                    else{
                        barGraphStartIndex = 0
                    }
                    if(displaySession.state == "pagesPerDayState"){
                        segmentedControl.selectedSegmentIndex = 0
                    }
                    else{
                        segmentedControl.selectedSegmentIndex = 1
                    }
                    refreshBarGraphs(barGraphStartIndex)
                }
            }
*/
            //----------------------------multiple session display--------------------end
        }
        if(sender == self.bottomNextButton){
            if(barGraphStartIndex < daysToDisplay.count - 10){
                barGraphStartIndex++
                refreshBarGraphs(barGraphStartIndex)
            }
                //----------------------------multiple session display--------------------begin
                /*
            else{
                if(sessionIndex < glblLog.allSessions.count - 1){
                    sessionIndex++
                    displaySession = glblLog.allSessions[sessionIndex]
                    if(displaySession.state == "pagesPerDayState"){
                        segmentedControl.selectedSegmentIndex = 0
                    }
                    else{
                        segmentedControl.selectedSegmentIndex = 1
                    }
                    refreshBarGraphs(0)
                }
            }*/
            //----------------------------multiple session display--------------------end
        }
    }
    
    func createLines(){
        
        let screenWidth = view.frame.size.width
        let screenHeight = self.view.frame.size.height
        let YlineHeight = screenHeight*0.5
        
        segmentedControl.frame =  CGRectMake(screenWidth/2 - 100 , screenHeight/2 - 250, screenWidth/3, screenHeight/40)
        self.view.addSubview(segmentedControl)
        
        let lineViewX = UIView.init(frame: CGRectMake(40, screenHeight - 100, screenWidth, 1))
        lineViewX.backgroundColor = UIColor.blackColor()
        self.view.addSubview(lineViewX)
        
        let lineViewY = UIView.init(frame: CGRectMake(40, screenHeight - YlineHeight - 150, 2, YlineHeight + 50))
        lineViewY.backgroundColor = UIColor.blackColor()
        self.view.addSubview(lineViewY)
        
        let scaleLine1 = UIView(frame: CGRectMake(40, screenHeight*0.75, screenWidth, 2))
        scaleLine1.backgroundColor = UIColor.blackColor()
        self.view.addSubview(scaleLine1)
        
        let scaleLine2 = UIView(frame: CGRectMake(40, screenHeight*0.6, screenWidth, 2))
        scaleLine2.backgroundColor = UIColor.blackColor()
        self.view.addSubview(scaleLine2)
        
        let scaleLine3 = UIView(frame: CGRectMake(40, screenHeight - YlineHeight - 100, screenWidth, 2))
        scaleLine3.backgroundColor = UIColor.blackColor()
        self.view.addSubview(scaleLine3)
        
        let scaleLabel1 = UILabel(frame: CGRectMake(10, screenHeight*0.75 - 10, 30, 20))
        scaleLabel1.text = "15"
        self.view.addSubview(scaleLabel1)
        
        let scaleLabel2 = UILabel(frame: CGRectMake(10, screenHeight*0.6 - 10, 30, 20))
        scaleLabel2.text = "30"
        self.view.addSubview(scaleLabel2)
        
        let scaleLabel3 = UILabel(frame: CGRectMake(10, screenHeight - YlineHeight - 100, 50, 20))
        scaleLabel3.text = "50+"
        self.view.addSubview(scaleLabel3)
    }
    func createPrevAndNextButtons(){
        let screenWidth = view.frame.size.width
        let screenHeight = self.view.frame.size.height
        
        let prevButtonX = screenWidth*8/10
        let nextButtonX = screenWidth*9/10
        let bottomYs = screenHeight*9.5/10
        
        let buttonWidth = screenWidth/25 as CGFloat
        
        self.bottomPrevButton = UIButton(frame: CGRectMake(prevButtonX, bottomYs, buttonWidth, buttonWidth))
        bottomPrevButton.setBackgroundImage(UIImage(named: "a.jpg"), forState: UIControlState.Normal)
        bottomPrevButton.addTarget(self, action: "buttonAction:", forControlEvents: UIControlEvents.TouchUpInside)
        self.view.addSubview(bottomPrevButton)
        
        self.bottomNextButton = UIButton(frame: CGRectMake(nextButtonX , bottomYs, buttonWidth, buttonWidth))
        bottomNextButton.setBackgroundImage(UIImage(named: "b.jpg"), forState: UIControlState.Normal)
        bottomNextButton.addTarget(self, action: "buttonAction:", forControlEvents: UIControlEvents.TouchUpInside)
        self.view.addSubview(bottomNextButton)
        
        
    }
    
    /*func refreshBarGraphs(i: Int){
    
    let screenWidth = view.frame.size.width
    let screenHeight = self.view.frame.size.height
    let distanceBetweenBars = screenWidth*0.09
    let buttonIncrements = screenHeight*0.01
    var count = 0
    var index = 0.0 as CGFloat
    //for loop populsting array of buttons for bar graph
    var indexPage = i
    while(count < 10){
    if(indexPage < glblLog.currentSession.days.count){
    
    let buttonWidth = 20.0 as CGFloat
    var buttonHeight = 10.0 as CGFloat
    //var buttonHeight2 = 10.0 as CGFloat
    let dayLabelbuttonHeight = 20.0 as CGFloat
    let dayLabelbuttonWidth = buttonWidth*3
    
    
    buttonHeight = CGFloat(glblLog.currentSession.days[indexPage].expectedPages) * buttonIncrements
    if(buttonHeight > screenHeight*0.5){
    buttonHeight = screenHeight*0.5
    }
    bars[count].frame = CGRectMake(70 + (index)*distanceBetweenBars , screenHeight-buttonHeight - 100, buttonWidth, buttonHeight)
    
    expectedPagesPerDayLabels[count].frame = CGRectMake(70 + (index)*distanceBetweenBars , screenHeight-buttonHeight - 120, buttonWidth*2, 20)
    if(count <= glblLog.currentSession.expectedNumOfDays){
    expectedPagesPerDayLabels[count].text = "\(glblLog.currentSession.days[indexPage].expectedPages)"
    }
    else{
    expectedPagesPerDayLabels[count].text = "0"
    }
    
    
    var buttonHeight2 = 0.0 as CGFloat
    buttonHeight2 = CGFloat(glblLog.currentSession.days[indexPage].pages.count) * buttonIncrements
    
    if(buttonHeight2 > screenHeight*0.5){
    buttonHeight2 = screenHeight*0.5
    }
    expectedBars[count].frame = CGRectMake(45 + (index)*distanceBetweenBars , screenHeight-buttonHeight2 - 100, buttonWidth, buttonHeight2)
    
    pagesPerDayLabels[count].frame = CGRectMake(45 + (index)*distanceBetweenBars , screenHeight-buttonHeight2 - 120, buttonWidth*2, 20)
    pagesPerDayLabels[count].text = "\(glblLog.currentSession.days[indexPage].pages.count)"
    
    let thisDate = glblLog.currentSession.days[indexPage].date
    if(thisDate == glblLog.currentSession.days[glblLog.currentSession.numberOfDaysPassed].date){
    dayLabelButtons[count].setTitle("today", forState: UIControlState.Normal)
    }else{
    dayLabelButtons[count].setTitle(thisDate.substringToIndex(thisDate.startIndex.advancedBy(5)), forState: UIControlState.Normal)
    }
    index++
    
    }
    indexPage++
    count++
    }
    
    
    }
*/
    func refreshBarGraphs(i: Int){
        
        let screenWidth = view.frame.size.width
        let screenHeight = self.view.frame.size.height
        let distanceBetweenBars = screenWidth*0.09
        let buttonIncrements = screenHeight*0.01
        var count = 0
        var index = 0.0 as CGFloat
        //for loop populsting array of buttons for bar graph
        var indexPage = i
        while(count < 10){
            if(indexPage < daysToDisplay.count){
                
                let buttonWidth = 20.0 as CGFloat
                var buttonHeight = 10.0 as CGFloat
                //var buttonHeight2 = 10.0 as CGFloat
                let dayLabelbuttonHeight = 20.0 as CGFloat
                let dayLabelbuttonWidth = buttonWidth*3
                
                
                buttonHeight = CGFloat(daysToDisplay[indexPage].expectedPages) * buttonIncrements
                if(buttonHeight > screenHeight*0.5){
                    buttonHeight = screenHeight*0.5
                }
                bars[count].frame = CGRectMake(70 + (index)*distanceBetweenBars , screenHeight-buttonHeight - 100, buttonWidth, buttonHeight)
                
                expectedPagesPerDayLabels[count].frame = CGRectMake(70 + (index)*distanceBetweenBars , screenHeight-buttonHeight - 120, buttonWidth*2, 20)
                if(count <= daysToDisplay.count){
                    expectedPagesPerDayLabels[count].text = "\(daysToDisplay[indexPage].expectedPages)"
                }
                else{
                    expectedPagesPerDayLabels[count].text = "0"
                }
                
                
                var buttonHeight2 = 0.0 as CGFloat
                buttonHeight2 = CGFloat(daysToDisplay[indexPage].pages.count) * buttonIncrements
                
                if(buttonHeight2 > screenHeight*0.5){
                    buttonHeight2 = screenHeight*0.5
                }
                expectedBars[count].frame = CGRectMake(45 + (index)*distanceBetweenBars , screenHeight-buttonHeight2 - 100, buttonWidth, buttonHeight2)
                
                pagesPerDayLabels[count].frame = CGRectMake(45 + (index)*distanceBetweenBars , screenHeight-buttonHeight2 - 120, buttonWidth*2, 20)
                pagesPerDayLabels[count].text = "\(daysToDisplay[indexPage].pages.count)"
                
                //------------------------------ TODAY Label ----------------------------------------------
                let thisDate = daysToDisplay[indexPage].date
                if(daysToDisplay.count > displaySession.numberOfDaysPassed + displaySession.previousDays.count && thisDate == daysToDisplay[displaySession.numberOfDaysPassed + displaySession.previousDays.count].date){
                    dayLabelButtons[count].setTitle("today", forState: UIControlState.Normal)
                }else{
                    dayLabelButtons[count].setTitle(thisDate.substringToIndex(thisDate.startIndex.advancedBy(5)), forState: UIControlState.Normal)
                }

                index++
                
            }
            else{
                bars[count].frame = CGRectMake(70 + (index)*distanceBetweenBars , screenHeight - 100, 30, 0)
                expectedBars[count].frame = CGRectMake(45 + (index)*distanceBetweenBars , screenHeight - 100, 30, 0)
                
                expectedPagesPerDayLabels[count].frame = CGRectMake(70 + (index)*distanceBetweenBars , screenHeight - 120, 20, 20)
                expectedPagesPerDayLabels[count].text = " "
                
                pagesPerDayLabels[count].frame = CGRectMake(45 + (index)*distanceBetweenBars , screenHeight - 120, 20, 20)
                pagesPerDayLabels[count].text = " "
                
                dayLabelButtons[count].setTitle(" ", forState: UIControlState.Normal)
            }
            indexPage++
            count++
        }
        
        
    }
    
    func createBarGraphs(){
        var count = 0
        //for loop populsting array of buttons for bar graph
        while(count < 10){
            bars.append(UIButton())
            bars[count].backgroundColor = UIColor.blueColor()
            self.view.addSubview(bars[count])
            
            expectedPagesPerDayLabels.append(UILabel())
            self.view.addSubview(expectedPagesPerDayLabels[count])
            
            expectedBars.append(UIButton())
            expectedBars[count].backgroundColor = UIColor.redColor()
            self.view.addSubview(expectedBars[count])
            
            pagesPerDayLabels.append(UILabel())
            self.view.addSubview(pagesPerDayLabels[count])
            
            count++
        }
        refreshBarGraphs(barGraphStartIndex)
    }
    
    func createLabels(){
        let screenWidth = view.frame.size.width
        let screenHeight = self.view.frame.size.height
        let dayLabelbuttonHeight = 20.0 as CGFloat
        let dayLabelbuttonWidth = dayLabelbuttonHeight*3
        let distanceBetweenBars = screenWidth*0.09
        var count = 0
        while(count < 10){
            dayLabelButtons.append(UIButton(frame: CGRectMake(40 + (CGFloat(count))*distanceBetweenBars , screenHeight - dayLabelbuttonHeight - 75, dayLabelbuttonWidth, dayLabelbuttonHeight)))
            dayLabelButtons[count].backgroundColor = UIColor.grayColor()
            self.view.addSubview(dayLabelButtons[count])
            count++
        }
        
    }
    override func viewDidDisappear(animated: Bool) {
        
        self.saveData()
    }
    func saveData(){
        defaults.setObject(glblLog.currentPageNumber, forKey: "currentPageNumber")
        let stringArray2 = glblLog.timeAtPageIndex.map({
            (number: Int) -> String in
            return String(number)
        })
        defaults.setObject(stringArray2, forKey: "timeAtPageIndex")
        
        
        defaults.setObject(glblLog.currentSession.numberOfDaysPassed, forKey: "currentSessionNumberOfDaysPassed")
        defaults.setObject(glblLog.currentSession.state, forKey: "currentSessionSelectorState")
        defaults.setObject(glblLog.currentSession.startDate, forKey: "currentSessionStartDate")
        defaults.setObject(glblLog.currentSession.endDate, forKey: "currentSessionEndDate")
        defaults.setObject(glblLog.currentSession.expectedPagesPerDay, forKey: "currentSessionExpectedPagesPerDay")
        
        var startPagesString = [String]()
        var endPagesString = [String]()
        var timeOnDay = [String]()
        var pagesReadAtIndexDay = [[String]]()
        var i = 0
        var j = 0
        for temp in glblLog.currentSession.days{
            startPagesString.append("\(temp.startPage)")
            endPagesString.append("\(temp.endPage)")
            timeOnDay.append("\(temp.time)")
            pagesReadAtIndexDay.append([String]())
            for tempPage in temp.pages{
                
                pagesReadAtIndexDay[i].append("\(tempPage.pageNumber)")
                j++
            }
            defaults.setObject(pagesReadAtIndexDay[i], forKey: "actualPagesPerDay\(i)")
            i++
        }
        defaults.setObject(timeOnDay, forKey: "timePerDay")
        defaults.setObject(startPagesString, forKey: "startPagesStringArray")
        defaults.setObject(endPagesString, forKey: "endPagesStringArray")
        //-----------------------------Saving previous days--------------------------------/
        defaults.setObject(glblLog.currentSession.previousDays.count, forKey: "previousDaysCount")
        if(glblLog.currentSession.previousDays.count > 0){
            var previousDaysStartPagesString = [String]()
            var previousDaysEndPagesString = [String]()
            var previousDaysTimeOnDay = [String]()
            var previousDaysPagesReadAtIndexDay = [[String]]()
            var i = 0
            var j = 0

            for temp in glblLog.currentSession.previousDays{
                previousDaysStartPagesString.append("\(temp.startPage)")
                previousDaysEndPagesString.append("\(temp.endPage)")
                previousDaysTimeOnDay.append("\(temp.time)")
                previousDaysPagesReadAtIndexDay.append([String]())
                for tempPage in temp.pages{
                    
                    previousDaysPagesReadAtIndexDay[i].append("\(tempPage.pageNumber)")
                    j++
                }
                defaults.setObject(previousDaysPagesReadAtIndexDay[i], forKey: "PreviousDaysActualPagesPerDay\(i)")
                i++
            }
            defaults.setObject(previousDaysTimeOnDay, forKey: "previousDaysTimeOnDay")
            defaults.setObject(previousDaysStartPagesString, forKey: "previousDaysStartPagesString")
            defaults.setObject(previousDaysEndPagesString, forKey: "previousDaysEndPagesString")
        }
        //-----------------------------Saving previous days--------------------------------/
        /*
        //-----------------------------Saving previous sessions--------------------------------/
        defaults.setObject(glblLog.allSessions.count, forKey: "numberOfSessions")
        var sessionIndex = 0
        for session in glblLog.allSessions{
            defaults.setObject(session.state, forKey: "selectorStateSession\(sessionIndex)")
            defaults.setObject(session.startDate, forKey: "startDateSession\(sessionIndex)")
            defaults.setObject(session.endDate, forKey: "endDateSession\(sessionIndex)")
            defaults.setObject(session.expectedPagesPerDay, forKey: "expectedPagesPerDaySession\(sessionIndex)")
            
            var startPagesString = [String]()
            var endPagesString = [String]()
            var timeOnDay = [String]()
            var pagesReadAtIndexDay = [[String]]()
            var i = 0
            var j = 0
            for temp in session.days{
                startPagesString.append("\(temp.startPage)")
                endPagesString.append("\(temp.endPage)")
                timeOnDay.append("\(temp.time)")
                pagesReadAtIndexDay.append([String]())
                for tempPage in temp.pages{
                    
                    pagesReadAtIndexDay[i].append("\(tempPage.pageNumber)")
                    j++
                }
                defaults.setObject(pagesReadAtIndexDay[i], forKey: "actualPagesPerDay\(i)OnSession\(sessionIndex)")
                i++
            }
            defaults.setObject(timeOnDay, forKey: "timePerDaySession\(sessionIndex)")
            defaults.setObject(startPagesString, forKey: "startPagesStringArraySession\(sessionIndex)")
            defaults.setObject(endPagesString, forKey: "endPagesStringArraySession\(sessionIndex)")
            
            sessionIndex++
        }
        */
    //-----------------------------Saving previous sessions-----------------------------------
    }
}