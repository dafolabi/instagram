//
//  ProfileViewController.swift
//  instagram
//
//  Created by Daniel Afolabi on 6/27/17.
//  Copyright © 2017 Daniel Afolabi. All rights reserved.
//

import UIKit
import Parse
import ParseUI

class ProfileViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    var posts: [PFObject]? = []
    
    var refreshControl: UIRefreshControl!
    
    var isMoreDataLoading = false
    var loadingMoreView:InfiniteScrollActivityView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView.delegate = self
        collectionView.dataSource = self
        
        refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(HomeViewController.didPullToRefresh(_:)), for: .valueChanged)
        collectionView.insertSubview(refreshControl, at: 0)
        
        
        // Do any additional setup after loading the view.
        // Set up Infinite Scroll loading indicator
        let frame = CGRect(x: 0, y: collectionView.contentSize.height, width: collectionView.bounds.size.width, height: InfiniteScrollActivityView.defaultHeight)
        loadingMoreView = InfiniteScrollActivityView(frame: frame)
        loadingMoreView!.isHidden = true
        collectionView.addSubview(loadingMoreView!)
        
        var insets = collectionView.contentInset
        insets.bottom += InfiniteScrollActivityView.defaultHeight
        collectionView.contentInset = insets
        
        
        let layout = collectionView.collectionViewLayout as! UICollectionViewFlowLayout
        layout.minimumLineSpacing = layout.minimumInteritemSpacing
        let cellsPerLine: CGFloat = 3;
        let interItemSpacingTotal = layout.minimumInteritemSpacing * (cellsPerLine - 1)
        let width = collectionView.frame.size.width / cellsPerLine - interItemSpacingTotal / cellsPerLine
        layout.itemSize = CGSize(width: width, height: width * 3 / 2)
        
        refresh()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func didHitLogoutButton(_ sender: Any) {
        PFUser.logOutInBackground { (error: Error?) in
            // PFUser.currentUser() will now be nil
            // check if user is logged in.
            if let error = error {
                print(error.localizedDescription)
            } else {
                // if there is a logged in user then load the home view controller
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let LoginViewController = storyboard.instantiateViewController(withIdentifier: "LoginViewController")
                // self.dismiss(animated: true, completion: nil)
                self.present(LoginViewController, animated: true, completion: {

                })
            }
        }
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return (posts?.count)!
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "profileCell", for: indexPath) as! profileCell
        let post = self.posts![indexPath.row]
        
        cell.profileImageView.file = post["media"] as? PFFile
        print("cell updated")
        
        return cell
    }
    
    func refresh(withLimit limit: Int = 20) {
        // construct PFQuery
        var query = PFQuery(className: "Post")
        query.order(byDescending: "createdAt")
        query.includeKey("author")
        query.limit = limit
        
        // fetch data asynchronously
        query.findObjectsInBackground { (posts: [PFObject]?, error: Error?) -> Void in
            if let posts = posts {
                self.posts = posts
                print("is refreshing")
                self.collectionView.reloadData()
            } else {
                print(error?.localizedDescription)
            }
        }
        
        // Update flag
        self.isMoreDataLoading = false
        
        // Stop the loading indicator
        self.loadingMoreView!.stopAnimating()

        
        // Reload the tableView now that there is new data
        self.collectionView.reloadData()
    }
    
    func didPullToRefresh(_ refreshControl: UIRefreshControl) {
        refresh()
        collectionView.reloadData()
        refreshControl.endRefreshing()
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if (!isMoreDataLoading) {
            // Calculate the position of one screen length before the bottom of the results
            let scrollViewContentHeight = collectionView.contentSize.height
            let scrollOffsetThreshold = scrollViewContentHeight - collectionView.bounds.size.height
            
            // When the user has scrolled past the threshold, start requesting
            if(scrollView.contentOffset.y > scrollOffsetThreshold && collectionView.isDragging) {
                isMoreDataLoading = true
                
                // Update position of loadingMoreView, and start loading indicator
                let frame = CGRect(x: 0, y: collectionView.contentSize.height, width: collectionView.bounds.size.width, height: InfiniteScrollActivityView.defaultHeight)
                loadingMoreView?.frame = frame
                loadingMoreView!.startAnimating()
                
                // Code to load more results
                refresh(withLimit: (posts?.count)! + 20)
            }
        }
    }
    
    class InfiniteScrollActivityView: UIView {
        var activityIndicatorView: UIActivityIndicatorView = UIActivityIndicatorView()
        static let defaultHeight:CGFloat = 60.0
        
        required init?(coder aDecoder: NSCoder) {
            super.init(coder: aDecoder)
            setupActivityIndicator()
        }
        
        override init(frame aRect: CGRect) {
            super.init(frame: aRect)
            setupActivityIndicator()
        }
        
        override func layoutSubviews() {
            super.layoutSubviews()
            activityIndicatorView.center = CGPoint(x: self.bounds.size.width/2, y: self.bounds.size.height/2)
        }
        
        func setupActivityIndicator() {
            activityIndicatorView.activityIndicatorViewStyle = .gray
            activityIndicatorView.hidesWhenStopped = true
            self.addSubview(activityIndicatorView)
        }
        
        func stopAnimating() {
            self.activityIndicatorView.stopAnimating()
            self.isHidden = true
        }
        
        func startAnimating() {
            self.isHidden = false
            self.activityIndicatorView.startAnimating()
        }
    }
    
    
    
    
     // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let cell = sender as! UICollectionViewCell
        if let indexPath = collectionView.indexPath(for: cell) {
            let post = posts?[indexPath.row]
            let detailViewController = segue.destination as! DetailViewController
            detailViewController.post = post
        }
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }

}
