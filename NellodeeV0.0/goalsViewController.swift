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
    var indexAtTodaysDate = 0
    let NellodeeMaroonColor = UIColor(red: 102/255, green: 51/255, blue: 51/255, alpha: 1)
    let NellodeeMidGray = UIColor(red: 51/255, green: 51/255, blue: 51/255, alpha: 1)
    
    //UI stuff
    var bottomPrevButton = UIButton()
    var bottomNextButton = UIButton()
    var bars = [UIButton]()
    var expectedBars = [UIButton]()
    var dayLabelButtons = [UIButton]()
    var pagesPerDayLabels = [UILabel]()
    var expectedPagesPerDayLabels = [UILabel]()
    
    
    //box stuff
    var leftLineOfBox1 = UIView()
    var rightLineOfBox1 = UIView()
    var topLineOfBox1 = UIView()
    var bottomLineOfBox1 = UIView()
    
    var leftLineOfBox2 = UIView()
    var rightLineOfBox2 = UIView()
    var topLineOfBox2 = UIView()
    var bottomLineOfBox2 = UIView()
    
    //var segmentedControl = UISegmentedControl(items: ["Pages per Day", "Completion Date"])
    
    
    @IBAction func setChanges(sender: UIButton) {
        glblLog.maxPageReached = glblLog.currentPageNumber
        glblLog.addSession(goalSession)
        displaySession = glblLog.allSessions[++sessionIndex]
        if(displaySession.previousDays.count > 5){
            barGraphStartIndex = displaySession.previousDays.count - 5
        }
        daysToDisplay = displaySession.previousDays
        for temp in displaySession.days{
            daysToDisplay.append(temp)
        }
        refreshBarGraphs(barGraphStartIndex)
        //performSegueWithIdentifier("reloadGoals", sender: self)
    }
    
    
    @IBOutlet var datePicker: UIDatePicker!
    var currentState = "date"//"pages"
    
    @IBAction func pagesSelectorEdited(sender: UIStepper) {
        //segmentedControl.selectedSegmentIndex = 0
        setBoxesForState("pagesPerDay")
        
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
            //segmentedControl.selectedSegmentIndex = 0
            setBoxesForState("pagesPerDay")
        }
        else{
            //segmentedControl.selectedSegmentIndex = 1
            setBoxesForState("endDate")
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
        //segmentedControl.selectedSegmentIndex = 1
        setBoxesForState("endDate")
        
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
        createBoxes()
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
        }
        if(sender == self.bottomNextButton){
            if(barGraphStartIndex < daysToDisplay.count - 10){
                barGraphStartIndex++
                refreshBarGraphs(barGraphStartIndex)
            }
        }
    }
    
    func createBoxes(){
        
        let screenWidth = view.frame.size.width
        let screenHeight = self.view.frame.size.height
        let topY = screenHeight*0.1
        let bottomY = screenHeight*0.37
        let leftXBox1 = screenWidth*0.05
        let rightXBox1 = screenWidth*0.5 - 2
        let leftXBox2 = screenWidth*0.5 + 2
        let rightXBox2 = screenWidth*0.95
        
        //segmentedControl.frame =  CGRectMake(screenWidth/2 - 100 , screenHeight/2 - 250, screenWidth/3, screenHeight/40)
        //self.view.addSubview(segmentedControl)
        leftLineOfBox1.frame = CGRectMake(leftXBox1, topY, 4, bottomY - topY)
        rightLineOfBox1.frame = CGRectMake(rightXBox1, topY, 4, bottomY - topY)
        topLineOfBox1.frame = CGRectMake(leftXBox1, topY, rightXBox1 - leftXBox1, 4)
        bottomLineOfBox1.frame = CGRectMake(leftXBox1, bottomY, rightXBox1 - leftXBox1, 4)
        
        leftLineOfBox2.frame = CGRectMake(leftXBox2, topY, 4, bottomY - topY)
        rightLineOfBox2.frame = CGRectMake(rightXBox2, topY, 4, bottomY - topY)
        topLineOfBox2.frame = CGRectMake(leftXBox2, topY, rightXBox2 - leftXBox2, 4)
        bottomLineOfBox2.frame = CGRectMake(leftXBox2, bottomY, rightXBox2 - leftXBox2, 4)
        
        leftLineOfBox1.backgroundColor = UIColor.grayColor()
        rightLineOfBox1.backgroundColor = UIColor.grayColor()
        topLineOfBox1.backgroundColor = UIColor.grayColor()
        bottomLineOfBox1.backgroundColor = UIColor.grayColor()
        
        leftLineOfBox2.backgroundColor = UIColor.grayColor()
        rightLineOfBox2.backgroundColor = UIColor.grayColor()
        topLineOfBox2.backgroundColor = UIColor.grayColor()
        bottomLineOfBox2.backgroundColor = UIColor.grayColor()
        
        self.view.addSubview(leftLineOfBox1)
        self.view.addSubview(rightLineOfBox1)
        self.view.addSubview(topLineOfBox1)
        self.view.addSubview(bottomLineOfBox1)
        
        self.view.addSubview(leftLineOfBox2)
        self.view.addSubview(rightLineOfBox2)
        self.view.addSubview(topLineOfBox2)
        self.view.addSubview(bottomLineOfBox2)
    }
    func setBoxesForState(goalState: String){
        var leftBoxColor = UIColor.grayColor()
        var rightBoxColor = UIColor.grayColor()
        switch(goalState){
        case "pagesPerDay":
            leftBoxColor = NellodeeMaroonColor
            break
        case "endDate":
            rightBoxColor = NellodeeMaroonColor
            break
        default:
            break
            
        }
        leftLineOfBox1.backgroundColor = leftBoxColor
        rightLineOfBox1.backgroundColor = leftBoxColor
        topLineOfBox1.backgroundColor = leftBoxColor
        bottomLineOfBox1.backgroundColor = leftBoxColor
        
        leftLineOfBox2.backgroundColor = rightBoxColor
        rightLineOfBox2.backgroundColor = rightBoxColor
        topLineOfBox2.backgroundColor = rightBoxColor
        bottomLineOfBox2.backgroundColor = rightBoxColor
    }
    
    func createLines(){
        
        let screenWidth = view.frame.size.width
        let screenHeight = self.view.frame.size.height
        let buttonIncrements = screenHeight*0.007
        let YlineHeight = screenHeight*0.35
        let bottomOffset = screenWidth*0.13
        let linesOffset = screenWidth*0.12
        let labelWidth = screenWidth*0.1
        
        //segmentedControl.frame =  CGRectMake(screenWidth/2 - 100 , screenHeight/2 - 250, screenWidth/3, screenHeight/40)
        //self.view.addSubview(segmentedControl)
        
        let lineViewX = UIView.init(frame: CGRectMake(linesOffset, screenHeight - bottomOffset, screenWidth, 2))
        lineViewX.backgroundColor = UIColor.grayColor()
        self.view.addSubview(lineViewX)
        
        let lineViewY = UIView.init(frame: CGRectMake(linesOffset, screenHeight - YlineHeight - 150, 2, YlineHeight + 50))
        lineViewY.backgroundColor = UIColor.grayColor()
        self.view.addSubview(lineViewY)
        
        let scaleLine1 = UIView(frame: CGRectMake(linesOffset, screenHeight - bottomOffset - 15*buttonIncrements, screenWidth, 2))
        scaleLine1.backgroundColor = UIColor.grayColor()
        self.view.addSubview(scaleLine1)
        
        let scaleLine2 = UIView(frame: CGRectMake(linesOffset,  screenHeight - bottomOffset - 30*buttonIncrements, screenWidth, 2))
        scaleLine2.backgroundColor = UIColor.grayColor()
        self.view.addSubview(scaleLine2)
        
        let scaleLine3 = UIView(frame: CGRectMake(linesOffset,  screenHeight - bottomOffset - 50*buttonIncrements, screenWidth, 2))
        scaleLine3.backgroundColor = UIColor.grayColor()
        self.view.addSubview(scaleLine3)
        
        let scaleLabel1 = UILabel(frame: CGRectMake(10,  screenHeight - bottomOffset - 15*buttonIncrements - 10, labelWidth, 20))
        scaleLabel1.text = "15 pages"
        self.view.addSubview(scaleLabel1)
        
        let scaleLabel2 = UILabel(frame: CGRectMake(10,  screenHeight - bottomOffset - 30*buttonIncrements - 10, labelWidth, 20))
        scaleLabel2.text = "30 pages"
        self.view.addSubview(scaleLabel2)
        
        let scaleLabel3 = UILabel(frame: CGRectMake(10,  screenHeight - bottomOffset - 50*buttonIncrements - 10, labelWidth, 20))
        scaleLabel3.text = "50 pages"
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
        //bottomPrevButton.backgroundColor = NellodeeMidGray
        bottomPrevButton.addTarget(self, action: "buttonAction:", forControlEvents: UIControlEvents.TouchUpInside)
        bottomPrevButton.setBackgroundImage(UIImage(named: "leftArrow.jpg"), forState: UIControlState.Normal)
        self.view.addSubview(bottomPrevButton)
        
        self.bottomNextButton = UIButton(frame: CGRectMake(nextButtonX , bottomYs, buttonWidth, buttonWidth))
        //bottomNextButton.backgroundColor = NellodeeMidGray
        bottomNextButton.setBackgroundImage(UIImage(named: "rightArrow.jpg"), forState: UIControlState.Normal)
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
        let offset = screenWidth*0.14
        let bottomOffset = screenHeight*0.1
        let distanceBetweenBars = screenWidth*0.14
        let buttonIncrements = screenHeight*0.007
        var count = 0
        var index = 0.0 as CGFloat
        //for loop populsting array of buttons for bar graph
        var indexPage = i
        while(count < 6){
            if(indexPage>=0 && indexPage < daysToDisplay.count){
                
                let buttonWidth = screenWidth*0.05
                var buttonHeight = 10.0 as CGFloat
                //var buttonHeight2 = 10.0 as CGFloat
                let dayLabelbuttonHeight = 20.0 as CGFloat
                let dayLabelbuttonWidth = buttonWidth*3
                
                if(daysToDisplay[indexPage].expectedPages>=0){
                    buttonHeight = CGFloat(daysToDisplay[indexPage].expectedPages) * buttonIncrements
                }
                if(buttonHeight > screenHeight*0.4){
                    buttonHeight = screenHeight*0.4
                }
                bars[count].frame = CGRectMake(offset + (index)*distanceBetweenBars , screenHeight-buttonHeight - bottomOffset, buttonWidth, buttonHeight)
                
                expectedPagesPerDayLabels[count].frame = CGRectMake(offset + (index)*distanceBetweenBars , screenHeight-buttonHeight - bottomOffset, buttonWidth, 20)
                if(count <= daysToDisplay.count && daysToDisplay[indexPage].pages.count <= 0){
                    expectedPagesPerDayLabels[count].text = "\(daysToDisplay[indexPage].expectedPages)"
                }
                else{
                    expectedPagesPerDayLabels[count].text = ""
                }
                
                
                var buttonHeight2 = 0.0 as CGFloat
                if(daysToDisplay[indexPage].pages.count>=0){
                    buttonHeight2 = CGFloat(daysToDisplay[indexPage].pages.count) * buttonIncrements
                }
                if(buttonHeight2 > screenHeight*0.4){
                    buttonHeight2 = screenHeight*0.4
                }
                let expectedBarsXs = offset + (index)*distanceBetweenBars + buttonWidth*0.75
                expectedBars[count].frame = CGRectMake(expectedBarsXs , screenHeight-buttonHeight2 - bottomOffset, buttonWidth, buttonHeight2)
                
                pagesPerDayLabels[count].frame = CGRectMake(expectedBarsXs , screenHeight-buttonHeight2 - bottomOffset, buttonWidth, 20)
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
                bars[count].frame = CGRectMake(70 + (index)*distanceBetweenBars , screenHeight - bottomOffset, 30, 0)
                expectedBars[count].frame = CGRectMake(45 + (index)*distanceBetweenBars , screenHeight - bottomOffset, 30, 0)
                
                expectedPagesPerDayLabels[count].frame = CGRectMake(70 + (index)*distanceBetweenBars , screenHeight - bottomOffset, 20, 20)
                expectedPagesPerDayLabels[count].text = " "
                
                pagesPerDayLabels[count].frame = CGRectMake(45 + (index)*distanceBetweenBars , screenHeight - bottomOffset, 20, 20)
                pagesPerDayLabels[count].text = " "
                
                dayLabelButtons[count].setTitle(" ", forState: UIControlState.Normal)
            }
            indexPage++
            count++
        }
        
        //------------------------------ TODAY, prev and future Label clrs ----------------------------------------------
        indexPage--
        count--
        while(count >= 0){
            //------------------------------ TODAY Label ----------------------------------------------
            var thisDate = "whatever"
            if(indexPage < daysToDisplay.count){
                thisDate = daysToDisplay[indexPage].date
            }
            if(indexPage > indexAtTodaysDate){
                dayLabelButtons[count].setTitleColor(NellodeeMaroonColor, forState: UIControlState.Normal)
            }
            else{
                dayLabelButtons[count].setTitleColor(NellodeeMidGray, forState: UIControlState.Normal)
            }
            
            if(indexAtTodaysDate == 0 && glblLog.currentSession.numberOfDaysPassed + glblLog.currentSession.previousDays.count < daysToDisplay.count && thisDate == daysToDisplay[glblLog.currentSession.numberOfDaysPassed + glblLog.currentSession.previousDays.count].date){
                indexAtTodaysDate = indexPage
                dayLabelButtons[count].setTitle("today", forState: UIControlState.Normal)
                dayLabelButtons[count].setTitleColor(NellodeeMaroonColor, forState: UIControlState.Normal)
            }
            else if (indexPage == indexAtTodaysDate){
                dayLabelButtons[count].setTitle("today", forState: UIControlState.Normal)
                dayLabelButtons[count].setTitleColor(NellodeeMaroonColor, forState: UIControlState.Normal)
            }
            else if(indexPage < daysToDisplay.count)
            {
                dayLabelButtons[count].setTitle("\(daysToDisplay[indexPage].date)", forState: UIControlState.Normal)
            }
            //------------------------------ TODAY Label ----------------------------------------------
            count--
            indexPage--
        }
        //------------------------------ TODAY, prev and future Label clrs ----------------------------------------------
        
        
    }
    
    func createBarGraphs(){
        var count = 0
        //for loop populsting array of buttons for bar graph
        while(count < 6){
            bars.append(UIButton())
            bars[count].backgroundColor = UIColor(red: 153/255, green: 153/255, blue: 153/255, alpha: 1)
            self.view.addSubview(bars[count])
            
            expectedPagesPerDayLabels.append(UILabel())
            expectedPagesPerDayLabels[count].textColor = UIColor.whiteColor()
            expectedPagesPerDayLabels[count].textAlignment = .Center
            self.view.addSubview(expectedPagesPerDayLabels[count])
            
            expectedBars.append(UIButton())
            expectedBars[count].backgroundColor = NellodeeMaroonColor
            self.view.addSubview(expectedBars[count])
            
            pagesPerDayLabels.append(UILabel())
            pagesPerDayLabels[count].textColor = UIColor.whiteColor()
            pagesPerDayLabels[count].textAlignment = .Center
            self.view.addSubview(pagesPerDayLabels[count])
            
            count++
        }
        refreshBarGraphs(barGraphStartIndex)
    }
    
    func createLabels(){
        let screenWidth = view.frame.size.width
        let screenHeight = self.view.frame.size.height
        let bottomOffset = screenHeight*0.07
        let offset = screenWidth*0.115
        let dayLabelbuttonHeight = 20.0 as CGFloat
        let dayLabelbuttonWidth = screenWidth*0.1
        let distanceBetweenBars = screenWidth*0.14
        var count = 0
        while(count < 10){
            dayLabelButtons.append(UIButton(frame: CGRectMake(offset + (CGFloat(count))*distanceBetweenBars , screenHeight - dayLabelbuttonHeight - bottomOffset, dayLabelbuttonWidth, dayLabelbuttonHeight)))
            //dayLabelButtons[count].settit .textAlignment = .Center
            dayLabelButtons[count].titleLabel?.font = UIFont.systemFontOfSize(18.0)
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