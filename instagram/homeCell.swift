//
//  homeCell.swift
//  instagram
//
//  Created by Daniel Afolabi on 6/28/17.
//  Copyright © 2017 Daniel Afolabi. All rights reserved.
//

import UIKit
import ParseUI

class homeCell: UITableViewCell {
    
    @IBOutlet weak var photoView: PFImageView!
    @IBOutlet weak var photoCaption: UILabel!
    
    
    var instagramPost: PFObject! {
        didSet {
            self.photoView.file = instagramPost["media"] as? PFFile
            
            let tempCaption = instagramPost["caption"] as! String
            
            let author = instagramPost["author"] as! PFUser
            self.photoCaption.text = author.username! + ": " + tempCaption
            
            
            self.photoView.loadInBackground()
        }
    }
    
    @IBAction func didHitSting(_ sender: Any) {
            instagramPost?["likesCount"] = instagramPost?["likesCount"] as! Int + 1
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
