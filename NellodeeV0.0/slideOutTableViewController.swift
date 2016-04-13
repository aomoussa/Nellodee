//
//  slideOutTableViewController.swift
//  NellodeeV0.0
//
//  Created by ahmed moussa on 11/12/15.
//  Copyright © 2015 ahmed moussa. All rights reserved.
//

import UIKit

class slideOutTableViewController: UITableViewController {

    var titles = [String]()
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
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        if(indexPath.row == 1){
            jsonLogger.writeSegueOutOfReader("Trends")
            performSegueWithIdentifier("toTrends", sender: self)
        }
        else if(indexPath.row == 0){
            jsonLogger.writeSegueOutOfReader("Goals")
            performSegueWithIdentifier("toGoals", sender: self)
        }
        else{
            jsonLogger.writeSegueOutOfReader("More Info")
            performSegueWithIdentifier("toMoreInfo", sender: self)
        }
    }
    
}
