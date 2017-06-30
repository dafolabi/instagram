//
//  DetailViewController.swift
//  instagram
//
//  Created by Daniel Afolabi on 6/29/17.
//  Copyright © 2017 Daniel Afolabi. All rights reserved.
//

import UIKit
import Parse
import ParseUI

class DetailViewController: UIViewController {

    @IBOutlet weak var detailImageView: PFImageView!
    
    @IBOutlet weak var detailphotoCaption: UILabel!
    
    @IBOutlet weak var detailAuthor: UILabel!
    
    @IBOutlet weak var detailTimestamp: UILabel!
    
    var post: PFObject!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        detailImageView.file = post["media"] as? PFFile
        detailphotoCaption.text = post["caption"] as! String
        
        let author = post["author"] as! PFUser
        detailAuthor.text = "username: " + author.username!
        
        if let date = post.createdAt {
            let dateFormatter = DateFormatter()
            dateFormatter.dateStyle = .short
            dateFormatter.timeStyle = .short
            let dateString = dateFormatter.string(from: date)
            detailTimestamp.text = "Date: " + dateString
            print(dateString) // Prints: Jun 28, 2017, 2:08 PM
        }
        
        detailImageView.loadInBackground()
        
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
