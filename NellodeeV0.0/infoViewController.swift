//
//  infoViewController.swift
//  NellodeeV1.0
//
//  Created by ahmed moussa on 1/5/16.
//  Copyright © 2016 ahmed moussa. All rights reserved.
//

import UIKit

class infoViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        
        // Do any additional setup after loading the view.
    }

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        let screenWidth = self.view.frame.width
        let screenHeight = self.view.frame.height
        
        let img = UIImage(named: "a.jpg")
        let buttonimg = UIButton(frame: CGRect(x: screenWidth*0.1, y: screenHeight*0.1, width: screenWidth*0.8, height: screenHeight*0.8))
        buttonimg.setBackgroundImage(img, forState: UIControlState.Normal)
        self.view.addSubview(buttonimg)
    
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
