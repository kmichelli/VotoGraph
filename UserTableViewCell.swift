//
//  UserTableViewCell.swift
//  VotoGraph
//
//  Created by Kevin Michelli on 2/10/16.
//  Copyright © 2016 Kevin Michelli. All rights reserved.
//

import UIKit

class UserTableViewCell: PFTableViewCell {
    
    @IBOutlet weak var userLeftImageView:PFImageView?
    @IBOutlet weak var userRightImageView:PFImageView?
    @IBOutlet weak var userNameLabel:UILabel?
    @IBOutlet weak var userLeftVotesLabel:UILabel?
    @IBOutlet weak var userRightVotesLabel:UILabel?
    @IBOutlet weak var userTimeLabel:UILabel?
    @IBOutlet weak var greenCheckIcon:UIImageView?
    @IBOutlet weak var greenCheckIcon2:UIImageView?
    
    var parseLObject:PFObject?
    var parseRObject:PFObject?

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        let rightGesture = UISwipeGestureRecognizer(target: self, action:#selector(UserTableViewCell.rightSwipe(_:)))
        rightGesture.direction = UISwipeGestureRecognizerDirection.Right
        contentView.addGestureRecognizer(rightGesture)
        let leftGesture = UISwipeGestureRecognizer(target: self, action:#selector(UserTableViewCell.leftSwipe(_:)))
        leftGesture.direction = UISwipeGestureRecognizerDirection.Left
        contentView.addGestureRecognizer(leftGesture)

        
        greenCheckIcon?.hidden = true
        greenCheckIcon2?.hidden = true
    }

    func rightSwipe(sender: AnyObject) {
        greenCheckIcon2?.hidden = false
        greenCheckIcon2?.alpha = 1.0
        
        
        //*******Need to work on this to allow only one vote***** 
       /* var hasVotedQuery = PFQuery(className: "UserImage")
        hasVotedQuery.getObjectInBackgroundWithId("objectId") {
            
        }*/
    
        //var userObjectId = PFUser.currentUser()?.objectId as String!
        
        if(parseRObject != nil) {
            if var rightVotes:Int? = parseRObject!.objectForKey("rightVotes") as? Int {
                rightVotes! += 1
                 
                parseRObject!.setObject(rightVotes!, forKey: "rightVotes")
                parseRObject!.saveInBackground()
                
                userRightVotesLabel?.text = "\(rightVotes!) votes"
            }
        }
        
        UIView.animateWithDuration(1.0, delay: 1.0, options: [], animations: {
            
            self.greenCheckIcon2?.alpha = 0
            
            }, completion: {
                (value:Bool) in
                
                self.greenCheckIcon2?.hidden = true
        })

    }
    
    func leftSwipe(sender: AnyObject) {
        greenCheckIcon?.hidden = false
        greenCheckIcon?.alpha = 1.0
        
        if(parseLObject != nil) {
            if var leftVotes:Int? = parseLObject!.objectForKey("leftVotes") as? Int {
                leftVotes! += 1
                
                parseLObject!.setObject(leftVotes!, forKey: "leftVotes")
                parseLObject!.saveInBackground()
                
                userLeftVotesLabel?.text = "\(leftVotes!) votes"
            }
        }
        UIView.animateWithDuration(1.0, delay: 1.0, options: [], animations: {

            self.greenCheckIcon?.alpha = 0
            
            }, completion: {
                (value:Bool) in

                self.greenCheckIcon?.hidden = true
        })
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
