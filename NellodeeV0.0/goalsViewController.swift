//
//  goalsViewController.swift
//  NellodeeV0.0
//
//  Created by ahmed moussa on 11/21/15.
//  Copyright © 2015 ahmed moussa. All rights reserved.
//

import UIKit

class goalsViewController: UIViewController {
    
    let defaults = NSUserDefaults.standardUserDefaults()
    
    var graphsCreated = false
    
    let dateFormatter = NSDateFormatter()
    
    var startPage = 0
    var expectedPagesPerDay = 0
    var numOfDays = 0
    var startDate = ""
    var finishDate = ""
    
    var bottomPrevButton = UIButton()
    var bottomNextButton = UIButton()
    
    var barButtons = [UIButton]()
    var barButtons2 = [UIButton]()
    var dayLabelButtons = [UIButton]()
    var pagesPerDayLabels = [UILabel]()
    var expectedPagesPerDayLabels = [UILabel]()
    var pagesPerDayStateLabel = UILabel()
    var completionDayStateLabel = UILabel()
    var beginButton = 1
    var i = 1
    /*
    @IBAction func reloadButton(sender: UIButton) {
        prepareAndSegue()
    }
    */
    @IBOutlet var nextButton: UIButton!
    @IBOutlet var prevButton: UIButton!
    
    
    @IBOutlet var datePicker: UIDatePicker!
    var currentState = "date"//"pages"
    
    @IBAction func pagesSelectorEdited(sender: UIStepper) {
        currentState = "pages"
        glblLog.currentState = "pagesPerDayState"//"completionDateState"

        currentStateLabel.text = currentState

        let pagesPerDay = Int(sender.value).description
        pagesSelectorLabel.text = pagesPerDay
        
        
        self.view.addSubview(pagesPerDayStateLabel)
        completionDayStateLabel.removeFromSuperview()
        
        
        self.startPage = glblLog.currentPageNumber
        self.expectedPagesPerDay = Int(pagesPerDay)!
        if(self.expectedPagesPerDay > 0 && glblLog.numberOfPages > 0){
            self.numOfDays = glblLog.numberOfPages/self.expectedPagesPerDay
        }
        self.startDate = dateFormatter.stringFromDate(NSDate())
        
        let unit:NSCalendarUnit = NSCalendarUnit.Day
        if #available(iOS 8.0, *) {
            self.finishDate = dateFormatter.stringFromDate(NSCalendar.currentCalendar().dateByAddingUnit(unit, value: self.numOfDays, toDate: NSDate(), options: [])!)
        } else {
            print("device too old... datePicker mess up")
        }
        
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
    }
    
    
    
    func datePickerChanged(){//(datePicker:UIDatePicker) {
        currentState = "date"
        glblLog.currentState = "completionDateState"
        currentStateLabel.text = currentState
        self.view.addSubview(completionDayStateLabel)
        pagesPerDayStateLabel.removeFromSuperview()
        
        //dateFormatter.timeStyle = NSDateFormatterStyle.ShortStyle
        
        let strDate = dateFormatter.stringFromDate(datePicker.date)
        print(strDate)
        let unit:NSCalendarUnit = NSCalendarUnit.Day
        let comps = NSCalendar.currentCalendar().components(unit, fromDate: NSDate(), toDate: datePicker.date, options: [])
        
        
        //strDate = "01/01/16, 11:43 PM"
        //datePicker.date = dateFormatter.dateFromString(strDate)!
        //print(Int(glblLog.numberOfPages / comps.day))
        if(comps.day > 0 && glblLog.numberOfPages > 0){
            self.startPage = glblLog.currentPageNumber
            self.expectedPagesPerDay = glblLog.numberOfPages / comps.day
            self.numOfDays = comps.day
            self.startDate = dateFormatter.stringFromDate(NSDate())
            self.finishDate = strDate
            /*
            glblLog.expectedPagesPerDay = glblLog.numberOfPages / comps.day
            glblLog.setExpectedPagesPerDay(glblLog.expectedPagesPerDay)
            print(comps.day)
            
            glblLog.startPage = glblLog.currentPageNumber
            //glblLog.startDate = dateFormatter.stringFromDate(NSDate())
            //glblLog.finishDate = strDate
            //print(strDate)
            glblLog.numOfDays = comps.day*/
        }
        else{
            print("date edit failed ")
        }
    }
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        createBarGraphs()
        createLines()
        createPrevAndNextButtons()
    }
    func buttonAction(sender: UIButton){
        
        if(sender == self.bottomPrevButton){
            print("bottomPrevButton CLICKED")
            if(i > 1){
                print(dayLabelButtons.count)
                print(i--)
                refreshBarGraphs(i)
            }
            
        }
        if(sender == self.bottomNextButton){
            print("bottomNextButton CLICKED")
            if(glblLog.numOfDays > i + 10){
                
                print(barButtons2.count)
                print(i++)
                refreshBarGraphs(i)
            }
        }
    }
    
    func createLines(){
        
        let screenWidth = view.frame.size.width
        let screenHeight = self.view.frame.size.height
        let YlineHeight = 350.0 as CGFloat
        
        
        completionDayStateLabel.frame = CGRectMake(screenWidth/2 + 100 , screenHeight/2 - 250, screenWidth/3, screenHeight/40)
        completionDayStateLabel.text = "Completion Day State"
        if(glblLog.currentState == "completionDateState"){//"pagesPerDayState"
        self.view.addSubview(completionDayStateLabel)
    }
        pagesPerDayStateLabel.frame = CGRectMake(screenWidth/2  - 300, screenHeight/2 - 250, screenWidth/3, screenHeight/40)
        pagesPerDayStateLabel.text = "Pages Per Day State"
        if(glblLog.currentState == "pagesPerDayState"){//"completionDateState"
        self.view.addSubview(pagesPerDayStateLabel)
        }
        
        let lineViewX = UIView.init(frame: CGRectMake(45, screenHeight - 100, screenWidth, 1))
        lineViewX.backgroundColor = UIColor.blackColor()
        self.view.addSubview(lineViewX)
    
        let lineViewY = UIView.init(frame: CGRectMake(45, screenHeight - YlineHeight - 100, 2, YlineHeight))
        lineViewY.backgroundColor = UIColor.blackColor()
        self.view.addSubview(lineViewY)
        
        let scaleLine1 = UIView(frame: CGRectMake(45, screenHeight - 300, screenWidth, 1))
        scaleLine1.backgroundColor = UIColor.blackColor()
        self.view.addSubview(scaleLine1)
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
    
    func refreshBarGraphs(i: Int){
        
        let screenWidth = view.frame.size.width
        let screenHeight = self.view.frame.size.height
        
        var count = 0
        var index = 0.0 as CGFloat
        //for loop populsting array of buttons for bar graph
        var indexPage = i
        while(count < 10){
            if(indexPage<glblLog.numOfDays){
                
                let buttonWidth = 20.0 as CGFloat
                var buttonHeight = 10.0 as CGFloat
                //var buttonHeight2 = 10.0 as CGFloat
                let dayLabelbuttonHeight = 20.0 as CGFloat
                let dayLabelbuttonWidth = buttonWidth*3
                
                var x = 0
                if(count < glblLog.expectedPagesPerDay1.count){
                    while( x <  glblLog.expectedPagesPerDay1[indexPage] && x < 30){
                        buttonHeight = buttonHeight + 15.0
                        x++
                    }
                }
                x = 0
                
                barButtons[count].frame = CGRectMake(70 + (index)*70.0 , screenHeight-buttonHeight - 100, buttonWidth, buttonHeight)
                
                if(indexPage <= glblLog.actualPagesPerDay.count ){
                    var buttonHeight2 = 0.0 as CGFloat
                    var ih = 0
                    while( ih <  glblLog.actualPagesPerDay[indexPage - 1].count && ih < 30){
                        buttonHeight2 = buttonHeight2 + 15.0
                        ih++
                    }
                    
                    barButtons2[count].frame = CGRectMake(45 + (index)*70.0 , screenHeight-buttonHeight2 - 100, buttonWidth, buttonHeight2)
                    
                    pagesPerDayLabels[count].frame = CGRectMake(45 + (index)*70.0 , screenHeight-buttonHeight2 - 120, buttonWidth*2, 20)
                    pagesPerDayLabels[count].text = "\(glblLog.actualPagesPerDay[indexPage - 1].count)"
                }
                else{
                    barButtons2[count].frame = CGRectMake(45 + (index)*70.0 , screenHeight - 100, buttonWidth, 0)
                    
                    pagesPerDayLabels[count].frame = CGRectMake(45 + (index)*70.0 , screenHeight - 120, buttonWidth*2, 20)
                    pagesPerDayLabels[count].text = "0"
                }
                
                dayLabelButtons[count].frame = CGRectMake(40 + (index++)*70.0 , screenHeight - dayLabelbuttonHeight - 75, dayLabelbuttonWidth, dayLabelbuttonHeight)
                if(indexPage < glblLog.daysRead.count){
                    dayLabelButtons[count].setTitle(glblLog.daysRead[indexPage].substringToIndex(glblLog.daysRead[indexPage].startIndex.advancedBy(5)), forState: UIControlState.Normal)
                }
                else if(indexPage == glblLog.daysRead.count){
                    dayLabelButtons[count].setTitle("today", forState: UIControlState.Normal)
                }
                else{
                    dayLabelButtons[count].setTitle("day \(indexPage)", forState: UIControlState.Normal)
                }
                indexPage++
                count++
            }
        }
        
        
    }
    func createBarGraphs(){
        
        //let screenWidth = view.frame.size.width
        let screenHeight = self.view.frame.size.height
        
        var count = 0
        var index = 0.0 as CGFloat
        //for loop populsting array of buttons for bar graph
        while(count < 10 && count < glblLog.expectedPagesPerDay1.count){
            
            
            let buttonWidth = 20.0 as CGFloat
            var buttonHeight = 10.0 as CGFloat
            //var buttonHeight2 = 10.0 as CGFloat
            let dayLabelbuttonHeight = 20.0 as CGFloat
            let dayLabelbuttonWidth = buttonWidth*3
            
            var x = 0
                while( x <  glblLog.expectedPagesPerDay1[count] && x < 30){
                    buttonHeight = buttonHeight + 15.0
                    x++
                }
            x = 0
            
            
            barButtons.append(UIButton(frame: CGRectMake(70 + (index)*70.0 , screenHeight-buttonHeight - 100, buttonWidth, buttonHeight)))
            barButtons[count].backgroundColor = UIColor.blueColor()
            self.view.addSubview(barButtons[count])
            
            expectedPagesPerDayLabels.append(UILabel(frame: CGRectMake(70 + (index)*70.0 , screenHeight-buttonHeight - 120, buttonWidth*2, 20)))
            if(count < glblLog.expectedPagesPerDay1.count){
                expectedPagesPerDayLabels[count].text = "\(glblLog.expectedPagesPerDay1[count])"
            }
            else{
                expectedPagesPerDayLabels[count].text = "0"
            }
            self.view.addSubview(expectedPagesPerDayLabels[count])
            
            
            if(count + beginButton <= glblLog.actualPagesPerDay.count ){
                var buttonHeight2 = 0.0 as CGFloat
                var i = 0
                while( i <  glblLog.actualPagesPerDay[count + beginButton - 1].count && i < 30){
                    buttonHeight2 = buttonHeight2 + 15.0
                    i++
                }
                barButtons2.append(UIButton(frame: CGRectMake(45 + (index)*70.0 , screenHeight-buttonHeight2 - 100, buttonWidth, buttonHeight2)))
                barButtons2[count].backgroundColor = UIColor.redColor()
                self.view.addSubview(barButtons2[count])
                
                pagesPerDayLabels.append(UILabel(frame: CGRectMake(45 + (index)*70.0 , screenHeight-buttonHeight2 - 120, buttonWidth*2, 20)))
                pagesPerDayLabels[count].text = "\(glblLog.actualPagesPerDay[count + beginButton - 1].count)"
                self.view.addSubview(pagesPerDayLabels[count])
            }
            else{
                barButtons2.append(UIButton(frame: CGRectMake(45 + (index)*70.0 , screenHeight - 100, buttonWidth, 0)))
                barButtons2[count].backgroundColor = UIColor.redColor()
                self.view.addSubview(barButtons2[count])
                
                pagesPerDayLabels.append(UILabel(frame: CGRectMake(45 + (index)*70.0 , screenHeight - 120, buttonWidth*2, 20)))
                pagesPerDayLabels[count].text = "0"
                self.view.addSubview(pagesPerDayLabels[count])
            }
            
            dayLabelButtons.append(UIButton(frame: CGRectMake(40 + (index++)*70.0 , screenHeight - dayLabelbuttonHeight - 75, dayLabelbuttonWidth, dayLabelbuttonHeight)))
            if(count + beginButton < glblLog.daysRead.count){
                dayLabelButtons[count].setTitle(glblLog.daysRead[count + beginButton].substringToIndex(glblLog.daysRead[count + beginButton].startIndex.advancedBy(5)), forState: UIControlState.Normal)
            }
            else if(count + beginButton == glblLog.daysRead.count){
                dayLabelButtons[count].setTitle("today", forState: UIControlState.Normal)
            }
            else{
                dayLabelButtons[count].setTitle("day \(count + beginButton)", forState: UIControlState.Normal)
            }
            dayLabelButtons[count].backgroundColor = UIColor.grayColor()
            
            self.view.addSubview(dayLabelButtons[count++])
            
        }
        
        
    }
    func createLabels(){
        
        let screenWidth = view.frame.size.width
        let screenHeight = self.view.frame.size.height
        let dayLabelbuttonHeight = 20.0 as CGFloat
        let dayLabelbuttonWidth = dayLabelbuttonHeight*3
        
        var count = 0
        var index = 0.0 as CGFloat
        //for loop populsting array of buttons for bar graph
        while(count < 10 && count < glblLog.numOfDays){
            dayLabelButtons.append(UIButton(frame: CGRectMake(40 + (index++)*70.0 , screenHeight - dayLabelbuttonHeight - 75, dayLabelbuttonWidth, dayLabelbuttonHeight)))
            if(count + beginButton < glblLog.daysRead.count){
                dayLabelButtons[count].setTitle(glblLog.daysRead[count + beginButton], forState: UIControlState.Normal)
            }
            else{
                dayLabelButtons[count].setTitle("day \(count + beginButton)", forState: UIControlState.Normal)
            }
            dayLabelButtons[count].backgroundColor = UIColor.grayColor()
            
            self.view.addSubview(dayLabelButtons[count++])
            
        }
        
    }
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if(segue.identifier == "reloadGoals"){
            glblLog.startPage = self.startPage
            glblLog.expectedPagesPerDay = self.expectedPagesPerDay
            glblLog.setExpectedPagesPerDay(glblLog.expectedPagesPerDay)
            glblLog.numOfDays = self.numOfDays
            glblLog.addSession(self.startDate, finishDate: self.finishDate, expectedPagesPerDay: self.expectedPagesPerDay)
            print(glblLog.currentSession.toString())
            //refreshBarGraphs(1)
        }
            //self.performSegueWithIdentifier("reloadGoals", sender: self)
    }
    override func viewDidDisappear(animated: Bool) {
        defaults.setObject(glblLog.currentPageNumber, forKey: "currentPageNumber")
        let stringArray = glblLog.expectedPagesPerDay1.map({
            (number: Int) -> String in
            return String(number)
        })
        defaults.setObject(stringArray, forKey: "expectedPagesPerDay1")
        let stringArray2 = glblLog.timeAtPageIndex.map({
            (number: Int) -> String in
            return String(number)
        })
        defaults.setObject(stringArray2, forKey: "timeAtPageIndex")
        /*
        let stringArray2 = glblLog.actualPagesPerDay.map({
            (number: Int) -> String in
            return String(number)
        })
        defaults.setObject(stringArray2, forKey: "actualPagesPerDay")*/
        defaults.setObject(glblLog.startDate, forKey: "startDate")
        defaults.setObject(glblLog.finishDate, forKey: "finishDate")
        
    }
    
}
/*
@IBAction func nextBar(sender: UIButton) {
if(glblLog.numOfDays > beginButton + 9){
//removeOldBars()
barButtons.removeAll()
barButtons2.removeAll()
dayLabelButtons.removeAll()

print(barButtons2.count)
print(beginButton++)
createBarGraphs()
}
}
@IBAction func prevBar(sender: UIButton) {
if(beginButton > 1){
//removeOldBars()
barButtons.removeAll()
barButtons2.removeAll()
dayLabelButtons.removeAll()
print(dayLabelButtons.count)
print(beginButton--)
createBarGraphs()
}
}*/
