//
//  MoviesViewController.swift
//  tomato
//
//  Created by Ho-Hsiang Wu on 4/18/15.
//  Copyright (c) 2015 muspaper. All rights reserved.
//

import UIKit

class MoviesViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UICollectionViewDataSource, UICollectionViewDelegate, UISearchBarDelegate {

    @IBOutlet weak var errorLabel: UILabel!
    @IBOutlet weak var moviesTableView: UITableView!
    @IBOutlet weak var moviesCollectionView: UICollectionView!
    @IBOutlet weak var toggleButton: UIBarButtonItem!
    @IBOutlet weak var movieSearchBar: UISearchBar!

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
                    self.moviesCollectionView.reloadData()
                    SVProgressHUD.dismiss()
                }
            }
        } else {
            errorLabel.text = "Network Error!"
            errorLabel.hidden = false
        }

        moviesTableView.dataSource = self
        moviesTableView.delegate = self
        moviesCollectionView.dataSource = self
        moviesCollectionView.delegate = self
        movieSearchBar.delegate = self
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

    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if let movies = movies {
            return movies.count
        } else {
            return 0
        }
    }

    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        var cell = collectionView.dequeueReusableCellWithReuseIdentifier("MovieCollectionCell", forIndexPath: indexPath) as! MovieCollectionViewCell
        let movie = movies![indexPath.item]
        let url = NSURL(string: movie.valueForKeyPath("posters.thumbnail") as! String)!
        cell.posterImageView.setImageWithURL(url)

        return cell
    }

    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.isEmpty {
            let url = NSURL(string: "http://api.rottentomatoes.com/api/public/v1.0/lists/movies/box_office.json?apikey=dagqdghwaq3e3mxyrp7kmmj5&limit=20&country=us")!
            let request = NSURLRequest(URL: url)

            NSURLConnection.sendAsynchronousRequest(request, queue: NSOperationQueue.mainQueue()) { (response: NSURLResponse!, data: NSData!, error: NSError!) -> Void in
                let json = NSJSONSerialization.JSONObjectWithData(data, options: nil, error: nil) as? NSDictionary
                if let json = json {
                    self.movies = json["movies"] as? [NSDictionary]
                    self.moviesTableView.reloadData()
                    self.moviesCollectionView.reloadData()
                    SVProgressHUD.dismiss()
                }
            }
        } else {
            SVProgressHUD.show()
            var urlEncodedString = searchText.stringByAddingPercentEncodingWithAllowedCharacters(.URLHostAllowedCharacterSet())!
            let url = NSURL(string: "http://api.rottentomatoes.com/api/public/v1.0/movies.json?apikey=dagqdghwaq3e3mxyrp7kmmj5&q=\(urlEncodedString)")!
            let request = NSURLRequest(URL: url)

            NSURLConnection.sendAsynchronousRequest(request, queue: NSOperationQueue.mainQueue()) { (response: NSURLResponse!, data: NSData!, error: NSError!) -> Void in
                let json = NSJSONSerialization.JSONObjectWithData(data, options: nil, error: nil) as? NSDictionary
                if let json = json {
                    self.movies = json["movies"] as? [NSDictionary]
                    self.moviesTableView.reloadData()
                    self.moviesCollectionView.reloadData()
                    SVProgressHUD.dismiss()
                }
            }
        }
    }

    @IBAction func toggleButtonClicked(sender: AnyObject) {
        view.endEditing(true)
        if moviesTableView.hidden {
            moviesCollectionView.hidden = true
            moviesTableView.reloadData()
            let toggleImage = UIImage(named: "iconmonstr-archive-3-icon-24.png")
            toggleButton.image = toggleImage
            moviesTableView.hidden = false
        } else {
            moviesTableView.hidden = true
            moviesCollectionView.reloadData()
            let toggleImage = UIImage(named: "iconmonstr-menu-icon-24.png")
            toggleButton.image = toggleImage
            moviesCollectionView.hidden = false
            view.endEditing(true)
        }
    }

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        view.endEditing(true)
        var movie: NSDictionary
        if moviesTableView.hidden {
            let cell = sender as! UICollectionViewCell
            let indexPath = moviesCollectionView.indexPathForCell(cell)!
            movie = movies![indexPath.item]
        } else {
            let cell = sender as! UITableViewCell
            let indexPath = moviesTableView.indexPathForCell(cell)!
            movie = movies![indexPath.row]
        }
        let movieDetailsViewController = segue.destinationViewController as! MovieDetailsViewController
        movieDetailsViewController.movie = movie
    }

}
