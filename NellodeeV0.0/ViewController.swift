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
    let NellodeeMidGray = UIColor(red: 102/255, green: 102/255, blue: 102/255, alpha: 1)
    let NellodeeBottomBarGray = UIColor(red: 204/255, green: 204/255, blue: 204/255, alpha: 1)
    
    //from storyboard
    @IBOutlet var webView: UIWebView!
    @IBOutlet var burger: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        jsonLogger.writeSegue("Reader")
        
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
        
        let pdf = CGPDFDocumentCreateWithURL(url)
        pdfPageCount = CGPDFDocumentGetNumberOfPages(pdf)
        
        
        //if(glblLog.numberOfPages != pdfPageCount){
            if(glblLog.timeAtPageIndex.count <= 1){
                glblLog.setBookNumOfPages(pdfPageCount)
            }
            else{
                glblLog.numberOfPages = pdfPageCount
            }
        //}
        timer = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: #selector(ViewController.runTimedCode), userInfo: nil, repeats: true)
        
        burger.target = self.revealViewController()
        burger.action = #selector(SWRevealViewController.revealToggle(_:))
        
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateStyle = NSDateFormatterStyle.ShortStyle
        todaysDate = dateFormatter.stringFromDate(NSDate())
        var currentSessionLastDateReached = todaysDate
        if(glblLog.currentSession.days.count > 0)
        {
            currentSessionLastDateReached = glblLog.currentSession.days[glblLog.currentSession.numberOfDaysPassed].date
        }
        print("today is \(todaysDate) and current session last date reached is \(currentSessionLastDateReached) comparision:")
        print(NSDate().compare(dateFormatter.dateFromString(currentSessionLastDateReached)!).rawValue)
        let dateComparison = dateFormatter.dateFromString(currentSessionLastDateReached)!.compare(NSDate()).rawValue
        
        if(currentSessionLastDateReached != todaysDate && dateComparison < 1){
            glblLog.currentSession.setNextDayStartPage(glblLog.currentPageNumber)
            glblLog.currentSession.numberOfDaysPassed += 1
            print("new day: todays date: \(todaysDate) and session.days[numberOfDaysPassed - 1] = \(glblLog.currentSession.days[glblLog.currentSession.numberOfDaysPassed - 1].date)")
            updateProgressBar()
        }
        else{
            print("same day or older: numberOfDaysPassed \(glblLog.currentSession.numberOfDaysPassed) \n todays date: \(todaysDate) ")
            //print(" \(glblLog.currentSession.toString())  ")
        }
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
            glblLog.currentPageNumber -= 1
            glblLog.scrollDestination = glblLog.scrollDestination - pageHeight
            webView.scrollView.setContentOffset(CGPointMake(0, glblLog.scrollDestination), animated: false)
            jsonLogger.writeChangedPage(glblLog.currentPageNumber, direction: "Previous")
            updateProgressBar()
        }
        if(sender == self.nextPageButton){
            
            if(glblLog.maxPageReached == glblLog.currentPageNumber && glblLog.currentSession.days.count > glblLog.currentSession.numberOfDaysPassed){
                glblLog.currentSession.days[glblLog.currentSession.numberOfDaysPassed].pages.append(page(pageNumber: glblLog.currentPageNumber+1, time: 0))
                
                print(glblLog.currentSession.toString())
            }
            
            
            if(glblLog.currentPageNumber < glblLog.numberOfPages){
                if(glblLog.currentPageNumber == glblLog.maxPageReached){
                    glblLog.maxPageReached += 1
                }
                glblLog.currentPageNumber += 1
                
                glblLog.scrollDestination = pageHeight + glblLog.scrollDestination
                webView.scrollView.setContentOffset(CGPointMake(0, 0), animated: false)
                jsonLogger.writeChangedPage(glblLog.currentPageNumber, direction: "Next")
                updateProgressBar()
            }
            
        }
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        let screenWidth = view.frame.size.width
        let screenHeight = self.view.frame.size.height
        let distanceFromSides = screenWidth*0.15
        
        bottomView.backgroundColor = NellodeeBottomBarGray
        navigationItem.title = "Nellodee"
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
        
        startPageLabel.frame = CGRectMake(distanceFromSides, screenHeight - labelHeight, labelWidth, labelHeight )
        self.view.addSubview(startPageLabel)
        
        endPageLabel.frame = CGRectMake(screenWidth - labelWidth*0.2 - distanceFromSides, screenHeight - labelHeight, labelWidth, labelHeight)
        self.view.addSubview(endPageLabel)
        
        currentPageLabel.text = "\(glblLog.currentPageNumber)"
        self.view.addSubview(currentPageLabel)
        
        //colors
        startPageLabel.textColor = UIColor(red: 102/255, green: 51/255, blue: 51/255, alpha: 1)
        endPageLabel.textColor = UIColor(red: 102/255, green: 51/255, blue: 51/255, alpha: 1)
        currentPageLabel.textColor = UIColor(red: 102/255, green: 51/255, blue: 51/255, alpha: 1)
        button1.backgroundColor = UIColor(red: 102/255, green: 51/255, blue: 51/255, alpha: 1)
        button2.backgroundColor = NellodeeMidGray
        webView.backgroundColor = UIColor(red: 51/255, green: 51/255, blue: 51/255, alpha: 1)
    }
    func createNextAndPrevButtons(){
        let screenWidth = view.frame.size.width
        let screenHeight = self.view.frame.size.height
        
        let buttonsWidth = screenWidth*0.09
        let distanceFromSides = screenWidth*0.02
        let distanceFromBottom = buttonsWidth + screenWidth*0.02
        
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
        if(glblLog.currentSession.days.count > glblLog.currentSession.numberOfDaysPassed){
            glblLog.currentSession.days[glblLog.currentSession.numberOfDaysPassed].time += 1
        }
        if(glblLog.timeAtPageIndex.count>glblLog.currentPageNumber){
            timeOnCurrentPage = glblLog.timeAtPageIndex[glblLog.currentPageNumber]
            glblLog.timeAtPageIndex[glblLog.currentPageNumber] += 1
        }
        
        if(timeOnCurrentPage == 0){
            guyView.setBackgroundImage(UIImage(named: "RunningMan_A.jpg"), forState: UIControlState.Normal)
        }
        else if(timeOnCurrentPage == 5){
            guyView.setBackgroundImage(UIImage(named: "RunningMan_B.jpg"), forState: UIControlState.Normal)
        }
        else if(timeOnCurrentPage == 10){
            guyView.setBackgroundImage(UIImage(named: "RunningMan_C.jpg"), forState: UIControlState.Normal)
        }
        
    }
    
    
    
    func updateProgressBar(){
        
        let screenWidth = view.frame.size.width
        let screenHeight = self.view.frame.size.height
        let distanceFromSides = screenWidth*0.15
        let progressBarWidth = screenWidth - distanceFromSides*2 as CGFloat
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
        let buttonHeight = screenHeight*0.005 as CGFloat
        let guyHeight = screenHeight*0.07 as CGFloat
        let guyWidth = screenWidth*0.07
        let labelWidth = screenWidth/15
        let labelHeight = screenHeight/30
        
        button1.frame = CGRectMake(distanceFromSides, screenHeight - labelHeight, button1Width, buttonHeight)
        
        button2.frame = CGRectMake(distanceFromSides + progress , screenHeight - labelHeight, button2Width, buttonHeight )
        
        if(glblLog.currentSession.days.count > glblLog.currentSession.numberOfDaysPassed){
            if(glblLog.currentSession.days[glblLog.currentSession.numberOfDaysPassed].startPage < glblLog.currentPageNumber){
                startPageLabel.text = "\(glblLog.currentSession.days[glblLog.currentSession.numberOfDaysPassed].startPage)"
            }
            else{
                startPageLabel.text = ""
            }
            if(glblLog.currentSession.days[glblLog.currentSession.numberOfDaysPassed].endPage > glblLog.currentPageNumber){
                endPageLabel.text = "\(glblLog.currentSession.days[glblLog.currentSession.numberOfDaysPassed].endPage)"
            }
            else{
                endPageLabel.text = ""
            }
        }
        currentPageLabel.frame = CGRectMake(distanceFromSides + progress - 5, screenHeight - labelHeight, labelWidth, labelHeight )
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
        guyView.frame = CGRectMake(distanceFromSides + progress - guyWidth/2, screenHeight - guyHeight - labelHeight, guyWidth, guyHeight)
    }
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        timer.invalidate()
    }
}

