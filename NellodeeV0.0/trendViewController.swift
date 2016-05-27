//
//  trendViewController.swift
//  NellodeeV0.0
//
//  Created by ahmed moussa on 11/14/15.
//  Copyright © 2015 ahmed moussa. All rights reserved.
//
// The trendViewController controls the contents and functionalities of the trend page

import UIKit

class trendViewController: UIViewController {
    
    let dateFormatter = NSDateFormatter()
    
    var barButtons = [UIButton]()
    var barButtons2 = [UIButton]()
    var pageLabelButtons = [UIButton]()
    var dayLabelButtons = [UIButton]()
    
    var timeAtPageLabels = [UILabel]()
    var pagesPerDayLabels = [UILabel]()
    
    var topPrevButton = UIButton()
    var bottomPrevButton = UIButton()
    var topNextButton = UIButton()
    var bottomNextButton = UIButton()
    
    var topI = 1 //initiating index of starting date in top bar graph
    var bottomI = 1 //initiating index of starting page in bottom bar graph
    
    var daysToDisplay = [day]()
    var indexAtTodaysDate = 0
    
    let timeSpentPerDay = [Int]()
    
    //scale variables
    let topButtonIncrements = 0.0001167 as CGFloat
    let bottomButtonIncrements = 0.00035 as CGFloat //(0.5% to be multiplies by screenHeight)
    let topGraphXaxisHeight = 0.5 as CGFloat//(50% to be multiplies by screenHeight)
    let bottomGraphXaxisHeight = 0.9 as CGFloat//(90% to be multiplies by screenHeight)
    
    //colors
    let NellodeeMaroonColor = UIColor(red: 102/255, green: 51/255, blue: 51/255, alpha: 1)
    let NellodeeMidGray = UIColor(red: 153/255, green: 153/255, blue: 153/255, alpha: 1)
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        dateFormatter.dateStyle = NSDateFormatterStyle.ShortStyle
        
        daysToDisplay = glblLog.currentSession.previousDays
        for temp in glblLog.currentSession.days{
            daysToDisplay.append(temp)
        }
        
        if(glblLog.maxPageReached<=9){
            bottomI = 1
        }
        else{
            bottomI = glblLog.maxPageReached - 5
        }
        if(daysToDisplay.count <= 6){
            topI = 1
        }
        else{
            topI = glblLog.currentSession.previousDays.count
        }
        
    }
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        let screenWidth = view.frame.size.width
        let screenHeight = self.view.frame.size.height
        
        //let navBar: UINavigationBar = UINavigationBar(frame: CGRect(x:0, y:0, width:screenWidth, height:screenHeight/15))
        //navBar.backItem?.title = "back"
        //navBar.backItem?.
        //self.view.addSubview(navBar)
        //let b = UIBarButtonItem(title: "back", style: UIBarButtonItemStyle.Plain, target: self, action: nil)
        //navBar.
        //self.navigationItem.leftBarButtonItem = b
        
        createBarGraphs()
        createLines()
        createPrevAndNextButtons()
    }
    
    func buttonAction(sender: UIButton){
        
        if(sender == self.bottomPrevButton){
            //print("bottomPrevButton CLICKED")
            if(bottomI>0){
                refreshBottomBarGraphs(--bottomI)
            }
            
        }
        if(sender == self.bottomNextButton){
            //print("bottomNextButton CLICKED")
            if(bottomI<=glblLog.maxPageReached - 6){
                refreshBottomBarGraphs(++bottomI)
            }
        }
        if(sender == self.topPrevButton){
            //print("TOPPrevButton CLICKED")
            if(topI>0){
                refreshTopBarGraphs(--topI)
            }
        }
        if(sender == self.topNextButton){
            //print("TOPNextButton CLICKED")
            if(topI<glblLog.currentSession.days.count - 6){
                refreshTopBarGraphs(++topI)
            }
        }
        
    }
    func refreshTopBarGraphs(i: Int){
        let screenWidth = view.frame.size.width
        let screenHeight = self.view.frame.size.height
        
        let buttonWidth = screenWidth*0.06
        var buttonHeight = 10.0 as CGFloat
        let labelButtonWidth = screenWidth*0.12
        let labelButtonHeight = 20.0 as CGFloat
        let distanceBetweenBars = screenWidth*0.14
        var count = 0
        var index = 0.0 as CGFloat
        var indexTime = i
        //for loop populuting array of buttons for bar graph
        //for indexTime in glblLog.timeAtPageIndex{
        while(indexTime>=0 && indexTime < daysToDisplay.count && count < 6){
            buttonHeight = topButtonIncrements*screenHeight * CGFloat(daysToDisplay[indexTime].time)
            if(buttonHeight > screenHeight*0.3){
                buttonHeight = screenHeight*0.3
            }
            barButtons2[count].frame = CGRectMake(115 + (index)*distanceBetweenBars , screenHeight/2 - buttonHeight, buttonWidth, buttonHeight)
            
            dayLabelButtons[count].frame = CGRectMake(115 + (index)*distanceBetweenBars - labelButtonWidth/4, screenHeight/2 + labelButtonHeight/2, labelButtonWidth, labelButtonHeight)
            dayLabelButtons[count].setAttributedTitle(getDateAttributedString(daysToDisplay[indexTime].date), forState: UIControlState.Normal)
            
            dayLabelButtons[count].setTitleColor(NellodeeMidGray, forState: UIControlState.Normal)
            barButtons2[count].backgroundColor = NellodeeMidGray
            
            if (daysToDisplay[indexTime].date == dateFormatter.stringFromDate(NSDate())){
                //dayLabelButtons[count].setTitle("today", forState: UIControlState.Normal)
                //dayLabelButtons[count].setTitleColor(NellodeeMaroonColor, forState: UIControlState.Normal)
                barButtons2[count].backgroundColor = NellodeeMaroonColor
            }
            
            pagesPerDayLabels[count].frame = CGRectMake(115 + (index)*distanceBetweenBars , screenHeight/2 - buttonHeight, buttonWidth, 20)
            if(daysToDisplay[indexTime].time/60>0){
                pagesPerDayLabels[count].text = "\(daysToDisplay[indexTime].time/60 ).\((daysToDisplay[indexTime].time%60)*10/60)"
            }
            else{
                pagesPerDayLabels[count].text = "\(daysToDisplay[indexTime].time)s"
            }
            
            index++
            count++
            indexTime++
        }
        /*
        indexTime--
        count--
        while(indexTime>=0 && indexTime<daysToDisplay.count && count >= 0){
            //------------------------------ TODAY Label ----------------------------------------------
            var thisDate = "whatever"
            if(indexTime < daysToDisplay.count){
                thisDate = daysToDisplay[indexTime].date
            }
            /*if(indexTime > indexAtTodaysDate){
             dayLabelButtons[count].setTitleColor(NellodeeMaroonColor, forState: UIControlState.Normal)
             barButtons2[count].backgroundColor = NellodeeMaroonColor
             }
             else{*/
            dayLabelButtons[count].setTitleColor(NellodeeMidGray, forState: UIControlState.Normal)
            barButtons2[count].backgroundColor = NellodeeMidGray
            //}
            
            if(indexAtTodaysDate == 0 && thisDate == daysToDisplay[glblLog.currentSession.numberOfDaysPassed + glblLog.currentSession.previousDays.count].date){
                indexAtTodaysDate = indexTime
                dayLabelButtons[count].setTitle("today", forState: UIControlState.Normal)
                dayLabelButtons[count].setTitleColor(NellodeeMaroonColor, forState: UIControlState.Normal)
                barButtons2[count].backgroundColor = NellodeeMaroonColor
            }
            else if (indexTime == indexAtTodaysDate){
                dayLabelButtons[count].setTitle("today", forState: UIControlState.Normal)
                dayLabelButtons[count].setTitleColor(NellodeeMaroonColor, forState: UIControlState.Normal)
                barButtons2[count].backgroundColor = NellodeeMaroonColor
            }
            else{
                let calendar = NSCalendar.currentCalendar()
                let components = calendar.components([.Day , .Month , .Year], fromDate: dateFormatter.dateFromString(daysToDisplay[indexTime].date)!)
                let month = components.month
                let day = components.day
                let attrs = [NSFontAttributeName : UIFont.systemFontOfSize(20)]
                let title = NSAttributedString(string: "\(month)/\(day)", attributes: attrs)
                dayLabelButtons[count].setAttributedTitle(title, forState: UIControlState.Normal)
            }
            //------------------------------ TODAY Label ----------------------------------------------
            count--
            indexTime--
        }*/
    }
    func getDateAttributedString(date: String) -> NSAttributedString{
        let calendar = NSCalendar.currentCalendar()
        let components = calendar.components([.Day , .Month , .Year], fromDate: dateFormatter.dateFromString(date)!)
        let month = components.month
        let day = components.day
        let attrs = [NSFontAttributeName : UIFont.systemFontOfSize(20)]
        var title = NSAttributedString(string: "\(month)/\(day)", attributes: attrs)
        if(date == dateFormatter.stringFromDate(NSDate())){
            let attrs = [NSFontAttributeName : UIFont.boldSystemFontOfSize(21), NSForegroundColorAttributeName : NellodeeMaroonColor]
            title = NSAttributedString(string: "today", attributes: attrs)
        }
        return title
    }
    func refreshBottomBarGraphs(i: Int){
        let screenWidth = view.frame.size.width
        let screenHeight = self.view.frame.size.height
        
        let buttonWidth = screenWidth*0.055
        var buttonHeight = 10.0 as CGFloat
        let labelButtonWidth = screenWidth*0.055
        let labelButtonHeight = 30.0 as CGFloat
        let distanceBetweenBars = screenWidth*0.14
        var count = 0
        var index = 0.0 as CGFloat
        var indexTime = i
        //for loop populuting array of buttons for bar graph
        //for indexTime in glblLog.timeAtPageIndex{
        while(indexTime <= glblLog.maxPageReached && count < 6){
            
            
            buttonHeight = 0
            
            buttonHeight = bottomButtonIncrements*screenHeight * CGFloat(glblLog.timeAtPageIndex[indexTime])
            if(buttonHeight > screenHeight*0.25){
                buttonHeight = screenHeight*0.25
            }
            barButtons[count].frame = CGRectMake(110 + (index)*distanceBetweenBars , screenHeight*bottomGraphXaxisHeight - buttonHeight, buttonWidth, buttonHeight)
            
            timeAtPageLabels[count].frame = CGRectMake(110 + (index)*distanceBetweenBars , screenHeight*bottomGraphXaxisHeight - buttonHeight, buttonWidth, labelButtonHeight)
            if(glblLog.timeAtPageIndex[indexTime]/60>0){
                timeAtPageLabels[count].text = "\(glblLog.timeAtPageIndex[indexTime]/60).\((glblLog.timeAtPageIndex[indexTime]%60)*10/60)"
            }
            else{
                timeAtPageLabels[count].text = "\(glblLog.timeAtPageIndex[indexTime])s"
            }
            pageLabelButtons[count].frame = CGRectMake(110 + (index)*distanceBetweenBars , screenHeight*bottomGraphXaxisHeight, labelButtonWidth, labelButtonHeight)
            pageLabelButtons[count].setTitle("\(indexTime)", forState: UIControlState.Normal)
            
            if(count == 5 && indexTime == glblLog.maxPageReached){
                //pageLabelButtons[count].setTitleColor(NellodeeMaroonColor, forState: UIControlState.Normal)
                let attrs = [NSFontAttributeName : UIFont.boldSystemFontOfSize(21), NSForegroundColorAttributeName : NellodeeMaroonColor]
                let title = NSAttributedString(string: "\(indexTime)", attributes: attrs)
                pageLabelButtons[count].setAttributedTitle(title, forState: UIControlState.Normal)
                
                barButtons[count].backgroundColor = NellodeeMaroonColor
            }
            else if(count == 5){
                //pageLabelButtons[count].setTitleColor(NellodeeMidGray, forState: UIControlState.Normal)
                let attrs = [NSFontAttributeName : UIFont.systemFontOfSize(20), NSForegroundColorAttributeName : UIColor.blackColor()]
                let title = NSAttributedString(string: "\(indexTime)", attributes: attrs)
                pageLabelButtons[count].setAttributedTitle(title, forState: UIControlState.Normal)
                barButtons[count].backgroundColor = NellodeeMidGray
            }
            
            index++
            count++
            indexTime++
        }
    }
    
    func createBarGraphs(){
        var count = 0
        
        while(count < 6){
            barButtons.append(UIButton())
            barButtons[count].backgroundColor = NellodeeMidGray
            self.view.addSubview(barButtons[count])
            
            timeAtPageLabels.append(UILabel())
            timeAtPageLabels[count].textColor = UIColor.whiteColor()
            timeAtPageLabels[count].textAlignment = .Center
            self.view.addSubview(timeAtPageLabels[count])
            
            barButtons2.append(UIButton())
            barButtons2[count].backgroundColor = NellodeeMidGray
            self.view.addSubview(barButtons2[count])
            
            
            pagesPerDayLabels.append(UILabel())
            pagesPerDayLabels[count].textColor = UIColor.whiteColor()
            pagesPerDayLabels[count].textAlignment = .Center
            self.view.addSubview(pagesPerDayLabels[count])
            
            pageLabelButtons.append(UIButton())
            pageLabelButtons[count].setTitleColor(UIColor.blackColor(), forState: UIControlState.Normal)
            self.view.addSubview(pageLabelButtons[count])
            
            dayLabelButtons.append(UIButton())
            dayLabelButtons[count].setTitleColor(UIColor.blackColor(), forState: UIControlState.Normal)
            dayLabelButtons[count].titleLabel?.font = UIFont.systemFontOfSize(20)
            self.view.addSubview(dayLabelButtons[count++])
            
        }
        refreshBottomBarGraphs(bottomI)
        refreshTopBarGraphs(topI)
        
    }
    
    func createLines(){
        let screenWidth = view.frame.size.width
        let screenHeight = self.view.frame.size.height
        
        let scaleLineHeight1 = screenHeight*0.7
        let scaleLineHeight2 = screenHeight*0.8
        let scaleLineHeight3 = screenHeight*0.4
        let scaleLineHeight4 = screenHeight*0.3
        
        let scaleLine1 = UIView.init(frame: CGRectMake(100, scaleLineHeight1, screenWidth, 2))
        scaleLine1.backgroundColor = UIColor.grayColor()
        self.view.addSubview(scaleLine1)
        
        let scaleLine2 = UIView.init(frame: CGRectMake(100, scaleLineHeight2, screenWidth, 2))
        scaleLine2.backgroundColor = UIColor.grayColor()
        self.view.addSubview(scaleLine2)
        
        let scaleLine3 = UIView.init(frame: CGRectMake(100, scaleLineHeight3, screenWidth, 2))
        scaleLine3.backgroundColor = UIColor.grayColor()
        self.view.addSubview(scaleLine3)
        
        let scaleLine4 = UIView.init(frame: CGRectMake(100, scaleLineHeight4, screenWidth, 2))
        scaleLine4.backgroundColor = UIColor.grayColor()
        self.view.addSubview(scaleLine4)
        
        let scaleLabel1 = UILabel(frame: CGRectMake(20, scaleLineHeight1 - 15, 60, 30))
        scaleLabel1.text = "10 min"
        self.view.addSubview(scaleLabel1)
        
        let scaleLabel2 = UILabel(frame: CGRectMake(20, scaleLineHeight2 - 15, 60, 30))
        scaleLabel2.text = "5 min"
        self.view.addSubview(scaleLabel2)
        
        let scaleLabel3 = UILabel(frame: CGRectMake(20, scaleLineHeight3 - 15, 60, 30))
        scaleLabel3.text = "15 min"
        self.view.addSubview(scaleLabel3)
        
        let scaleLabel4 = UILabel(frame: CGRectMake(20, scaleLineHeight4 - 15, 60, 30))
        scaleLabel4.text = "30 min"
        self.view.addSubview(scaleLabel4)
        
        let lineViewX = UIView.init(frame: CGRectMake(100, screenHeight*bottomGraphXaxisHeight , screenWidth, 2))
        lineViewX.backgroundColor = UIColor.blackColor()
        self.view.addSubview(lineViewX)
        
        let lineViewX2 = UIView.init(frame: CGRectMake(100, screenHeight/2, screenWidth, 2))
        lineViewX2.backgroundColor = UIColor.blackColor()
        self.view.addSubview(lineViewX2)
        
        
        let YlineHeight = screenHeight*0.3
        
        let topLineViewY = UIView.init(frame: CGRectMake(100, screenHeight - YlineHeight - 100, 2, YlineHeight))
        topLineViewY.backgroundColor = UIColor.blackColor()
        self.view.addSubview(topLineViewY)
        
        let bottomLineViewY = UIView.init(frame: CGRectMake(100, screenHeight - YlineHeight*2.33 - 100, 2, YlineHeight))
        bottomLineViewY.backgroundColor = UIColor.blackColor()
        self.view.addSubview(bottomLineViewY)
    }
    func createPrevAndNextButtons(){
        let screenWidth = view.frame.size.width
        let screenHeight = self.view.frame.size.height
        
        let prevButtonX = screenWidth*8/10
        let nextButtonX = screenWidth*9/10
        let topYs = screenHeight*0.53
        let bottomYs = screenHeight*0.93
        
        let buttonWidth = screenWidth/25 as CGFloat
        print(screenHeight)
        print(buttonWidth)
        
        self.topPrevButton = UIButton(frame: CGRectMake(prevButtonX, topYs, buttonWidth, buttonWidth))
        topPrevButton.setBackgroundImage(UIImage(named: "leftArrow.jpg"), forState: UIControlState.Normal)
        topPrevButton.addTarget(self, action: "buttonAction:", forControlEvents: UIControlEvents.TouchUpInside)
        self.view.addSubview(topPrevButton)
        
        self.topNextButton = UIButton(frame: CGRectMake(nextButtonX , topYs, buttonWidth, buttonWidth))
        topNextButton.setBackgroundImage(UIImage(named: "rightArrow.jpg"), forState: UIControlState.Normal)
        topNextButton.addTarget(self, action: "buttonAction:", forControlEvents: UIControlEvents.TouchUpInside)
        self.view.addSubview(topNextButton)
        
        self.bottomPrevButton = UIButton(frame: CGRectMake(prevButtonX, bottomYs, buttonWidth, buttonWidth))
        bottomPrevButton.setBackgroundImage(UIImage(named: "leftArrow.jpg"), forState: UIControlState.Normal)
        bottomPrevButton.addTarget(self, action: "buttonAction:", forControlEvents: UIControlEvents.TouchUpInside)
        self.view.addSubview(bottomPrevButton)
        
        self.bottomNextButton = UIButton(frame: CGRectMake(nextButtonX , bottomYs, buttonWidth, buttonWidth))
        bottomNextButton.setBackgroundImage(UIImage(named: "rightArrow.jpg"), forState: UIControlState.Normal)
        bottomNextButton.addTarget(self, action: "buttonAction:", forControlEvents: UIControlEvents.TouchUpInside)
        self.view.addSubview(bottomNextButton)
    }
    
}
