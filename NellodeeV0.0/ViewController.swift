//
//  ViewController.swift
//  NellodeeV0.0
//
//  Created by ahmed moussa on 11/12/15.
//  Copyright © 2015 ahmed moussa. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UIWebViewDelegate {
    //local variables
    let defaults = NSUserDefaults.standardUserDefaults()
    var todaysDate = "12/12/15"
    var pageHeight = 841.8 as CGFloat
    var path = ""
    var pdfPageCount = 0
    var timeOnCurrentPage = 0
    var timer = NSTimer()
    
    //UI stuff
    let guyView = UIButton()
    let currentPageLabel = UILabel()
    let startPageLabel = UILabel()
    let endPageLabel = UILabel()
    let button1 = UIButton()
    let button2 = UIButton()
    
    //from storyboard
    @IBOutlet var webView: UIWebView!
    @IBAction func nextDay(sender: UIButton) {
        glblLog.addDay("\(25+glblLog.daysRead.count)/12/15")
        todaysDate = "\(25+glblLog.daysRead.count)/12/15"
        updateProgressBar()
    }
    @IBOutlet var burger: UIBarButtonItem!
    @IBOutlet var paceLabel: UILabel!
    @IBOutlet var timerLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if(!glblLog.dayExists()){
            glblLog.addToday()
            updateProgressBar()
            
        }
        self.path = NSBundle.mainBundle().pathForResource("pdfBook", ofType: "pdf")!
        let url = NSURL.fileURLWithPath(path)
        self.webView.loadRequest(NSURLRequest(URL: url))
        
        let pdf = CGPDFDocumentCreateWithURL(url)
        pdfPageCount = CGPDFDocumentGetNumberOfPages(pdf)
        
        if(glblLog.numberOfPages != pdfPageCount){
            if(glblLog.timeAtPageIndex.count <= 1){
                glblLog.setBookNumOfPages(pdfPageCount)
            }
            else{
                glblLog.numberOfPages = pdfPageCount
            }
        }
        webView.delegate = self
        
        timer = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: "runTimedCode", userInfo: nil, repeats: true)
        
        burger.target = self.revealViewController()
        burger.action = Selector("revealToggle:")
    }
    
    @IBAction func nextPageButton(sender: UIButton) {
        glblLog.pageReadUpdate()
        if(glblLog.currentPageNumber == glblLog.maxPageReached){
            glblLog.maxPageReached++
        }
        glblLog.currentPageNumber++
        glblLog.scrollDestination = pageHeight + glblLog.scrollDestination
        webView.scrollView.setContentOffset(CGPointMake(0, glblLog.scrollDestination), animated: false)
        updateProgressBar()
    }
    @IBAction func prevPageButton(sender: UIButton) {
        glblLog.currentPageNumber--
        glblLog.scrollDestination = glblLog.scrollDestination - pageHeight
        webView.scrollView.setContentOffset(CGPointMake(0, glblLog.scrollDestination), animated: false)
        updateProgressBar()
    }
    
    func runTimedCode() {
        timeOnCurrentPage = glblLog.timeAtPageIndex[glblLog.currentPageNumber]
        timerLabel.text = "\(timeOnCurrentPage)"
        
        if(timeOnCurrentPage == 0){
            guyView.setBackgroundImage(UIImage(named: "a.jpg"), forState: UIControlState.Normal)
        }
        else if(timeOnCurrentPage == 5){
            guyView.setBackgroundImage(UIImage(named: "b.jpg"), forState: UIControlState.Normal)
        }
        else if(timeOnCurrentPage == 10){
            guyView.setBackgroundImage(UIImage(named: "a.jpg"), forState: UIControlState.Normal)
        }
        
        if(timeOnCurrentPage < 5){
            paceLabel.text = "fast"}
        else if(timeOnCurrentPage < 10){
            paceLabel.text = "arright"}
        else {
            paceLabel.text = "sloww"}
//        let todaysIndex = glblLog.currentSession.getTodaysIndex(todaysDate)
//        if(todaysIndex >= 0 ){
//            var pageIndex = glblLog.currentSession.days[todaysIndex].getPageIndex(glblLog.currentPageNumber - 1)
//            if(pageIndex >= 0){
//                glblLog.currentSession.days[todaysIndex].pages[pageIndex].time++
//            }
//            //print("todays index: \(todaysIndex) page number: \(glblLog.currentPageNumber) page index: \(pageIndex)")
//        }
        glblLog.currentSession.addTime()
        glblLog.timeAtPageIndex[glblLog.currentPageNumber]++
    }
    
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        let screenWidth = view.frame.size.width
        let screenHeight = self.view.frame.size.height
        webView.scrollView.setContentOffset(CGPointMake(0, glblLog.scrollDestination), animated: false)
        webView.frame = CGRectMake(0, webView.frame.minY, screenWidth, pageHeight )
        
        self.view.addSubview(button1)
        self.view.addSubview(button2)
        self.view.addSubview(guyView)
        updateProgressBar()
        
        let labelWidth = screenWidth/15
        let labelHeight = screenHeight/30
        
        startPageLabel.frame = CGRectMake(100, screenHeight - 1.5*labelHeight, labelWidth, labelHeight )
        startPageLabel.text = "\(glblLog.startPage)"
        self.view.addSubview(startPageLabel)
        
        endPageLabel.frame = CGRectMake(screenWidth - labelWidth/2 - 100, screenHeight - 1.5*labelHeight, labelWidth, labelHeight)
        endPageLabel.text = "\(glblLog.startPage + glblLog.expectedPagesPerDay)"
        self.view.addSubview(endPageLabel)
        
        currentPageLabel.frame = CGRectMake(100 +  labelWidth/2, screenHeight - labelHeight - (2 * screenHeight/25), labelWidth, labelHeight )
        currentPageLabel.text = "\(glblLog.currentPageNumber)"
        self.view.addSubview(currentPageLabel)
        
    }
    func updateProgressBar(){
        let screenWidth = view.frame.size.width
        let screenHeight = self.view.frame.size.height
        let progressBarWidth = screenWidth - 200 as CGFloat
        var progress = 0.0 as CGFloat
        if(glblLog.numberOfPages > 0 && glblLog.expectedPagesPerDay1.count > glblLog.daysRead.count ){
            progress = CGFloat(glblLog.actualPagesPerDay[glblLog.daysRead.count - 1].count)/CGFloat(glblLog.expectedPagesPerDay1[glblLog.daysRead.count - 1]) * progressBarWidth
        }
        if(progress > progressBarWidth){
            progress = progressBarWidth
        }
        let button1Width = progress
        let button2Width = progressBarWidth - progress
        let buttonHeight = screenHeight/25 as CGFloat
        let imageWidth = screenWidth/22
        
        button1.frame = CGRectMake(100, screenHeight - 2*buttonHeight, button1Width, buttonHeight)
        button1.backgroundColor = UIColor.greenColor()
        
        button2.frame = CGRectMake(100 + progress , screenHeight - 2*buttonHeight, button2Width, buttonHeight )
        button2.backgroundColor = UIColor.redColor()
        
        let labelWidth = screenWidth/15
        let labelHeight = screenHeight/30
        
        startPageLabel.text = "\(glblLog.startPage)"

        if(glblLog.expectedPagesPerDay1.count > glblLog.daysRead.count){
        endPageLabel.text = "\(glblLog.startPage + glblLog.expectedPagesPerDay1[glblLog.daysRead.count - 1])"//"\(glblLog.startPage + glblLog.expectedPagesPerDay)"
        }
        currentPageLabel.frame = CGRectMake(100 + progress - 5, screenHeight - labelHeight - 2*buttonHeight, labelWidth, labelHeight )
        currentPageLabel.text = "\(glblLog.currentPageNumber)"

        guyView.frame = CGRectMake(100 + progress - imageWidth/2, screenHeight - 2*buttonHeight, imageWidth, buttonHeight)
        
           }
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        timer.invalidate()
    }
}

