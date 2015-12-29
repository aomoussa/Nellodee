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
    
    //UI stuff
    var bottomPrevButton = UIButton()
    var bottomNextButton = UIButton()
    var bars = [UIButton]()
    var expectedBars = [UIButton]()
    var dayLabelButtons = [UIButton]()
    var pagesPerDayLabels = [UILabel]()
    var expectedPagesPerDayLabels = [UILabel]()
    var pagesPerDayStateLabel = UILabel()
    var completionDayStateLabel = UILabel()
    
    
    @IBAction func setChanges(sender: UIButton) {
        glblLog.addSession(goalSession)
        print(glblLog.currentSession.toString())
        refreshBarGraphs(0)
    }
    @IBOutlet var nextButton: UIButton!
    @IBOutlet var prevButton: UIButton!
    
    
    @IBOutlet var datePicker: UIDatePicker!
    var currentState = "date"//"pages"
    
    @IBAction func pagesSelectorEdited(sender: UIStepper) {
        currentState = "pages"
        
        currentStateLabel.text = currentState
        
        let pagesPerDay = Int(sender.value).description
        pagesSelectorLabel.text = pagesPerDay
        
        self.view.addSubview(pagesPerDayStateLabel)
        completionDayStateLabel.removeFromSuperview()
        
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
        print(goalSession.toString())
        
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
        currentStateLabel.text = currentState
        self.view.addSubview(completionDayStateLabel)
        pagesPerDayStateLabel.removeFromSuperview()
        
        let strDate = dateFormatter.stringFromDate(datePicker.date)
        print(strDate)
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
            print("bottomPrevButton CLICKED")
            if(barGraphStartIndex > 0){
                print(dayLabelButtons.count)
                print(barGraphStartIndex--)
                refreshBarGraphs(barGraphStartIndex)
            }
            
        }
        if(sender == self.bottomNextButton){
            print("bottomNextButton CLICKED")
            if(glblLog.currentSession.days.count >= barGraphStartIndex + 10){
                
                print(expectedBars.count)
                print(barGraphStartIndex++)
                refreshBarGraphs(barGraphStartIndex)
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
            if(indexPage < glblLog.currentSession.days.count){
                
                let buttonWidth = 20.0 as CGFloat
                var buttonHeight = 10.0 as CGFloat
                //var buttonHeight2 = 10.0 as CGFloat
                let dayLabelbuttonHeight = 20.0 as CGFloat
                let dayLabelbuttonWidth = buttonWidth*3
                
                
                buttonHeight = CGFloat(glblLog.currentSession.days[indexPage].expectedPages) * CGFloat(15)
                if(buttonHeight > screenHeight*0.5){
                    buttonHeight = screenHeight*0.5
                }
                bars[count].frame = CGRectMake(70 + (index)*70.0 , screenHeight-buttonHeight - 100, buttonWidth, buttonHeight)
                
                expectedPagesPerDayLabels[count].frame = CGRectMake(70 + (index)*70.0 , screenHeight-buttonHeight - 120, buttonWidth*2, 20)
                if(count < glblLog.currentSession.expectedNumOfDays){
                    expectedPagesPerDayLabels[count].text = "\(glblLog.currentSession.days[indexPage].expectedPages)"
                }
                else{
                    expectedPagesPerDayLabels[count].text = "0"
                }
                
                
                var buttonHeight2 = 0.0 as CGFloat
                buttonHeight2 = CGFloat(glblLog.currentSession.days[indexPage].pages.count) * CGFloat(15)
                if(buttonHeight2 > screenHeight*0.5){
                    buttonHeight2 = screenHeight*0.5
                }
                expectedBars[count].frame = CGRectMake(45 + (index)*70.0 , screenHeight-buttonHeight2 - 100, buttonWidth, buttonHeight2)
                
                pagesPerDayLabels[count].frame = CGRectMake(45 + (index)*70.0 , screenHeight-buttonHeight2 - 120, buttonWidth*2, 20)
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
        refreshBarGraphs(0)
    }
    
    func createLabels(){
        //let screenWidth = view.frame.size.width
        let screenHeight = self.view.frame.size.height
        let dayLabelbuttonHeight = 20.0 as CGFloat
        let dayLabelbuttonWidth = dayLabelbuttonHeight*3
        
        var count = 0
        while(count < 10){
            dayLabelButtons.append(UIButton(frame: CGRectMake(40 + (CGFloat(count))*70.0 , screenHeight - dayLabelbuttonHeight - 75, dayLabelbuttonWidth, dayLabelbuttonHeight)))
            dayLabelButtons[count].backgroundColor = UIColor.grayColor()
            self.view.addSubview(dayLabelButtons[count])
            count++
        }
        
    }
    override func viewDidDisappear(animated: Bool) {
        
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
        var pagesReadAtIndexPage = [[String]]()
        var i = 0
        var j = 0
        for temp in glblLog.currentSession.days{
            startPagesString.append("\(temp.startPage)")
            endPagesString.append("\(temp.endPage)")
            timeOnDay.append("\(temp.time)")
            pagesReadAtIndexPage.append([String]())
            for tempPage in temp.pages{
                
                pagesReadAtIndexPage[i].append("\(tempPage.pageNumber)")
                j++
            }
            defaults.setObject(pagesReadAtIndexPage[i], forKey: "actualPagesPerDay\(i)")
            i++
        }
        defaults.setObject(timeOnDay, forKey: "timePerDay")
        defaults.setObject(startPagesString, forKey: "startPagesStringArray")
        defaults.setObject(endPagesString, forKey: "endPagesStringArray")
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
/*
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
defaults.setObject(glblLog.startDate, forKey: "startDate")
defaults.setObject(glblLog.finishDate, forKey: "finishDate")
defaults.setObject(glblLog.daysRead, forKey: "daysRead")

defaults.setObject(glblLog.actualPagesPerDay.count, forKey: "actualPagesPerDay.count")
var i = 0
for temp in glblLog.actualPagesPerDay{
let stringArray3 = temp.map({
(number: Int) -> String in
return String(number)
})
defaults.setObject(stringArray3, forKey: "actualPagesPerDay\(i++)")
}


}
*/
/*
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

*/
