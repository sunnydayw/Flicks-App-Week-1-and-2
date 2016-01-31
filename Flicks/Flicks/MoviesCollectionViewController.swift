//
//  MoviesCollectionViewController.swift
//  Flicks
//
//  Created by QingTian Chen on 1/31/16.
//  Copyright © 2016 QingTian Chen. All rights reserved.
//

import UIKit
import AFNetworking
import MBProgressHUD
import ReachabilitySwift

class MoviesCollectionViewController: UIViewController, UICollectionViewDataSource,UICollectionViewDelegate {

    @IBOutlet weak var networkError: UIView!
    @IBOutlet weak var collectionView: UICollectionView!
    var movies: [NSDictionary]?
    var reachability: Reachability?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.dataSource = self
        collectionView.delegate = self
        /****** Check network Status ******/
        do {
            reachability = try Reachability.reachabilityForInternetConnection()
        } catch {
            print("Unable to create Reachability")
        }
        reachability!.whenReachable = { reachability in
            // this is called on a background thread, but UI updates must
            // be on the main thread, like this:
            self.networkError.hidden = true
            dispatch_async(dispatch_get_main_queue()) {
                if reachability.isReachableViaWiFi() {
                    print("Reachable via WiFi")
                } else {
                    print("Reachable via Cellular")
                }
            }
        }
        reachability!.whenUnreachable = { reachability in
            // this is called on a background thread, but UI updates must
            // be on the main thread, like this:
            self.networkError.hidden = false
            dispatch_async(dispatch_get_main_queue()) {
                print("Not reachable")
            }
        }
        do {
            try reachability!.startNotifier()
        } catch {
            print("Unable to start notifier")
        }
        
        /****** Pull and refresh ******/
        let refreshControl: UIRefreshControl = {
            let refreshControl = UIRefreshControl()
            refreshControl.addTarget(self, action: "refresh:", forControlEvents: UIControlEvents.ValueChanged)
            return refreshControl
        }()
        self.collectionView.addSubview(refreshControl)
        

        // Do any additional setup after loading the view.
        loadMovieData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    func refresh(refreshControl: UIRefreshControl) {
        print("refresh")
        loadMovieData()
        collectionView.reloadData()
        refreshControl.endRefreshing()
    }
    
    func reachabilityChanged(note: NSNotification) {
        
        let reachability = note.object as! Reachability
        
        if reachability.isReachable() {
            if reachability.isReachableViaWiFi() {
                print("Reachable via WiFi")
            } else {
                print("Reachable via Cellular")
            }
        } else {
            print("Not reachable")
        }
    }
    
    func loadMovieData() {
        let apiKey = "a07e22bc18f5cb106bfe4cc1f83ad8ed"
        let url = NSURL(string: "https://api.themoviedb.org/3/movie/now_playing?api_key=\(apiKey)")
        let request = NSURLRequest(
            URL: url!,
            cachePolicy: NSURLRequestCachePolicy.ReloadIgnoringLocalCacheData,timeoutInterval: 1)
        
        let session = NSURLSession(
            configuration: NSURLSessionConfiguration.defaultSessionConfiguration(),
            delegate: nil,
            delegateQueue: NSOperationQueue.mainQueue()
        )
        
        // Display HUD right before the request is made
        MBProgressHUD.showHUDAddedTo(self.view, animated: true)
        
        let task: NSURLSessionDataTask = session.dataTaskWithRequest(request,
            completionHandler: { (dataOrNil, response, error) in
                if let data = dataOrNil {
                    if let responseDictionary = try! NSJSONSerialization.JSONObjectWithData(
                        data, options:[]) as? NSDictionary {
                            //print("response: \(responseDictionary)")
                            self.movies = responseDictionary["results"] as? [NSDictionary]
                            self.collectionView.reloadData()
                            // Hide HUD once the network request comes back
                            MBProgressHUD.hideHUDForView(self.view, animated: true)
                            print("im in loading data")
                    } else{
                        MBProgressHUD.hideHUDForView(self.view, animated: true)
                        self.loadMovieData()
                        print("im in reloading")
                    }
                }
        })
        task.resume()
        
    }

    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if let movies = movies {
            return movies.count
        }else {
            return 0
        }
        
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("Chen.Cell", forIndexPath: indexPath) as! MovieCollectionViewCell
        let movie = movies![indexPath.row]
        if let posterPath = movie["poster_path"] as? String {
            let baseUrl = "http://image.tmdb.org/t/p/w500"
            let imageUrl = NSURL(string: baseUrl + posterPath)
            //cell.CollectionImg.setImageWithURL(imageUrl!)
            
            //Fading in an Image Loaded from the Network
            let imageRequest = NSURLRequest(URL: imageUrl!)
            cell.CollectionImg.setImageWithURLRequest(
                imageRequest,
                placeholderImage: nil,
                success: { (imageRequest, imageResponse, image) -> Void in
                    // imageResponse will be nil if the image is cached
                    if imageResponse != nil {
                        print("Image was NOT cached, fade in image")
                        cell.CollectionImg.alpha = 0.0
                        cell.CollectionImg.image = image
                        UIView.animateWithDuration(1, animations: { () -> Void in
                            cell.CollectionImg.alpha = 1.0
                        })
                    } else {
                        print("Image was cached so just update the image")
                        cell.CollectionImg.image = image
                    }
                },
                failure: { (imageRequest, imageResponse, error) -> Void in
                    // do something for the failure condition
            })

        }
        //cell.textLabel?.text = title
        //print("row \(indexPath.row)")
        return cell
        
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if (segue.identifier == "1"){
            let cell = sender as! UICollectionViewCell
            let selectedRowIndex = collectionView.indexPathForCell(cell)
            let movie = movies![(selectedRowIndex!.row)]
            let targetView: DetailViewViewController = segue.destinationViewController as! DetailViewViewController
            targetView.movie = movie
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
