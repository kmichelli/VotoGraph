//
//  UserTableViewController.swift
//  VotoGraph
//
//  Created by Kevin Michelli on 1/28/16.
//  Copyright © 2016 Kevin Michelli. All rights reserved.
//

import UIKit

class UserTableViewController: PFQueryTableViewController {
    
    let cellIdentifier:String = "Cell"

    var endTime: NSDate?
    var countdownTime: String?
    
    override init(style: UITableViewStyle, className: String!) {
        super.init(style: style, className: className)
        
        self.pullToRefreshEnabled = true
        self.paginationEnabled = false
        self.objectsPerPage = 15
        
        self.parseClassName = className
        self.tableView.rowHeight = 380
        self.tableView.allowsSelection = false
    
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!

    }
    
   /* THIS disables the ability to be placed in a storyboard..
    required init(coder aDecoder:NSCoder)
    {
        fatalError("NSCoding not supported")
    }*/
    
    override func viewWillAppear(animated: Bool) {
        if (PFUser.currentUser() == nil) {
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                
                let viewController:UIViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("Login") as UIViewController
                self.presentViewController(viewController, animated: true, completion: nil)
            })
        }
    }

    override func viewDidLoad() {
        tableView.registerNib(UINib(nibName: "UserTableViewCell", bundle: nil), forCellReuseIdentifier: cellIdentifier)
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        //Set the time limit for the timer
        let fifteenMinutes = NSTimeInterval(60 * 15)
        endTime = NSDate(timeIntervalSinceNow: fifteenMinutes)
        scheduleTimer()
        
        //Adds button to navigation bar to go to home view
        let btnName = UIButton()
        btnName.setImage(UIImage(named: "IconHomeSelected.png"), forState: .Normal)
        btnName.frame = CGRectMake(0, 0, 30, 30)
        btnName.addTarget(self, action: #selector(UserTableViewController.goHome), forControlEvents: .TouchUpInside)
        let rightBarButton = UIBarButtonItem()
        rightBarButton.customView = btnName
        self.navigationItem.rightBarButtonItem = rightBarButton
    }
    
    func goHome() {
        let viewController:UIViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("Home")
        self.presentViewController(viewController, animated: true, completion: nil)
    }

    //start the timer
    func scheduleTimer() {
        NSTimer.scheduledTimerWithTimeInterval(1.0 / 30.0, target: self, selector: #selector(UserTableViewController.tick(_:)), userInfo: nil, repeats: true)
    }
    
    //Called to reload time left on timer
    //**********TIMER ISSUE: updating all cells with same time***********
    //*****Remove the reloadData. Make own class to call from********
    //****Try using a query to get createdAt time or other object*****
    @objc
    func tick(timer: NSTimer) {
        guard let endTime = endTime else{
            return
        }
        let calendar = NSCalendar(calendarIdentifier: NSCalendarIdentifierGregorian)
        if let components = calendar?.components([.Minute, .Second], fromDate: NSDate(), toDate: endTime, options: []) {
            countdownTime = formatDateComponents(components)
        }
        //Updates the label for time in the cell
        self.tableView.reloadData()
    }
    
    //Formats the time in 00:00
    func formatDateComponents(components: NSDateComponents) -> String {
        let timeLeft = NSCalendar.currentCalendar().dateFromComponents(components)!
        let formatter = NSDateFormatter()
        formatter.dateFormat = "mm:ss"
        let timeString = formatter.stringFromDate(timeLeft)
        return timeString
    }
    
    override func queryForTable() -> PFQuery {
        let query:PFQuery = PFQuery(className: self.parseClassName!)
        
        if(objects?.count == 0)
        {
            query.cachePolicy = PFCachePolicy.CacheThenNetwork
        }
        
        query.orderByAscending("createdAt")
        
        return query
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath, object: PFObject?) -> PFTableViewCell? {
        
        
        var cell:UserTableViewCell? = (tableView.dequeueReusableCellWithIdentifier(cellIdentifier) as? UserTableViewCell)
        
        if(cell==nil) {
            cell = NSBundle.mainBundle().loadNibNamed("UserTableViewCell", owner: self, options: nil)[0] as? UserTableViewCell
        }
        
        cell?.parseLObject = object
        cell?.parseRObject = object
        
        if let pfObject = object {
            
            //******Switch to username from the User class*********
            cell?.userNameLabel?.text = pfObject["name"] as? String
            
            var leftVotes:Int? = pfObject["leftVotes"] as? Int
            if leftVotes == nil {
                leftVotes = 0
            }
            
            var rightVotes:Int? = pfObject["rightVotes"] as? Int
            if rightVotes == nil {
                rightVotes = 0
            }
            

            cell?.userLeftVotesLabel?.text = "\(leftVotes!) votes"
            cell?.userRightVotesLabel?.text = "\(rightVotes!) votes"
           
            //Time left for the voting
            cell?.userTimeLabel?.text = countdownTime

            //Displays the pictures side by side
            let defaultLeftPicture = UIImage(named: "PlaceholderPhoto.png")
            cell?.userLeftImageView?.image = defaultLeftPicture
            if let leftPicture = pfObject["leftImage"] as? PFFile {
                cell?.userLeftImageView?.file = leftPicture
                cell?.userLeftImageView?.loadInBackground()
            }
            
            let defaultRightPicture = UIImage(named: "PlaceholderPhoto.png")
            cell?.userRightImageView?.image = defaultRightPicture
            if let rightPicture = pfObject["rightImage"] as? PFFile {
                cell?.userRightImageView?.file = rightPicture
                cell?.userRightImageView?.loadInBackground()
            }

        }
        
        return cell
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
