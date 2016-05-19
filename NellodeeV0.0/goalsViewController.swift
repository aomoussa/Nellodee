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
    var sessionSet = false
    let defaults = NSUserDefaults.standardUserDefaults()
    let dateFormatter = NSDateFormatter()
    var goalSession = session()
    var barGraphStartIndex = 0
    var displaySession = session()
    var daysToDisplay = [day]()
    var indexAtTodaysDate = 0
    let NellodeeMaroonColor = UIColor(red: 102/255, green: 51/255, blue: 51/255, alpha: 1)
    let NellodeeMidGray = UIColor(red: 51/255, green: 51/255, blue: 51/255, alpha: 1)
    let NellodeeLightGray = UIColor(red: 221/255, green: 221/255, blue: 221/255, alpha: 1)
    
    
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
    
    func sessionDataToString(session1: session)->String {
        if(session1.state == "pagesPerDayState"){
            return "expected pages per day: \(session1.expectedPagesPerDay)"
        }
        else{
            return "start date: \(session1.startDate) and end date: \(session1.endDate)"
        }
    }
    
    @IBAction func setChanges(sender: UIButton) {
        if(sessionSet){
        jsonLogger.writeGoalChangesSet(sessionDataToString(glblLog.currentSession), fromType: glblLog.currentSession.state, to: sessionDataToString(goalSession), toType: goalSession.state)
        
        glblLog.maxPageReached = glblLog.currentPageNumber
        glblLog.addSession(goalSession)
        displaySession = glblLog.currentSession
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
        goalSession = session(endDate: finishDate, expectedPagesPerDay: expectedPagesPerDay, state: "pagesPerDayState")
        sessionSet = true
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
        
        
        
        
        
        //----------------------------multiple session display array creation--------------------begin
        displaySession = glblLog.currentSession
        daysToDisplay = displaySession.previousDays
        for temp in displaySession.days{
            daysToDisplay.append(temp)
        }
        
        //----------------------------multiple session display array creation--------------------end
        print("displaySession.previousDays.count \(displaySession.previousDays.count)")
        print("------------ IN GOALS VIEW! CURRENT SESSION: \n \(glblLog.currentSession.toString())")
        barGraphStartIndex = 0
        /*
        if(displaySession.previousDays.count + displaySession.numberOfDaysPassed > 5){
            barGraphStartIndex = displaySession.previousDays.count + displaySession.numberOfDaysPassed - 5
            if(barGraphStartIndex > daysToDisplay.count - 10){
                barGraphStartIndex = daysToDisplay.count - 10
            }
            
        }*/
    }
    
    func datePickerChanged(){
        //segmentedControl.selectedSegmentIndex = 1
        setBoxesForState("endDate")
        
        let strDate = dateFormatter.stringFromDate(datePicker.date)
        let unit:NSCalendarUnit = NSCalendarUnit.Day
        let comps = NSCalendar.currentCalendar().components(unit, fromDate: NSDate(), toDate: datePicker.date, options: [])
        
        if(comps.day > 0 && glblLog.numberOfPages > 0){
            goalSession = session(endDate: strDate, expectedPagesPerDay: (glblLog.numberOfPages-glblLog.maxPageReached) / comps.day, state: "completionDateState")
            sessionSet = true
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
        if(glblLog.currentSession.state == "pagesPerDayState"){
            //segmentedControl.selectedSegmentIndex = 0
            setBoxesForState("pagesPerDay")
        }
        else{
            //segmentedControl.selectedSegmentIndex = 1
            setBoxesForState("endDate")
        }
    }
    func buttonAction(sender: UIButton){
        
        if(sender == self.bottomPrevButton){
            if(barGraphStartIndex > 0){
                barGraphStartIndex--
                refreshBarGraphs(barGraphStartIndex)
            }
        }
        if(sender == self.bottomNextButton){
            if(barGraphStartIndex < daysToDisplay.count - 6){
                barGraphStartIndex++
                refreshBarGraphs(barGraphStartIndex)
            }
        }
    }
    
    func createBoxes(){
        
        let screenWidth = view.frame.size.width
        let screenHeight = self.view.frame.size.height
        let lineWidth = screenWidth*0.008
        let topY = screenHeight*0.14
        let bottomY = screenHeight*0.4
        let leftXBox1 = screenWidth*0.05
        let rightXBox1 = screenWidth*0.5 - lineWidth/2
        let leftXBox2 = screenWidth*0.5 + lineWidth/2
        let rightXBox2 = screenWidth*0.95
        
        //segmentedControl.frame =  CGRectMake(screenWidth/2 - 100 , screenHeight/2 - 250, screenWidth/3, screenHeight/40)
        //self.view.addSubview(segmentedControl)
        leftLineOfBox1.frame = CGRectMake(leftXBox1, topY, lineWidth, bottomY - topY)
        rightLineOfBox1.frame = CGRectMake(rightXBox1, topY, lineWidth, bottomY - topY)
        topLineOfBox1.frame = CGRectMake(leftXBox1, topY, rightXBox1 - leftXBox1, lineWidth)
        bottomLineOfBox1.frame = CGRectMake(leftXBox1, bottomY, rightXBox1 - leftXBox1 + lineWidth, lineWidth)
        
        leftLineOfBox2.frame = CGRectMake(leftXBox2, topY, lineWidth, bottomY - topY)
        rightLineOfBox2.frame = CGRectMake(rightXBox2, topY, lineWidth, bottomY - topY)
        topLineOfBox2.frame = CGRectMake(leftXBox2, topY, rightXBox2 - leftXBox2 , lineWidth)
        bottomLineOfBox2.frame = CGRectMake(leftXBox2, bottomY, rightXBox2 - leftXBox2 + lineWidth, lineWidth)
        
        leftLineOfBox1.backgroundColor = NellodeeLightGray
        rightLineOfBox1.backgroundColor = NellodeeLightGray
        topLineOfBox1.backgroundColor = NellodeeLightGray
        bottomLineOfBox1.backgroundColor = NellodeeLightGray
        
        leftLineOfBox2.backgroundColor = NellodeeLightGray
        rightLineOfBox2.backgroundColor = NellodeeLightGray
        topLineOfBox2.backgroundColor = NellodeeLightGray
        bottomLineOfBox2.backgroundColor = NellodeeLightGray
        
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
        var leftBoxColor = NellodeeLightGray
        var rightBoxColor = NellodeeLightGray
        switch(goalState){
        case "pagesPerDay":
            leftBoxColor = NellodeeMaroonColor
            break
        case "endDate":
            rightBoxColor = NellodeeMaroonColor
            break
        default:
            leftBoxColor = NellodeeMaroonColor
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
        lineViewX.backgroundColor = UIColor.blackColor()
        self.view.addSubview(lineViewX)
        
        let lineViewY = UIView.init(frame: CGRectMake(linesOffset, screenHeight - YlineHeight - 150, 2, YlineHeight + 50))
        lineViewY.backgroundColor = UIColor.blackColor()
        self.view.addSubview(lineViewY)
        
        let scaleLine1 = UIView(frame: CGRectMake(linesOffset, screenHeight - bottomOffset - 15*buttonIncrements, screenWidth, 2))
        scaleLine1.backgroundColor = UIColor.blackColor()
        self.view.addSubview(scaleLine1)
        
        let scaleLine2 = UIView(frame: CGRectMake(linesOffset,  screenHeight - bottomOffset - 30*buttonIncrements, screenWidth, 2))
        scaleLine2.backgroundColor = UIColor.blackColor()
        self.view.addSubview(scaleLine2)
        
        let scaleLine3 = UIView(frame: CGRectMake(linesOffset,  screenHeight - bottomOffset - 50*buttonIncrements, screenWidth, 2))
        scaleLine3.backgroundColor = UIColor.blackColor()
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
                if(buttonHeight > screenHeight*0.375){
                    buttonHeight = screenHeight*0.375
                }
                bars[count].frame = CGRectMake(offset + (index)*distanceBetweenBars , screenHeight-buttonHeight - bottomOffset, buttonWidth, buttonHeight)
                
                expectedPagesPerDayLabels[count].frame = CGRectMake(offset + (index)*distanceBetweenBars , screenHeight-buttonHeight - bottomOffset, buttonWidth, 20)
                if(count <= daysToDisplay.count && daysToDisplay[indexPage].pages.count <= 0 && daysToDisplay[indexPage].expectedPages > 1){
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
                if(daysToDisplay[indexPage].pages.count>1){
                    pagesPerDayLabels[count].text = "\(daysToDisplay[indexPage].pages.count)"
                }
                else{
                    pagesPerDayLabels[count].text = ""
                }
                
                //------------------------------ TODAY Label ----------------------------------------------
                //let thisDate = daysToDisplay[indexPage].date
                let thisDate = dateFormatter.stringFromDate(NSDate())
                
                if(daysToDisplay[indexPage].date == thisDate){
//daysToDisplay.count > displaySession.numberOfDaysPassed + displaySession.previousDays.count && thisDate == daysToDisplay[displaySession.numberOfDaysPassed + displaySession.previousDays.count].date){
                    let attrs = [NSFontAttributeName : UIFont.boldSystemFontOfSize(21), NSForegroundColorAttributeName : NellodeeMaroonColor]
                    let title = NSAttributedString(string: "today", attributes: attrs)
                    //title.add
                    dayLabelButtons[count].setAttributedTitle(title, forState: UIControlState.Normal)
                    //dayLabelButtons[count].setTitleColor(NellodeeMaroonColor, forState: UIControlState.Normal)
                }else{
                    let calendar = NSCalendar.currentCalendar()
                    let components = calendar.components([.Day , .Month , .Year], fromDate: dateFormatter.dateFromString(daysToDisplay[indexPage].date)!)
                    let month = components.month
                    let day = components.day
                    let attrs = [NSFontAttributeName : UIFont.systemFontOfSize(20)]
                    let title = NSAttributedString(string: "\(month)/\(day)", attributes: attrs)
                    dayLabelButtons[count].setAttributedTitle(title, forState: UIControlState.Normal)
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
            
            count += 1
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
        while(count < 6){
            dayLabelButtons.append(UIButton(frame: CGRectMake(offset + (CGFloat(count))*distanceBetweenBars , screenHeight - dayLabelbuttonHeight - bottomOffset, dayLabelbuttonWidth, dayLabelbuttonHeight)))
            //dayLabelButtons[count].settit .textAlignment = .Center
            dayLabelButtons[count].titleLabel?.font = UIFont.systemFontOfSize(18.0)
            self.view.addSubview(dayLabelButtons[count])
            count += 1
        }
        
    }
}