//
//  MoviesViewController.swift
//  tomato
//
//  Created by Ho-Hsiang Wu on 4/18/15.
//  Copyright (c) 2015 muspaper. All rights reserved.
//

import UIKit

class MoviesViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var errorLabel: UILabel!
    @IBOutlet weak var moviesTableView: UITableView!

    var refreshControl: UIRefreshControl!
    var movies: [NSDictionary]?

    override func viewDidLoad() {
        super.viewDidLoad()

        refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: "onRefresh", forControlEvents: UIControlEvents.ValueChanged)
        moviesTableView.insertSubview(refreshControl, atIndex: 0)

        SVProgressHUD.show()

        if Reachability.isConnectedToNetwork() {
            let url = NSURL(string: "http://api.rottentomatoes.com/api/public/v1.0/lists/movies/box_office.json?apikey=dagqdghwaq3e3mxyrp7kmmj5&limit=20&country=us")!
            let request = NSURLRequest(URL: url)
            
            NSURLConnection.sendAsynchronousRequest(request, queue: NSOperationQueue.mainQueue()) { (response: NSURLResponse!, data: NSData!, error: NSError!) -> Void in
                let json = NSJSONSerialization.JSONObjectWithData(data, options: nil, error: nil) as? NSDictionary
                if let json = json {
                    self.movies = json["movies"] as? [NSDictionary]
                    self.moviesTableView.reloadData()
                    SVProgressHUD.dismiss()
                }
            }
        } else {
            errorLabel.text = "Network Error!"
            errorLabel.hidden = false
        }

        moviesTableView.dataSource = self
        moviesTableView.delegate = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func delay(delay:Double, closure:()->()) {
        dispatch_after(
            dispatch_time(
                DISPATCH_TIME_NOW,
                Int64(delay * Double(NSEC_PER_SEC))
            ),
            dispatch_get_main_queue(), closure)
    }

    func onRefresh() {
        delay(1, closure: {
            self.refreshControl.endRefreshing()
        })
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let movies = movies {
            return movies.count
        } else {
            return 0
        }
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCellWithIdentifier("MovieCell", forIndexPath: indexPath) as! MovieTableViewCell

        let movie = movies![indexPath.row]
        cell.titleLabel.text = movie["title"] as? String
        cell.synopsisLabel.text = movie["synopsis"] as? String
        let url = NSURL(string: movie.valueForKeyPath("posters.thumbnail") as! String)!
        cell.posterImageView.setImageWithURL(url)
        
        return cell
    }

    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let cell = sender as! UITableViewCell
        let indexPath = moviesTableView.indexPathForCell(cell)!

        let movie = movies![indexPath.row]
        let movieDetailsViewController = segue.destinationViewController as! MovieDetailsViewController
        movieDetailsViewController.movie = movie
    }

}
