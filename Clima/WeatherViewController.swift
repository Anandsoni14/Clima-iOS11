//
//  ViewController.swift
//  WeatherApp
//
//  Created by Angela Yu on 23/08/2015.
//  Copyright (c) 2015 London App Brewery. All rights reserved.
//

import UIKit
import CoreLocation
import Alamofire
import SwiftyJSON


class WeatherViewController: UIViewController, CLLocationManagerDelegate,changeCityName {
    
    //Constants
    let WEATHER_URL = "http://api.openweathermap.org/data/2.5/weather"
    let APP_ID = "e72ca729af228beabd5d20e3b7749713"
    

    //TODO: Declare instance variables here
	let locationManager = CLLocationManager()
	let weatherDataModel = WeatherDataModel()
    

    
    //Pre-linked IBOutlets
    @IBOutlet weak var weatherIcon: UIImageView!
    @IBOutlet weak var cityLabel: UILabel!
    @IBOutlet weak var temperatureLabel: UILabel!

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        //TODO:Set up the location manager here.
		locationManager.delegate = self
		locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
		locationManager.requestWhenInUseAuthorization()
		locationManager.startUpdatingLocation()
    
        
        
    }
    
    
    
    //MARK: - Networking
    /***************************************************************/
    
    //Write the getWeatherData method here:
	
	func getWeatherData(url: String, parameters: [String:String]){
		
		Alamofire.request(url, method: .get, parameters: parameters).responseJSON {
			response in
			if response.result.isSuccess {
				
				print("Success! Got Weather Data")
				
				let weatherJSON : JSON = JSON(response.result.value!)
				print(weatherJSON)
				self.updateWeatherData(json: weatherJSON)
				
			}else {
				print("Error \(String(describing: response.result.error))")
				self.cityLabel.text = "Connection mai problem"
			}
			
		}
	
		
		
	}
    

    
    
    
    
    
    //MARK: - JSON Parsing
    /***************************************************************/
   
    
    //Write the updateWeatherData method here:
	
	func updateWeatherData(json : JSON) {
		
		if let temp = json["main"]["temp"].double {
		weatherDataModel.temp = Int(temp - 273.15)
		
		weatherDataModel.city = json["name"].stringValue
		
		let weartherInt : Int = json["weather"][0]["id"].intValue
		weatherDataModel.condition = weartherInt
		
		weatherDataModel.weatherIconName = weatherDataModel.updateWeatherIcon(condition: weartherInt)
	
			updateUIWithWeatherData()
		}else {
			cityLabel.text = json["message"].stringValue
		}
		
	}
    

    
    
    
    //MARK: - UI Updates
    /***************************************************************/
    
    
    //Write the updateUIWithWeatherData method here:
	func updateUIWithWeatherData() {
		cityLabel.text = weatherDataModel.city
		temperatureLabel.text = "\(weatherDataModel.temp)℃"
		weatherIcon.image = UIImage(named: weatherDataModel.weatherIconName)
	}
    
    
    
    
    
    //MARK: - Location Manager Delegate Methods
    /***************************************************************/
    
    
    //Write the didUpdateLocations method here:
	func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
		let location = locations[locations.count-1]
		if location.horizontalAccuracy > 0 {
			locationManager.stopUpdatingLocation()
			locationManager.delegate = nil
			
			print("longi = \(location.coordinate.longitude)")
			print("lati = \(location.coordinate.latitude)")
			
			let longi = String(location.coordinate.longitude)
			let lati = String(location.coordinate.latitude)
			
			let params : [String : String] = ["lat" : lati , "lon" : longi , "appid" : APP_ID]
			
			getWeatherData(url: WEATHER_URL, parameters : params)
		}
	}
    
    
    
    //Write the didFailWithError method here:
	func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
		print(error)
		cityLabel.text = "Location Unavailable"
		
	}
    
    
    

    
    //MARK: - Change City Delegate methods
    /***************************************************************/
    
    
    //Write the userEnteredANewCityName Delegate method here:
	func userEnteredACityName(city: String) {
		print(city)
		let params : [String : String] = ["q" : city, "appid" : APP_ID]
		getWeatherData(url: WEATHER_URL, parameters : params)
	}

    
    //Write the PrepareForSegue Method here
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		if segue.identifier == "changeCityName" {
			let desiVC = segue.destination as! ChangeCityViewController
			
			desiVC.delegate = self
		}
	}
    
    
    
    
}


