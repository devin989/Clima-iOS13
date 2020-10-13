//
//  WeatherManager.swift
//  Clima
//
//  Created by DEVEEN RATNAYAKE on 10/12/20.
//  Copyright © 2020 App Brewery. All rights reserved.
//

import Foundation
import CoreLocation
protocol WeatherManagerDelegate {
    func didUpdateWeather(_ weatherManager:WeatherManager ,weather: WeatherModel)
    func didFailWithError(error:Error)
}



struct WeatherManager {
    let weatherURL = "https://api.openweathermap.org/data/2.5/weather?&appid=010443a0435df6029503d4063a475da3&units=metric"
    
    var delegate:WeatherManagerDelegate?
    
    func fetchWeather(cityName:String) {
        let urlString = "\(weatherURL)&q=\(cityName)"
//        print(urlString)
        performRequest(with : urlString)
    }
    
    func fetchWeather(latitude: CLLocationDegrees,longtitude:CLLocationDegrees){
        let urlString = "\(weatherURL)&lat=\(latitude)&lon=\(longtitude)"
        performRequest(with : urlString)

    }
    
    func performRequest(with urlString:String) {
        //1 create url
        if  let url = URL(string: urlString){
            // 2.url session
            let session = URLSession(configuration: .default)
            // 3. give  session task
            let task = session.dataTask(with: url) { (data, response, error) in
                if error != nil{
                    self.delegate?.didFailWithError(error: error!)
                    return
                }
                
                if let safeData = data{
                    if let weather = self.parseJSON(weatherData: safeData){
                        self.delegate?.didUpdateWeather(self,weather: weather)
                    }
                }
            }
            
            //4.start the task
            task.resume()
        }
    }
    
    func parseJSON(weatherData:Data)->WeatherModel?{
        
        let decoder = JSONDecoder()
        
        do{
            
           let decodedData = try decoder.decode(WeatherData.self, from: weatherData)
            
            let id = decodedData.weather[0].id
            
            let name = decodedData.name
            
            let temp = decodedData.main.temp
            
            let weather = WeatherModel(conditionId: id, cityName: name, temperature: temp)
            
        return weather
            
            
        }catch{
            delegate?.didFailWithError(error: error)
            return nil
        }
        
    }
    
  
    
    
}
