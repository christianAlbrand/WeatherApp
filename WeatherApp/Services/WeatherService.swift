//
//  WeatherService.swift
//  WeatherApp
//
//  Created by Christian-SDGKU on 23/09/26.
//

import Foundation

class WeatherService {
    
    // STEP 1.- THE USER SENDS THE NAME OF THE PLACE
    // STEP 2.- WE SEND THE PLACE TO API WE GET BACK COORDENATES
    // STEP 3.- WE SEND THOSE COORDENATES TO API, WE GET THE WEATHER BACK
    
    // MARK: ERROR MENU ADD MORE IF YOU CAN THINK
    
    enum NetworkError: Error {
        case badStatusCode(Int)
        case invalidResponse
        case invalidURL
        case noResults
    }
    
    // HELPER FUNCTION
    
    private func performGetRequest(url: URL) async throws -> Data {
        
        // STEP 1: Create a URLSession (the tool that makes network requests)
        let session: URLSession = URLSession.shared
        
        // STEP 2: send a GET request to the URL and wait for the server to respond
        // - "try" because networking can fail
        // - "await" because it takes time
        let result: (Data, URLResponse) = try await session.data(from: url)
        
        // STEP 3: Split the result into:
        // - data: the actual content (usually JSON)
        // - response: information about the request (status code, headers, etc.)
        let data: Data = result.0
        let response: URLResponse = result.1
        
        // STEP 4: we want an HTTP response so we can read the status code (200, 404, 500...)
        // If this is not an HTTP response, something is wrong
        if let httpResponse = response as? HTTPURLResponse {
            
            let statusCode: Int = httpResponse.statusCode
            
            if statusCode < 200 || statusCode >= 300 {
                throw NetworkError.badStatusCode(statusCode)
            }
            
            return data
        }
        
        throw NetworkError.invalidResponse
    }
    
    func fetchCoordinates(forCity city: String) async throws -> GeocodingPlace {
        
        // Step 1.- Create my url components
        var urlComponents: URLComponents? = URLComponents(
            string: "https://geocoding-api.open-meteo.com/v1/search"
        )
        
        if urlComponents == nil {
            throw NetworkError.invalidURL
        }
        
        // Step 2.- Add my parameters to my base url
        urlComponents?.queryItems = [
            
            // Name, count, language, format
            URLQueryItem(name: "name", value: city),
            URLQueryItem(name: "count", value: "1"),
            URLQueryItem(name: "language", value: "en"),
            URLQueryItem(name: "format", value: "json")
        ]
        
        guard let url = urlComponents?.url else {
            throw NetworkError.invalidURL
        }
        
        let data = try await performGetRequest(url: url)
        
        let decoder: JSONDecoder = JSONDecoder()
        
        let response: GeocodingResult = try decoder.decode(
            GeocodingResult.self,
            from: data
        )
        
        if let results: [GeocodingPlace] = response.results {
            
            if let first: GeocodingPlace = results.first {
                return first
            }
        }
        
        throw NetworkError.noResults
    }
    
    func fetchWeather(
        latitude: Double,
        longitude: Double
    ) async throws -> CurrentWeather {
        
        var urlComponents: URLComponents? = URLComponents(
            string: "https://api.open-meteo.com/v1/forecast"
        )
        
        if urlComponents == nil {
            throw NetworkError.invalidURL
        }
        
        urlComponents?.queryItems = [
            URLQueryItem(name: "latitude", value: String(latitude)),
            URLQueryItem(name: "longitude", value: String(longitude)),
            URLQueryItem(
                name: "current",
                value: "temperature_2m,wind_speed_10m"
            ),
            URLQueryItem(name: "timezone", value: "auto")
        ]
        
        guard let url = urlComponents?.url else {
            throw NetworkError.invalidURL
        }
        
        let data = try await performGetRequest(url: url)
        
        let decoder: JSONDecoder = JSONDecoder()
        
        let response: ForecastResponse = try decoder.decode(
            ForecastResponse.self,
            from: data
        )
        
        return response.current
    }
    
    func fetchAPI(
        forCity city: String
    ) async throws -> (cityName: String, weather: CurrentWeather) {
        
        let geoCoord = try await fetchCoordinates(forCity: city)
        
        let geoWeather = try await fetchWeather(
            latitude: geoCoord.latitude,
            longitude: geoCoord.longitude
        )
        
        return (geoCoord.name, geoWeather)
    }
}
