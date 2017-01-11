//
//  ParkingMapViewController.swift
//  JustTest
//
//  Created by Nicholas Allio on 13/10/2016.
//  Copyright © 2016 Nicholas Allio. All rights reserved.
//

import UIKit
import MapKit

class ParkingMapViewController: UIViewController, MKMapViewDelegate {

    @IBOutlet weak var map: MKMapView!
    
    var detailVC: ParkingDetailsViewController?
    let parkingHandler = ParkingSlotHandler()
    
    override func viewDidLoad() {
        super.viewDidLoad()
                
        self.map.delegate = self
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        
        let initialLocation = MKCoordinateRegionMakeWithDistance(parkingHandler.currentPosition, CLLocationDistance(1000), CLLocationDistance(1000))
        let initialLocationPin = MKPointAnnotation()
        initialLocationPin.coordinate = parkingHandler.currentPosition
        DispatchQueue.main.async {
            self.map.setRegion(initialLocation, animated: true)
            self.map.addAnnotation(initialLocationPin)
        }
        
        loadLocations()
    }
    
    func loadLocations() {
        parkingHandler.getPins { (result) in
            if let result = result {
                DispatchQueue.main.async {
                    self.map.showAnnotations(result, animated: true)
                    UIApplication.shared.isNetworkActivityIndicatorVisible = false
                }
            } else {
                let alert = UIAlertController(title: "Error", message: "An error occurred while downloading your locations.\nCheck your connection and retry.", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Ok", style: .cancel, handler: { (action) in
                    self.loadLocations()
                }))
                self.present(alert, animated: true, completion: nil)
            }
        }
    }
    
    func addDetailView(sender: MKAnnotation) {
        if detailVC == nil {
            detailVC = self.storyboard?.instantiateViewController(withIdentifier: "parkingDetail") as? ParkingDetailsViewController
            self.addChildViewController(detailVC!)
            self.view.addSubview(detailVC!.view)
            detailVC?.view.frame = CGRect(x: 0, y: self.view.frame.maxY, width: view.frame.width, height: view.frame.height)
        }
        
        if sender.isMember(of: MKPointAnnotation.self) {
            detailVC?.setupUIAccording(to: nil)
        } else {
            let park = sender as! ParkingSlot
            detailVC?.setupUIAccording(to: park)
        }
        
        UIView.animate(withDuration: 0.5) { [weak self] in
            let frame = self?.detailVC!.view.frame
            let yComponent = UIScreen.main.bounds.height - 200
            self?.detailVC!.view.frame = CGRect(x: 0, y: yComponent, width: frame!.width, height: frame!.height)
        }
    }
    
    func removeDetailView() {
        self.map.removeOverlays(self.map.overlays)
        if detailVC != nil {
            UIView.animate(withDuration: 0.2) { [weak self] in
                let frame = self?.detailVC!.view.frame
                let yComponent = UIScreen.main.bounds.height
                self?.detailVC!.view.frame = CGRect(x: 0, y: yComponent, width: frame!.width, height: frame!.height)
            }
        }
    }
    
    func displayWalkingDirections(to: CLLocationCoordinate2D) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        let request = MKDirectionsRequest()
        request.source = MKMapItem(placemark: MKPlacemark(coordinate: self.parkingHandler.currentPosition))
        request.destination = MKMapItem(placemark: MKPlacemark(coordinate: to))
        request.transportType = .walking
        
        let directions = MKDirections(request: request)
        directions.calculate { (response, error) in
            if error == nil && response != nil {
                if let route = response?.routes.first {
                    DispatchQueue.main.async {
                        self.map.add(route.polyline)
            
                        var routeRect = route.polyline.boundingMapRect
                    
                        let wPadding = routeRect.size.width * 0.25
                        let hPadding = routeRect.size.height * 0.25
                        
                        routeRect.size.width += wPadding
                        routeRect.size.height += hPadding
                        
                        routeRect.origin.x -= wPadding / 2
                        routeRect.origin.y -= hPadding / 2
                        
                        self.map.setRegion(MKCoordinateRegionForMapRect(routeRect), animated: true)
                        
                        var stepsString = ""
                        for step in route.steps {
                            stepsString += "🗺 \(step.instructions)\n"
                        }
                        self.detailVC?.displayDirections(with: stepsString)
                        
                        UIApplication.shared.isNetworkActivityIndicatorVisible = false
                    }
                    
                }
            } else {
                let alert = UIAlertController(title: "Error", message: "An error occurred while calculating walking directions.", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Ok", style: .cancel, handler: nil))
                self.present(alert, animated: true, completion: nil)
            }
        }
    }
    
    // MARK: - Map view delegate

    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if let annotation = annotation as? ParkingSlot {
            let identifier = "parkingPin"
            var annotationView: MKPinAnnotationView
            if let dequeuedView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier) as? MKPinAnnotationView {
                dequeuedView.annotation = annotation
                annotationView = dequeuedView
            } else {
                annotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: identifier)
                annotationView.canShowCallout = false
                annotationView.animatesDrop = true
                annotationView.pinTintColor = UIColor.blue
            }
            return annotationView
        }
        return nil
    }
    
    func mapView(_ mapView: MKMapView, didDeselect view: MKAnnotationView) {
        removeDetailView()
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        let parkingLocation = MKCoordinateRegionMakeWithDistance(view.annotation!.coordinate, CLLocationDistance(1000), CLLocationDistance(1000))
        DispatchQueue.main.async {
            self.map.setRegion(parkingLocation, animated: true)
        }
        removeDetailView()
        addDetailView(sender: view.annotation!)
    }
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let renderer = MKPolylineRenderer(overlay: overlay)
        renderer.strokeColor = UIColor.blue
        renderer.lineWidth = 4
        return renderer
    }
    
}

