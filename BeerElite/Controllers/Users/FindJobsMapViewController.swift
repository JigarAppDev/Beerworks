//
//  FindJobsMapViewController.swift
//  BeerElite
//
//  Created by Jigar on 22/12/21.
//  Copyright © 2021 Jigar. All rights reserved.
//

import UIKit
import NVActivityIndicatorView
import SwiftyJSON
import Kingfisher
import MapKit

class FindJobsMapViewController: UIViewController, NVActivityIndicatorViewable, MKMapViewDelegate {
    
    @IBOutlet var mapView: MKMapView!
    
    var jobList = [JobsDataModel]()
    var locationArray = [CLLocation]()
    var isFrom = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        var lati = 21.282778
        var longi = -157.829444
        if jobList.count > 0 {
            lati = jobList.first?.latitude ?? 21.282778
            longi = jobList.first?.longitude ?? -157.829444
            
            locationArray.removeAll()
            //get all location
            for obj in jobList {
                if obj.latitude != nil && obj.longitude != nil {
                    locationArray.append(CLLocation(latitude: obj.latitude!, longitude: obj.longitude!))
                    
                    // Drop a pin
                    let location = CLLocationCoordinate2DMake(obj.latitude!, obj.longitude!)
                    let dropPin = MKPointAnnotation()
                    dropPin.coordinate = location
                    dropPin.title = obj.jobTitle
                    dropPin.subtitle = obj.jobId
                    self.mapView.addAnnotation(dropPin)
                }
            }
        }
        // Set initial location
        let initialLocation = CLLocation(latitude: lati, longitude: longi)
        mapView.centerToLocation(initialLocation)
    }
    
    
    // MARK: - Back Click
    @IBAction func btnBackClick(sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        guard let jobId = view.annotation?.subtitle else { return }
        let obj = self.jobList.filter { (job) -> Bool in
            return job.jobId == jobId
        }
        if obj != nil {
            let detailsVC = self.storyboard?.instantiateViewController(withIdentifier: "JobDetailsViewController") as! JobDetailsViewController
            detailsVC.dataObj = obj.first
            detailsVC.isFrom = self.isFrom
            self.navigationController?.pushViewController(detailsVC, animated: true)
        }
    }
    
}

private extension MKMapView {
    func centerToLocation(
        _ location: CLLocation,
        regionRadius: CLLocationDistance = 10000
    ) {
        let coordinateRegion = MKCoordinateRegion(
            center: location.coordinate,
            latitudinalMeters: regionRadius,
            longitudinalMeters: regionRadius)
        setRegion(coordinateRegion, animated: true)
    }
}
