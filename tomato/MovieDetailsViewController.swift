//
//  MovieDetailsViewController.swift
//  tomato
//
//  Created by Ho-Hsiang Wu on 4/18/15.
//  Copyright (c) 2015 muspaper. All rights reserved.
//

import UIKit

class MovieDetailsViewController: UIViewController {

    @IBOutlet weak var backgroundImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var synopsisLabel: UILabel!
    @IBOutlet weak var titleNavigationItem: UINavigationItem!

    var movie: NSDictionary!

    override func viewDidLoad() {
        super.viewDidLoad()

        titleLabel.text = movie["title"] as? String
        titleNavigationItem.title = movie["title"] as? String
        synopsisLabel.text = movie["synopsis"] as? String
        var urlString = movie.valueForKeyPath("posters.original") as! String
        var range = urlString.rangeOfString(".*cloudfront.net/", options: .RegularExpressionSearch)
        if let range = range {
            urlString = urlString.stringByReplacingCharactersInRange(range, withString: "https://content6.flixster.com/")
        }
        let url = NSURL(string: urlString)
        backgroundImageView.setImageWithURL(url)
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
