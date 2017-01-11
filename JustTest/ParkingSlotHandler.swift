//
//  ParkingSlotHandler.swift
//  JustTest
//
//  Created by Nicholas Allio on 13/10/2016.
//  Copyright © 2016 Nicholas Allio. All rights reserved.
//

import UIKit
import MapKit

class ParkingSlotHandler: NSObject {
    
    fileprivate let session = URLSession.shared
    fileprivate let baseURL = "https://api.justpark.com/apiv3/search/region"
    
    let currentPosition = CLLocationCoordinate2D(latitude: CLLocationDegrees(51.5560241), longitude: CLLocationDegrees(-0.2817075))
    let distanceFromCurrentPosition = 100
    
    var parkingSlots = [ParkingSlot]()
    
    func getPins(_ completion: @escaping (([ParkingSlot]?) -> ())) {
        let url = URL(string: baseURL)
        var request = URLRequest(url: url!)
        request.httpMethod = "POST"
        
        let json = ["near" : ["lat" : "\(self.currentPosition.latitude)", "lng" : "\(self.currentPosition.longitude)", "distance" : "\(self.distanceFromCurrentPosition)"]]
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: json, options: .prettyPrinted)
            request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
            request.httpBody = jsonData
        } catch {
            completion(nil)
        }
                
        let task = self.session.dataTask(with: request) { (data, response, error) in
            guard (error == nil) else {
                completion(nil)
                return
            }
            
            guard let statusCode = (response as? HTTPURLResponse)?.statusCode, statusCode >= 200 && statusCode <= 299 else {
                completion(nil)
                return
            }
            
            guard let data = data else {
                completion(nil)
                return
            }
                        
            do {
                let jsonData = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as! [String:AnyObject]
                let locationList = jsonData["data"] as! [[String:AnyObject]]
                for loc in locationList {
                    self.parkingSlots.append(ParkingSlot(dictionary: loc))
                }
                
                completion(self.parkingSlots)
                
            } catch {
                completion(nil)
            }
        }
        task.resume()
    }

}
