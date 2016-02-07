//
//  LaunchScreenViewController.swift
//  Flicks
//
//  Created by QingTian Chen on 2/7/16.
//  Copyright © 2016 QingTian Chen. All rights reserved.
//

import UIKit

class LaunchScreenViewController: UIViewController {

    @IBOutlet weak var launchImg: UIImageView!
    override func viewDidLoad() {
        super.viewDidLoad()
        //self.showNavController()
        UIView.animateWithDuration(0.3, delay: 0.1, usingSpringWithDamping: 0.5, initialSpringVelocity: 10, options: [], animations: { () -> Void in
            self.launchImg.transform = CGAffineTransformMakeScale(1.1, 1.1)
            self.launchImg.alpha = 0.5
            }) { (Bool) -> Void in
                UIView.animateWithDuration(0.3, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 10, options: [], animations: { () -> Void in
                    self.launchImg.transform = CGAffineTransformMakeScale(1, 1)
                    self.launchImg.alpha = 1
                    }, completion: { (Bool) -> Void in
                        UIView.animateWithDuration(0.3, delay: 0.1, usingSpringWithDamping: 0.5, initialSpringVelocity: 10, options: [], animations: { () -> Void in
                            self.launchImg.transform = CGAffineTransformMakeScale(1.1, 1.1)
                            self.launchImg.alpha = 0.5
                            }) { (Bool) -> Void in
                                UIView.animateWithDuration(0.3, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 10, options: [], animations: { () -> Void in
                                    self.launchImg.transform = CGAffineTransformMakeScale(1, 1)
                                    self.launchImg.alpha = 1
                                    }, completion: { (Bool) -> Void in
                                        UIView.animateWithDuration(0.3, delay: 0.1, usingSpringWithDamping: 0.5, initialSpringVelocity: 10, options: [], animations: { () -> Void in
                                            self.launchImg.transform = CGAffineTransformMakeScale(1.1, 1.1)
                                            self.launchImg.alpha = 0.5
                                            }) { (Bool) -> Void in
                                                UIView.animateWithDuration(0.3, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 10, options: [], animations: { () -> Void in
                                                    self.launchImg.transform = CGAffineTransformMakeScale(1, 1)
                                                    self.launchImg.alpha = 1
                                                    }, completion: { (Bool) -> Void in
                                                        self.showNavController()
                                                })
                                        }
                                        
                                })
                        }
                        
                })
        }
        



        // Do any additional setup after loading the view.
        //performSelector(Selector("showNavController"), withObject: nil, afterDelay: 1)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    func showNavController() {
        performSegueWithIdentifier("showSplashScreen", sender: self)
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
