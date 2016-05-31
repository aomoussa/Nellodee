//
//  goalsViewController.swift
//  NellodeeV0.0
//
//  Created by ahmed moussa on 11/21/15.
//  Copyright © 2015 ahmed moussa. All rights reserved.
//
//
// The goalViewController controls the contents and functionalities of the goals page


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
    
    //colors
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
    
    // sessionDataToString is a small function that returns a short description of the goals of a session (for json writing)
    func sessionDataToString(session1: session)->String {
        if(session1.state == "pagesPerDayState"){
            return "expected pages per day: \(session1.expectedPagesPerDay)"
        }
        else{
            return "start date: \(session1.startDate) and end date: \(session1.endDate)"
        }
    }
    
    //setChanges is the action function of clicking the setChanges button. If a session has been set, it sets the glblLog.currentSession to the desired session and saves and displays accordingly.
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
        //performSegueWithIdentifier("reloadGoals", sender: self) //uncomment if reloading the view entirely is desired (currently unnecessary)
        }
    }
    
    
    @IBOutlet var datePicker: UIDatePicker!
    var currentState = "date"//"pages"
    
    //Handles changes in the pages selector, Creates a new instance of the class type "session" for every edit of the pagesSelector and saves it in "goalSession" to be finally in utilisation when the setchanges button is clicked
    @IBAction func pagesSelectorEdited(sender: UIStepper) {
        setBoxesForState("pagesPerDay")//changes colors of the boxes.
        
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
        // This adds the previous days of the session to the same array as the current one just for display purposes
        displaySession = glblLog.currentSession
        daysToDisplay = displaySession.previousDays
        for temp in displaySession.days{
            daysToDisplay.append(temp)
        }
        //----------------------------multiple session display array creation--------------------end
        print("displaySession.previousDays.count \(displaySession.previousDays.count)")
        print("------------ IN GOALS VIEW! CURRENT SESSION: \n \(glblLog.currentSession.toString())")
        barGraphStartIndex = 0 //change to displaySession.previousDays.count - 3 (if possible) to show todays date in the middle with some previous dates to the left
        /*
        if(displaySession.previousDays.count + displaySession.numberOfDaysPassed > 5){
            barGraphStartIndex = displaySession.previousDays.count + displaySession.numberOfDaysPassed - 5
            if(barGraphStartIndex > daysToDisplay.count - 5){
                barGraphStartIndex = daysToDisplay.count - 5
            }
            
        }*/ // previously working code for making the start day of the top section be todays date. I suggest - 3 (instead of 5) to make the current day in the middle.
    }
    
    //Handles changes in the date picker, Creates a new instance of the class type "session" for every different date selected and saves it in "goalSession" to be finally in utilisation when the setchanges button is clicked
    func datePickerChanged(){
        setBoxesForState("endDate")//changes colors of the boxes.
        
        let strDate = dateFormatter.stringFromDate(datePicker.date)
        let unit:NSCalendarUnit = NSCalendarUnit.Day
        let comps = NSCalendar.currentCalendar().components(unit, fromDate: NSDate(), toDate: datePicker.date, options: [])
        
        if(comps.day > 0 && glblLog.numberOfPages > 0){
            goalSession = session(endDate: strDate, expectedPagesPerDay: (glblLog.numberOfPages-glblLog.maxPageReached) / (comps.day + 1) , state: "completionDateState")
            sessionSet = true
        }
        else{
            print("date edit failed ")
        }
    }
    
    //called when view appears, calls on the creation of some UI views
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        createLines()
        createBoxes()
        createPrevAndNextButtons()
        createLabels()
        createBarGraphs()
        
        //set initial colors of the boxes
        if(glblLog.currentSession.state == "pagesPerDayState"){
            setBoxesForState("pagesPerDay")
        }
        else{
            setBoxesForState("endDate")
        }
    }
    
    //handles clickeing the next and previous buttons (just increments/decrements the "barGraphStartIndex" and refreshes)
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
    
    //handles changing the color of the boxes as desired.. accepts a string specifying the state.
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
    
    //creates lines and scales of bar graph
    func createLines(){
        
        let screenWidth = view.frame.size.width
        let screenHeight = self.view.frame.size.height
        let buttonIncrements = screenHeight*0.007
        let YlineHeight = screenHeight*0.35
        let bottomOffset = screenWidth*0.13
        let linesOffset = screenWidth*0.12
        let labelWidth = screenWidth*0.1
        
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
    
    //resets the heights and label numbers of the bars. accepts an int which specifies where the starting point is in the array "daysToDisplay"
    func refreshBarGraphs(i: Int){
        
        let screenWidth = view.frame.size.width
        let screenHeight = self.view.frame.size.height
        let offset = screenWidth*0.14
        let bottomOffset = screenHeight*0.1
        let distanceBetweenBars = screenWidth*0.14
        let buttonIncrements = screenHeight*0.007 //the equivalent height representing one day //increase or decrease to change the heights of the bars
        var count = 0
        var index = 0.0 as CGFloat
        
        //loop setting attributes of array of buttons for bar graph
        var indexPage = i
        while(count < 6){
            if(indexPage>=0 && indexPage < daysToDisplay.count){
                
                let barWidth = screenWidth*0.05
                var barHeight = 10.0 as CGFloat //initial height of all the bars.. // maybe makes more sense to initiate to 0
                
                if(daysToDisplay[indexPage].expectedPages>=0){
                    barHeight = CGFloat(daysToDisplay[indexPage].expectedPages) * buttonIncrements
                }
                if(barHeight > screenHeight*0.375){
                    barHeight = screenHeight*0.375
                }
                bars[count].frame = CGRectMake(offset + (index)*distanceBetweenBars , screenHeight-barHeight - bottomOffset, barWidth, barHeight)
                
                expectedPagesPerDayLabels[count].frame = CGRectMake(offset + (index)*distanceBetweenBars , screenHeight-barHeight - bottomOffset, barWidth, 20)
                if(count <= daysToDisplay.count && daysToDisplay[indexPage].pages.count <= 0 && daysToDisplay[indexPage].expectedPages > 1){
                    expectedPagesPerDayLabels[count].text = "\(daysToDisplay[indexPage].expectedPages)"
                }
                else{
                    expectedPagesPerDayLabels[count].text = ""
                }
                
                
                var barHeight2 = 0.0 as CGFloat
                if(daysToDisplay[indexPage].pages.count>=0){
                    barHeight2 = CGFloat(daysToDisplay[indexPage].pages.count) * buttonIncrements
                }
                if(barHeight2 > screenHeight*0.4){
                    barHeight2 = screenHeight*0.4
                }
                let expectedBarsXs = offset + (index)*distanceBetweenBars + barWidth*0.75
                expectedBars[count].frame = CGRectMake(expectedBarsXs , screenHeight-barHeight2 - bottomOffset, barWidth, barHeight2)
                pagesPerDayLabels[count].frame = CGRectMake(expectedBarsXs , screenHeight-barHeight2 - bottomOffset, barWidth, 20)
                if(daysToDisplay[indexPage].pages.count>1){
                    pagesPerDayLabels[count].text = "\(daysToDisplay[indexPage].pages.count)"
                }
                else{
                    pagesPerDayLabels[count].text = ""
                }
                
                //------------------------------ TODAY Label ----------------------------------------------
                let thisDate = dateFormatter.stringFromDate(NSDate())
                
                if(daysToDisplay[indexPage].date == thisDate){
                    let attrs = [NSFontAttributeName : UIFont.boldSystemFontOfSize(21), NSForegroundColorAttributeName : NellodeeMaroonColor]
                    let title = NSAttributedString(string: "today", attributes: attrs)
                    dayLabelButtons[count].setAttributedTitle(title, forState: UIControlState.Normal)
                }
                else{
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
    
    //creates an array of 6 bars and 6 expectedBars (type: UIButton) as well as the labels of the bars
    func createBarGraphs(){
        var count = 0
        //for loop populating array of buttons for bar graph
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
    
    //creates an array of 6 labels for the buttom of the bars (displays the dates or "today")
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