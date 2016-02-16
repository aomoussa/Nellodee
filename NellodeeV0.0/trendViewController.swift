//
//  trendViewController.swift
//  NellodeeV0.0
//
//  Created by ahmed moussa on 11/14/15.
//  Copyright © 2015 ahmed moussa. All rights reserved.
//

import UIKit

class trendViewController: UIViewController {
    
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
    
    var topI = 1//glblLog.currentSession.numberOfDaysPassed - 9
    var bottomI = 1//glblLog.maxPageReached-9
    
    var daysToDisplay = [day]()
    var indexAtTodaysDate = 0
    
    let timeSpentPerDay = [Int]()
    
    //scale variables
    let buttonIncrements = 0.01 as CGFloat //(3% to be multiplies by screenHeight)
    let topGraphXaxisHeight = 0.5 as CGFloat//(50% to be multiplies by screenHeight)
    let bottomGraphXaxisHeight = 0.9 as CGFloat//(90% to be multiplies by screenHeight)
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        daysToDisplay = glblLog.currentSession.previousDays
        for temp in glblLog.currentSession.days{
            daysToDisplay.append(temp)
        }
        
        if(glblLog.maxPageReached<=9){
            bottomI = 1
        }
        else{
            bottomI = glblLog.maxPageReached-9
        }
        if(daysToDisplay.count <= 9){
            topI = 1
        }
        else{
            topI = glblLog.currentSession.previousDays.count
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
            //print("bottomPrevButton CLICKED")
            if(bottomI>1){
                refreshBottomBarGraphs(--bottomI)
            }
            
        }
        if(sender == self.bottomNextButton){
            //print("bottomNextButton CLICKED")
            if(bottomI<glblLog.maxPageReached - 9){
                refreshBottomBarGraphs(++bottomI)
            }
        }
        if(sender == self.topPrevButton){
            //print("TOPPrevButton CLICKED")
            if(topI>1){
                refreshTopBarGraphs(--topI)
            }
        }
        if(sender == self.topNextButton){
            //print("TOPNextButton CLICKED")
            if(topI<glblLog.currentSession.days.count - 9){
                refreshTopBarGraphs(++topI)
            }
        }
        
    }
    func refreshTopBarGraphs(i: Int){
        let screenWidth = view.frame.size.width
        let screenHeight = self.view.frame.size.height
        
        let buttonWidth = 30.0 as CGFloat
        var buttonHeight = 10.0 as CGFloat
        let labelButtonWidth = 60.0 as CGFloat
        let labelButtonHeight = 20.0 as CGFloat
        let distanceBetweenBars = screenWidth*0.09
        var count = 0
        var index = 0.0 as CGFloat
        var indexTime = i
        //for loop populuting array of buttons for bar graph
        //for indexTime in glblLog.timeAtPageIndex{
        while(indexTime>=0 && indexTime < daysToDisplay.count && count < 9){
            buttonHeight = buttonIncrements*screenHeight * CGFloat(daysToDisplay[indexTime].time)
            if(buttonHeight > screenHeight*0.4){
                buttonHeight = screenHeight*0.4
            }
            barButtons2[count].frame = CGRectMake(115 + (index)*distanceBetweenBars , screenHeight/2 - buttonHeight, buttonWidth, buttonHeight)
            
            dayLabelButtons[count].frame = CGRectMake(100 + (index)*distanceBetweenBars , screenHeight/2, labelButtonWidth, labelButtonHeight)
            
            
            pagesPerDayLabels[count].frame = CGRectMake(120 + (index)*distanceBetweenBars , screenHeight/2 - buttonHeight - 20, buttonWidth, 20)
            pagesPerDayLabels[count].text = "\(daysToDisplay[indexTime].time)"
            
            index++
            count++
            indexTime++
        }
        indexTime--
        count--
        while(indexTime>=0 && indexTime<daysToDisplay.count && count >= 0){
            //------------------------------ TODAY Label ----------------------------------------------
            var thisDate = "whatever"
            if(indexTime < daysToDisplay.count){
                thisDate = daysToDisplay[indexTime].date
            }
            if(indexTime > indexAtTodaysDate){
                dayLabelButtons[count].backgroundColor = UIColor.redColor()
            }
            else{
                dayLabelButtons[count].backgroundColor = UIColor.greenColor()
            }

            if(indexAtTodaysDate == 0 && thisDate == daysToDisplay[glblLog.currentSession.numberOfDaysPassed + glblLog.currentSession.previousDays.count].date){
                indexAtTodaysDate = indexTime
                dayLabelButtons[count].setTitle("today", forState: UIControlState.Normal)
                dayLabelButtons[count].backgroundColor = UIColor.blueColor()
            }
            else if (indexTime == indexAtTodaysDate){
                dayLabelButtons[count].setTitle("today", forState: UIControlState.Normal)
                dayLabelButtons[count].backgroundColor = UIColor.blueColor()
            }
            else{
                dayLabelButtons[count].setTitle("\(daysToDisplay[indexTime].date)", forState: UIControlState.Normal)
            }
            //------------------------------ TODAY Label ----------------------------------------------
            count--
            indexTime--
        }
    }

    func refreshBottomBarGraphs(i: Int){
        let screenWidth = view.frame.size.width
        let screenHeight = self.view.frame.size.height
        
        let buttonWidth = 30.0 as CGFloat
        var buttonHeight = 10.0 as CGFloat
        let labelButtonWidth = 60.0 as CGFloat
        let labelButtonHeight = 20.0 as CGFloat
        let distanceBetweenBars = screenWidth*0.09
        var count = 0
        var index = 0.0 as CGFloat
        var indexTime = i
        //for loop populuting array of buttons for bar graph
        //for indexTime in glblLog.timeAtPageIndex{
        while(indexTime <= glblLog.maxPageReached && count < 9){
            
            
            buttonHeight = 0
            
            buttonHeight = buttonIncrements*screenHeight * CGFloat(glblLog.timeAtPageIndex[indexTime])
            if(buttonHeight > screenHeight*0.3){
                buttonHeight = screenHeight*0.3
            }
            barButtons[count].frame = CGRectMake(110 + (index)*distanceBetweenBars , screenHeight*bottomGraphXaxisHeight - buttonHeight, buttonWidth, buttonHeight)
            
            timeAtPageLabels[count].frame = CGRectMake(110 + (index)*distanceBetweenBars , screenHeight-buttonHeight - 125, buttonWidth, 20)
            timeAtPageLabels[count].text = "\(glblLog.timeAtPageIndex[indexTime])"
            
            pageLabelButtons[count].frame = CGRectMake(100 + (index)*distanceBetweenBars , screenHeight*bottomGraphXaxisHeight, labelButtonWidth, labelButtonHeight)
            pageLabelButtons[count].setTitle("\(indexTime)", forState: UIControlState.Normal)
            
            index++
            count++
            indexTime++
        }
    }
    
    func createBarGraphs(){
        var count = 0
        
        while(count < 9){
            barButtons.append(UIButton())
            barButtons[count].backgroundColor = UIColor.blueColor()
            self.view.addSubview(barButtons[count])
            
            timeAtPageLabels.append(UILabel())
            self.view.addSubview(timeAtPageLabels[count])
            
            barButtons2.append(UIButton())
            barButtons2[count].backgroundColor = UIColor.blueColor()
            self.view.addSubview(barButtons2[count])
            
            
            pagesPerDayLabels.append(UILabel())
            self.view.addSubview(pagesPerDayLabels[count])
            
            pageLabelButtons.append(UIButton())
            pageLabelButtons[count].backgroundColor = UIColor.greenColor()
            self.view.addSubview(pageLabelButtons[count])
            
            dayLabelButtons.append(UIButton())
            dayLabelButtons[count].backgroundColor = UIColor.grayColor()
            dayLabelButtons[count].titleLabel?.font = UIFont.systemFontOfSize(UIFont.smallSystemFontSize())
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
        
        let scaleLabel1 = UILabel(frame: CGRectMake(70, scaleLineHeight1 - 15, 30, 30))
        scaleLabel1.text = "20"
        self.view.addSubview(scaleLabel1)
        
        let scaleLabel2 = UILabel(frame: CGRectMake(70, scaleLineHeight2 - 15, 30, 30))
        scaleLabel2.text = "10"
        self.view.addSubview(scaleLabel2)
        
        let scaleLabel3 = UILabel(frame: CGRectMake(70, scaleLineHeight3 - 15, 30, 30))
        scaleLabel3.text = "10"
        self.view.addSubview(scaleLabel3)
        
        let scaleLabel4 = UILabel(frame: CGRectMake(70, scaleLineHeight4 - 15, 30, 30))
        scaleLabel4.text = "20"
        self.view.addSubview(scaleLabel4)
        
        let lineViewX = UIView.init(frame: CGRectMake(100, screenHeight*bottomGraphXaxisHeight , screenWidth, 2))
        lineViewX.backgroundColor = UIColor.blackColor()
        self.view.addSubview(lineViewX)
        
        let lineViewX2 = UIView.init(frame: CGRectMake(100, screenHeight/2, screenWidth, 2))
        lineViewX2.backgroundColor = UIColor.blackColor()
        self.view.addSubview(lineViewX2)
        
        
        let YlineHeight = screenHeight*0.7
        let lineViewY = UIView.init(frame: CGRectMake(100, screenHeight - YlineHeight - 100, 2, YlineHeight))
        lineViewY.backgroundColor = UIColor.blackColor()
        self.view.addSubview(lineViewY)
    }
    func createPrevAndNextButtons(){
        let screenWidth = view.frame.size.width
        let screenHeight = self.view.frame.size.height
        
        let prevButtonX = screenWidth*8/10
        let nextButtonX = screenWidth*9/10
        let topYs = screenHeight*0.53
        let bottomYs = screenHeight*0.93
        
        let buttonWidth = screenWidth/25 as CGFloat
        
        self.topPrevButton = UIButton(frame: CGRectMake(prevButtonX, topYs, buttonWidth, buttonWidth))
        topPrevButton.setBackgroundImage(UIImage(named: "a.jpg"), forState: UIControlState.Normal)
        topPrevButton.addTarget(self, action: "buttonAction:", forControlEvents: UIControlEvents.TouchUpInside)
        self.view.addSubview(topPrevButton)
        
        self.topNextButton = UIButton(frame: CGRectMake(nextButtonX , topYs, buttonWidth, buttonWidth))
        topNextButton.setBackgroundImage(UIImage(named: "b.jpg"), forState: UIControlState.Normal)
        topNextButton.addTarget(self, action: "buttonAction:", forControlEvents: UIControlEvents.TouchUpInside)
        self.view.addSubview(topNextButton)
        
        self.bottomPrevButton = UIButton(frame: CGRectMake(prevButtonX, bottomYs, buttonWidth, buttonWidth))
        bottomPrevButton.setBackgroundImage(UIImage(named: "a.jpg"), forState: UIControlState.Normal)
        bottomPrevButton.addTarget(self, action: "buttonAction:", forControlEvents: UIControlEvents.TouchUpInside)
        self.view.addSubview(bottomPrevButton)
        
        self.bottomNextButton = UIButton(frame: CGRectMake(nextButtonX , bottomYs, buttonWidth, buttonWidth))
        bottomNextButton.setBackgroundImage(UIImage(named: "b.jpg"), forState: UIControlState.Normal)
        bottomNextButton.addTarget(self, action: "buttonAction:", forControlEvents: UIControlEvents.TouchUpInside)
        self.view.addSubview(bottomNextButton)
    }
    
}
