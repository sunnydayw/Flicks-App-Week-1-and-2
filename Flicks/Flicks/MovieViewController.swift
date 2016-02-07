//
//  MovieViewController.swift
//  Flicks
//
//  Created by QingTian Chen on 1/27/16.
//  Copyright © 2016 QingTian Chen. All rights reserved.
//

import UIKit
import AFNetworking
import MBProgressHUD
import ReachabilitySwift

class MovieViewController: UIViewController, UITableViewDataSource, UITableViewDelegate,UISearchBarDelegate {
    
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var networkError: UIView!
    @IBOutlet weak var tableView: UITableView!
    var movies: [NSDictionary]?
    var filterNSD: [NSDictionary]?
    var reachability: Reachability?
    var MovieDdata: [String] = []
    var filteredData: [String] = []
    var displayarray: [Int] = []
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.delegate = self
        searchBar.delegate = self
        filteredData = MovieDdata
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
        self.tableView.addSubview(refreshControl)
        
        /****** Load Network Data ******/
        loadMovieData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func refresh(refreshControl: UIRefreshControl) {
        print("refresh")
        loadMovieData()
        self.tableView.reloadData()
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
                            // load movie title in to array MovieData
                            self.MovieDdata.removeAll()
                            let NumOfMovie = self.movies!.count
                            for (var i=0; i < NumOfMovie; i++) {
                                var movie = self.movies![i]
                                var title = movie["title"] as! String
                                self.MovieDdata.append(title)
                            }
                            self.filteredData = self.MovieDdata
                            //print("\(self.MovieDdata)")
                            //print("\(NumOfMovie)")
                            // Hide HUD once the network request comes back
                            MBProgressHUD.hideHUDForView(self.view, animated: true)
                            self.tableView.reloadData()
                    } else{
                        MBProgressHUD.hideHUDForView(self.view, animated: true)
                        self.loadMovieData()
                        print("im in reloading")
                    }
                }
        })
        task.resume()

    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("MovieCell", forIndexPath: indexPath) as! MovieCell
        displayarray.removeAll()
        for (var i = 0; i<self.movies!.count; i++) {
            let movie = movies! [i]
            let title = movie["title"] as! String
            for (var j = 0; j<filteredData.count; j++) {
                if(title == filteredData[j]) {
                    let Number = movies!.indexOf(movie)! as Int
                    displayarray.append(Number)
                }
            }
        }
        print("\(displayarray)")
        //let movie = filterNSD![indexPath.row]
        let movie = movies![displayarray[indexPath.row]]
        // display all movie[index] element, find those index element in moives
        let title = movie["title"] as! String
        let overview = movie["overview"] as! String
        if let posterPath = movie["poster_path"] as? String {
            // we geting 500x750 image
            let baseUrl = "http://image.tmdb.org/t/p/w500"
            let imageUrl = NSURL(string: baseUrl + posterPath)
            //cell.posterView.setImageWithURL(imageUrl!)
            cell.titleLabel.text = title
            cell.overviewLabel.text = overview
            //Fading in an Image Loaded from the Network
            let imageRequest = NSURLRequest(URL: imageUrl!)
            cell.posterView.setImageWithURLRequest(
                imageRequest,
                placeholderImage: nil,
                success: { (imageRequest, imageResponse, image) -> Void in
                    // imageResponse will be nil if the image is cached
                    if imageResponse != nil {
                        print("Image was NOT cached, fade in image")
                        cell.posterView.alpha = 0.0
                        cell.posterView.image = image
                        UIView.animateWithDuration(1, animations: { () -> Void in
                            cell.posterView.alpha = 1.0
                        })
                    } else {
                        print("Image was cached so just update the image")
                        cell.posterView.image = image
                    }
                },
                failure: { (imageRequest, imageResponse, error) -> Void in
                    // do something for the failure condition
            })

        }
        return cell
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if let movies = movies {
            //filteredData change when text did change happen,only filtered title appear
            //find same title in the movies array and only display those movies
            //print("\(filteredData.count)")
            //print("\(filteredData)")
            return filteredData.count
            
        }else {
            return 0
        }
        
        
    }
    
    
    // This method updates filteredData based on the text in the Search Box
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        // When there is no text, filteredData is the same as the original data
        if searchText.isEmpty {
            filteredData = MovieDdata
        } else {
            // The user has entered text into the search box
            // Use the filter method to iterate over all items in the data array
            // For each item, return true if the item should be included and false if the
            // item should NOT be included
            filteredData = MovieDdata.filter({(dataItem: String) -> Bool in
                // If dataItem matches the searchText, return true to include it
                if dataItem.rangeOfString(searchText, options: .CaseInsensitiveSearch) != nil {
                    
                    /* 
                    for loop from 0 to # of movies
                        for # of filter moive
                            if n moive title = # filter moive title
                                find title postiton in moives 
                                save that position to filteredNSD
                    */
                    /*
                    for (var i = 0; i<self.movies!.count; i++) {
                        let movie = movies! [i]
                        let title = movie["title"] as! String
                        for (var j = 0; j<filteredData.count; j++) {
                            if(title == filteredData[j]) {
                                print("\(title) = \(filteredData[j])")
                                print("\(movies?.indexOf(movie))")
                            }
                        }
                    }*/
                    
                    return true
                } else {
                    return false
                }
            })
        }
        tableView.reloadData()
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if (segue.identifier == "detailOfMovie"){
            let selectedRowIndex = self.tableView.indexPathForSelectedRow
            let movie = movies![displayarray[(selectedRowIndex?.row)!]]
            let targetView: DetailViewViewController = segue.destinationViewController as! DetailViewViewController
            targetView.movie = movie
        }
    }

}
