//
//  DetailViewViewController.swift
//  Flicks
//
//  Created by QingTian Chen on 1/31/16.
//  Copyright © 2016 QingTian Chen. All rights reserved.
//

import UIKit
import AFNetworking
import MBProgressHUD
import ReachabilitySwift

class DetailViewViewController: UIViewController {
    
    @IBOutlet weak var infoView: UIView!
    @IBOutlet weak var detailvote: UILabel!
    @IBOutlet weak var detailTitle: UILabel!
    @IBOutlet weak var detailImg: UIImageView!
    @IBOutlet weak var scrollView: UIScrollView!
    var movie: NSDictionary?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //scrollView.contentSize = CGSize(width: scrollView.frame.size.width, height: infoView.frame.origin.y + infoView.frame.size.height)
        
        
        loadDetails()
        
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func loadDetails() {
        MBProgressHUD.showHUDAddedTo(self.view, animated: true) 
        if let posterPath = movie?["poster_path"] as? String {
            // we geting 500x750 image
            let baseUrl = "http://image.tmdb.org/t/p/w500"
            let imageUrl = NSURL(string: baseUrl + posterPath)
            self.detailImg.setImageWithURL(imageUrl!)
            MBProgressHUD.hideHUDForView(self.view, animated: true)
            let title = movie!["title"] as? String
            self.detailTitle.text = title
            let vote_average = movie!["vote_average"] as! Double
            self.detailvote.text = ("\(vote_average)")
            detailvote.sizeToFit()
            
        } else {
            detailvote.text = nil
            detailImg.image = nil
            detailTitle.text = nil
            MBProgressHUD.hideHUDForView(self.view, animated: true)
        }

    
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
