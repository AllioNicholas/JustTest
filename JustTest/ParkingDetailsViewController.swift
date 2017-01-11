//
//  ParkingDetailsViewController.swift
//  JustTest
//
//  Created by Nicholas Allio on 14/10/2016.
//  Copyright © 2016 Nicholas Allio. All rights reserved.
//

import UIKit

class ParkingDetailsViewController: UIViewController {
    
    @IBOutlet weak var titleParkingLabel: UILabel!
    @IBOutlet weak var fareParkingLabel: UILabel!
    @IBOutlet weak var reviewParkingLabel: UILabel!
    @IBOutlet weak var directionsButton: UIButton!
    
    @IBOutlet weak var walkMeThereLabel: UILabel!

    @IBOutlet weak var directionsLabel: UILabel!
    
    var parkingSlot: ParkingSlot?
    let fullView = CGFloat(100)
    var partialView : CGFloat {
        get {
            return UIScreen.main.bounds.height - UIApplication.shared.statusBarFrame.height - reviewParkingLabel.frame.maxY
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.layer.cornerRadius = 10.0
        self.view.clipsToBounds = true
        
        // Do any additional setup after loading the view.
        let blurBackground = UIVisualEffectView(effect: UIBlurEffect(style: .light))
        blurBackground.frame = self.view.bounds
        
        self.view.insertSubview(blurBackground, at: 0)
    }
    
    @IBAction func closeDetails(_ sender: AnyObject) {
        removeGestureRecognizer()
        (self.parent as! ParkingMapViewController).map.deselectAnnotation(parkingSlot, animated: true)
        (self.parent as! ParkingMapViewController).removeDetailView()
    }
    
    @IBAction func getWalkingDirections(_ sender: AnyObject) {
        addGestureRecognizer()
        (self.parent as! ParkingMapViewController).displayWalkingDirections(to: self.parkingSlot!.coordinate)
    }
    
    func setupUIAccording(to parking: ParkingSlot?) {
        if let park = parking {
            titleParkingLabel.text = park.title
            directionsButton.isHidden = false
            fareParkingLabel.isHidden = false
            reviewParkingLabel.isHidden = false
            walkMeThereLabel.isHidden = false
            directionsLabel.isHidden = true
            fareParkingLabel.text = park.priceHour! >= 0 ? "Price: \(park.priceHour!) £ per hour " : "Price: -.- £ per hour "
            reviewParkingLabel.text = park.reviewAverage! >= 0 ? "Review average: \(park.reviewAverage!)" : "Review average: -"
            self.parkingSlot = park
        } else {
            titleParkingLabel.text = "Your initial location"
            directionsButton.isHidden = true
            fareParkingLabel.isHidden = true
            reviewParkingLabel.isHidden = true
            walkMeThereLabel.isHidden = true
            directionsLabel.isHidden = true
        }
    }
    
    func displayDirections(with steps: String) {
        directionsLabel.isHidden = false
        directionsLabel.text = steps
    }
    
    func handleGesture(recognizer: UIPanGestureRecognizer) {
        let translation = recognizer.translation(in: self.view)
        let y = self.view.frame.minY
        if (y + translation.y >= fullView) && (y + translation.y <= partialView) {
            self.view.frame = CGRect(x: 0, y: y + translation.y, width: view.frame.width, height: view.frame.height)
            recognizer.setTranslation(CGPoint.zero, in: self.view)
        }
        
    }
    
    func addGestureRecognizer() {
        let gesture = UIPanGestureRecognizer(target: self, action: #selector(handleGesture))
        self.view.addGestureRecognizer(gesture)
    }
    
    func removeGestureRecognizer() {
        if let recognizers = self.view.gestureRecognizers {
            for rec in recognizers {
                self.view.removeGestureRecognizer(rec)
            }
        }
    }
}
