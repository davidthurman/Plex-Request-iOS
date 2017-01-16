//
//  MovieCell.swift
//  Plex Request
//
//  Created by David Thurman on 1/14/17.
//  Copyright © 2017 David Thurman. All rights reserved.
//

import UIKit
import Alamofire
class MovieCell: UITableViewCell {
    var delegate: UIViewController?
    @IBOutlet var movieTitle: UIButton!
    @IBOutlet var moviePoster: UIImageView!
    var movieDescription = ""
    var movieId = ""
    var movieDate = ""
    var type = ""
    @IBAction func addMovie(_ sender: AnyObject) {
        addMovie()
    }
    
    func success() {
        let alert = UIAlertController(title: "Request Sent", message: nil, preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "Done", style: UIAlertActionStyle.default, handler: nil))
        delegate?.present(alert, animated: true, completion: nil)
    }
    
    func addMovie() {
        SwiftSpinner.show("Submitting Request")
        let postUrl = "http://www.plex.dev/api/requests/submit"
        var parameters: [String: String] = [:]
        parameters["userId"] = "123"
        parameters["movieId"] = movieId
        parameters["type"] = type
        Alamofire.request(postUrl, method: .post, parameters: parameters, encoding: JSONEncoding.default)
            .responseJSON { response in
                if response.response == nil {
                    SwiftSpinner.hide()
                    self.fail()
                }
                else {
                    SwiftSpinner.hide()
                    self.success()
                }
        }
    }
    
    func fail() {
        let alert = UIAlertController(title: "No Connection", message: "Your request was unable to submit. Would you like to retry your submission or cancel?", preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "Retry", style: UIAlertActionStyle.default, handler: { action in self.addMovie()}))
        alert.addAction(UIAlertAction(title: "Cancel", style: .default, handler: nil))
        delegate?.present(alert, animated: true, completion: nil)
    }

    @IBAction func descriptionAction(_ sender: AnyObject) {
        var title = movieTitle.currentTitle
        var movieTemp = movieDate as NSString
        movieDate = movieTemp.substring(with: NSRange(location: 0, length: 4))
        let alert = UIAlertController(title: title! + " (" + movieDate + ")", message: movieDescription, preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "Done", style: UIAlertActionStyle.default, handler: nil))
        delegate?.present(alert, animated: true, completion: nil)
    }
}
