//
//  ViewController.swift
//  CLVisitDemo
//
//  Created by trvslhlt on 2/24/15.
//  Copyright (c) 2015 travis holt. All rights reserved.
//

import UIKit
import CoreLocation

class ViewController: UIViewController {

  @IBOutlet weak var textView: UITextView!
  @IBOutlet weak var manualLoggingButton: UIButton!
  
  let departingTitle = "Departing"
  let arrivingTitle = "Arriving"
  
  override func viewDidLoad() {
    super.viewDidLoad()
    NSNotificationCenter.defaultCenter().addObserver(self, selector: "locationDataUpdated", name: LocationDelegate.locationDataUpdatedNotification, object: nil)
    manualLoggingButton.setTitle(arrivingTitle, forState: UIControlState.Normal)
  }
  
  override func viewDidAppear(animated: Bool) {
    super.viewDidAppear(animated)
    self.textView.text = LocationDelegate.sharedInstance.locationDataToString()
  }
  
  func refreshTextView() {
    self.textView.text = LocationDelegate.sharedInstance.locationDataToString()
  }

  func locationDataUpdated() {
    refreshTextView()
  }
  
  // MARK: IBAction
  @IBAction func manualLoggingButtonTapped(sender: UIButton) {
    if let title = sender.titleLabel?.text {
      if title == arrivingTitle {
        LocationDelegate.sharedInstance.manuallyLogCurrentLocation(arriving: true)
        manualLoggingButton.setTitle(departingTitle, forState: UIControlState.Normal)
      } else {
        LocationDelegate.sharedInstance.manuallyLogCurrentLocation(arriving: false)
        manualLoggingButton.setTitle(arrivingTitle, forState: UIControlState.Normal)
      }
    }
  }
  
}












