//
//  WeatherModels.swift
//  WeatherApp
//
//  Created by Christian-SDGKU on 23/09/26.
//

import Foundation

struct GeocodingResult: Codable {
    let results: [GeocodingPlace]?
}

struct GeocodingPlace: Codable {
    let name: String
    let latitude: Double
    let longitude: Double
}

struct ForecastResponse: Codable {
    let current: CurrentWeather
}

struct CurrentWeather: Codable {
    let temperature_2m: Double
    let wind_speed_10m: Double
}
