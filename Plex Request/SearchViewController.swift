//
//  SearchViewController.swift
//  Plex Request
//
//  Created by David Thurman on 1/9/17.
//  Copyright © 2017 David Thurman. All rights reserved.
//

import UIKit
import SwiftyJSON
import Alamofire
import SwiftGif

class SearchViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet var searchIcon: UIButton!
    @IBOutlet var tableView: UITableView!
    @IBOutlet var typeSwitch: UISegmentedControl!
    @IBOutlet var searchBar: UITextField!
    var timeoutTracker = 0
    var items: [[String:String]] = []
    var count = 1
    var tempType = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if tableView.isHidden == false {
            tableView.isHidden = true
        }
        
        //let loadingGif = UIImage.gif(name: "loading.gif")
        //loadingImageView.image
        
        // Do any additional setup after loading the view, typically from a nib.
        
        self.tableView.register(MovieCell.self, forCellReuseIdentifier: "cell")
        self.tableView.delegate = self
        self.tableView.dataSource = self
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func search(_ sender: AnyObject) {
        print(typeSwitch.selectedSegmentIndex)
        print(searchBar.text!)
        if searchBar.text! != "" {
            searchCall()
        }
        
    }
    
    func invalidInput() {
        
    }
        
    func searchCall() {
        self.items = []
        var type = ""
        var loadingMessage = ""
        if typeSwitch.selectedSegmentIndex == 0 {
            type = "movie"
            loadingMessage = "Fetching Movies"
        }
        else {
            type = "tv"
            loadingMessage = "Fetching Shows"
        }
        tempType = type
        var url = searchBar.text!.replacingOccurrences(of: " ", with: "-", options: .literal, range: nil)
        if url.range(of: "#") != nil || url.range(of: "%") != nil || url.range(of: "^") != nil || (url.range(of: "\\") != nil) || url.range(of: "`") != nil{
            let alert = UIAlertController(title: "Invalid Input", message: nil, preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "Done", style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
        else {
            SwiftSpinner.show(loadingMessage)
            Alamofire.request("http://www.plex.dev/api/search/" + type + "/" + url).responseJSON { response in
                debugPrint(response)
                if response.response == nil {
                    SwiftSpinner.hide()
                    self.popUp()

                }
                else {
                    if type == "movie" {
                        if let json = response.result.value {
                            let jsonTest = JSON(json)
                            for x in jsonTest["results"] {
                                if let title = x.1["title"].string{
                                    if let url = x.1["poster_path"].string {
                                        if let description = x.1["overview"].string {
                                            if let movieDate = x.1["release_date"].string {
                                                let stringId = String(describing: x.1["id"])
                                                let movieArray: [String : String] = ["title" : title, "url" : url, "id" : stringId, "description" : description, "date" : movieDate]
                                                self.items.append(movieArray)
                                                SwiftSpinner.hide()
                                                self.tableView.reloadData()
                                            }
                                        }
                                        
                                    }
                                }
                            }
                        }
                    }
                    else {
                        if let json = response.result.value {
                            let jsonTest = JSON(json)
                            for x in jsonTest["results"] {
                                if let title = x.1["name"].string{
                                    if let url = x.1["poster_path"].string {
                                        if let description = x.1["overview"].string {
                                            if let movieDate = x.1["first_air_date"].string {
                                                let stringId = String(describing: x.1["id"])
                                                let movieArray: [String : String] = ["title" : title, "url" : url, "id" : stringId, "description" : description, "date" : movieDate]
                                                self.items.append(movieArray)
                                                SwiftSpinner.hide()
                                                self.tableView.reloadData()
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
                
                
            }
        }
    }
    
    func popUp() {
        let alert = UIAlertController(title: "No Connection", message: "Your request was unable to submit. Would you like to retry your connection or cancel?", preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "Retry", style: UIAlertActionStyle.default, handler: { action in self.searchCall()}))
        alert.addAction(UIAlertAction(title: "Cancel", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    func tableView(_ tableView:UITableView, numberOfRowsInSection section:Int) -> Int
    {
        return self.items.count
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int
    {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        tableView.isHidden = false
        var movieCell = tableView.dequeueReusableCell(withIdentifier: "movieCell") as! MovieCell
        movieCell.delegate = self
        movieCell.movieDescription = self.items[indexPath.row]["description"]!
        movieCell.movieDate = self.items[indexPath.row]["date"]!
        movieCell.movieTitle?.setTitle(self.items[indexPath.row]["title"], for: .normal)
        movieCell.movieTitle?.contentHorizontalAlignment = .left
        movieCell.type = self.tempType
        print(movieCell.movieTitle!)
        let url = URL(string: "https://image.tmdb.org/t/p/w500" + self.items[indexPath.row]["url"]!)
        let data = try? Data(contentsOf: url!)
        movieCell.moviePoster?.image = UIImage(data: data!)
        movieCell.movieId = self.items[indexPath.row]["id"]!
        movieCell.backgroundColor = UIColor.clear
        return movieCell
    }

    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        print("You selected cell #\(indexPath.row)!")
    }
    
    func descriptionPopup(title: String, movieDescription: String) {
        let alert = UIAlertController(title: title, message: movieDescription, preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "Click", style: UIAlertActionStyle.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
}
