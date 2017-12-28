//
//  ViewController.swift
//  SwiftWeather
//
//  Created by Kassem Itani on 12/28/17.
//  Copyright © 2017 kassem Itani. All rights reserved.
//

import UIKit
import Alamofire
import CoreLocation
import GooglePlaces
import GoogleMaps


class ViewController: UIViewController, CLLocationManagerDelegate {

    @IBOutlet var lblCityName: UILabel!
    @IBOutlet var lblWeatherSummary: UILabel!
    @IBOutlet var lblWeatherDegrees: UILabel!
    let APIKEY = "3962ffa8c0a12cbe2bc27a120e602ee5"
    let BASEURL = "https://api.openweathermap.org/data/2.5/"
    let WEATHER = "weather?"
    var lat = 0.0
    var lng = 0.0
    var units = "metric"
    var unit = "C"
    var locationManager = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        requestLocationPermision()
    }    
    
    func requestLocationPermision() {
        
        self.locationManager.requestWhenInUseAuthorization()
        self.locationManager.delegate = self
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
        self.locationManager.startUpdatingLocation()
    }
    
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.first {
            lat = location.coordinate.latitude
            lng = location.coordinate.longitude
            loadCurrentWeather()
//            manager.stopUpdatingLocation()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        if CLLocationManager.locationServicesEnabled() {
            switch(CLLocationManager.authorizationStatus()) {
            case .notDetermined, .restricted, .denied:
                showAlert("Please Allow the Location Permision to get weather of your city")
            case .authorizedAlways, .authorizedWhenInUse:
                print("locationEnabled")
            }
        } else {
            showAlert("Please Turn ON the location services on your device")
            print("locationDisabled")
        }
        manager.stopUpdatingLocation()
    }
    
    
    
    class func isLocationEnabled() -> (status: Bool, message: String) {
        if CLLocationManager.locationServicesEnabled() {
            switch(CLLocationManager.authorizationStatus()) {
            case .notDetermined, .restricted, .denied:
                return (false,"No access")
            case .authorizedAlways, .authorizedWhenInUse:
                return(true,"Access")
            }
        } else {
            return(false,"Turn On Location Services to Allow App to Determine Your Location")
        }
    }
    
    
    func loadCurrentWeather() {
        let url = "\(BASEURL)\(WEATHER)lat=\(lat)&lon=\(lng)&appid=\(APIKEY)&units=\(units)"
        
        Alamofire.request(url).responseJSON { response in
            if let json = response.result.value as? [String: Any] {
                if let weather = json["weather"] as? [[String:Any]]   {
                    if let main = weather[0]["main"] as? String {
                        print("main=\(main)")
                        self.lblWeatherSummary.text = main
                    }
                    if let description = weather[0]["description"] as? String {
                        print("description=\(description)")
                        self.lblWeatherSummary.text = "\(self.lblWeatherSummary.text!), \(description)"
                    }
                }
                
                if let main = json["main"] as? [String:Any]   {
                    if let temp = main["temp"] as? NSNumber {
                        print("temp=\(temp)")
                        self.lblWeatherDegrees.text = "\(temp) \(self.unit)"
                    }
                    if let temp_max = main["temp_max"] as? NSNumber, let temp_min = main["temp_min"] as? NSNumber {
                        print("temp_max=\(temp_max) and temp_min=\(temp_min)")
                    }
                }
                if let name = json["name"] as? String  {
                    print("name=\(name)")
                    self.lblCityName.text = name
                }
                
            }
            
        }
    }


    
    
    
    func showAlert(_ message:String) {
        let alert = UIAlertController(title: "", message: message, preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
}

