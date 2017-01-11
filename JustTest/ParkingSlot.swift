//
//  ParkingSlot.swift
//  JustTest
//
//  Created by Nicholas Allio on 13/10/2016.
//  Copyright © 2016 Nicholas Allio. All rights reserved.
//

import UIKit
import MapKit

class ParkingSlot: NSObject, MKAnnotation {
    
    var coordinate: CLLocationCoordinate2D
    var title: String?
    var priceHour: Double?
    var reviewAverage: Double?
    
    init(dictionary: [String:AnyObject]) {
        
        self.coordinate = CLLocationCoordinate2D(latitude: CLLocationDegrees(dictionary["address_lat"] as? Double ?? 0), longitude: CLLocationDegrees(dictionary["address_lng"] as? Double ?? 0))
        self.title = dictionary["custom_title"] as? String ?? "Parking Slot"
        self.priceHour = dictionary["price_hour"] as? Double ?? -1
                
        self.reviewAverage = dictionary["review_average"] as? Double ?? -1
        
    }

}
