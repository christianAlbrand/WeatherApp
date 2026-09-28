//
//  WeatherViewModel.swift
//  WeatherApp
//
//  Created by Christian-SDGKU on 23/09/26.
//

import Foundation
import Combine

@MainActor
class WeatherViewModel: ObservableObject {
    
    @Published var searchText: String = ""
    @Published var cityName: String = ""
    @Published var temperature: String = ""
    @Published var windText: String = ""
    @Published var timeText: String = ""
    
    @Published var isLoading: Bool = false
    @Published var errorMessage: String = ""
    
    let API = WeatherService()
    
    func searchWeather() async {
        
        self.isLoading = true
        self.errorMessage = ""
        
        let trimmedText = self.searchText.trimmingCharacters(
            in: .whitespacesAndNewlines
        )
        
        if trimmedText.isEmpty {
            self.errorMessage = "Please enter a city name"
            self.isLoading = false
            return
        }
        
        do {
            
            let result = try await API.fetchAPI(
                forCity: trimmedText
            )
            
            cityName = result.cityName
            
            temperature = "Temp: \(result.weather.temperature_2m)°C"
            
            windText = "Wind: \(result.weather.wind_speed_10m) km/h"
            
            self.isLoading = false
            
        } catch {
            
            print("❌ Weather API Error:", error)
            
            self.errorMessage = "Something went wrong: \(error.localizedDescription)"
            
            self.isLoading = false
        }
    }
}
