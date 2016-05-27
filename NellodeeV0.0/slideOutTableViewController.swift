//
//  slideOutTableViewController.swift
//  NellodeeV0.0
//
//  Created by ahmed moussa on 11/12/15.
//  Copyright © 2015 ahmed moussa. All rights reserved.
//
//This class is in charge of controlling the content of the slide out menu

import UIKit
class slideOutTableViewController: UITableViewController {

    var titles = [String]() //string array of titles to fill out slideout menu
    override func viewDidLoad() {
        super.viewDidLoad()
        jsonLogger.writeBurgerClicked()
        self.titles = ["Goals", "Trends", "About Nellodee"]
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 3
    }

    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("selectorCell", forIndexPath: indexPath)

        cell.textLabel?.text = self.titles[indexPath.row]
        

        return cell
    }
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return self.view.frame.height*0.1 // sets every row height to 10% of the screen height
    }
    //--------- ---------- ---------- IMPORTANT FOR DISABLING CUSTOM SESSIONS --------- ---------- --------- -----------
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        //specifies which view cintroller to go to when a row is selected from slide out menu
        //comment out the performSegueWithIdentifier() functions to block going to these sections
        if(indexPath.row == 1){
            jsonLogger.writeSegue("Trends") // write interaction data to json file
            performSegueWithIdentifier("toTrends", sender: self)
        }
        else if(indexPath.row == 0){
            jsonLogger.writeSegue("Goals") // write interaction data to json file
            performSegueWithIdentifier("toGoals", sender: self)
        }
        else{
            jsonLogger.writeSegue("More Info") // write interaction data to json file
            performSegueWithIdentifier("toMoreInfo", sender: self)
        }
    }
    
}
