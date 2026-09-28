//
//  WeatherView.swift
//  WeatherApp
//
//  Created by Christian-SDGKU on 23/09/26.
//

import SwiftUI

struct WeatherView: View {
    
    @StateObject var viewModel: WeatherViewModel = WeatherViewModel()
    
    var body: some View {
        
        VStack(spacing: 20) {
            
            TextField(
                "Enter a city",
                text: $viewModel.searchText
            )
            .textFieldStyle(.roundedBorder)
            .autocorrectionDisabled()
            .textInputAutocapitalization(.words)
            
            Button("Get Weather") {
                
                Task {
                    await viewModel.searchWeather()
                }
            }
            .buttonStyle(.borderedProminent)
            
            if viewModel.isLoading {
                ProgressView()
            }
            
            if !viewModel.errorMessage.isEmpty {
                Text(viewModel.errorMessage)
                    .foregroundStyle(.red)
                    .multilineTextAlignment(.center)
            }
            
            if !viewModel.cityName.isEmpty {
                
                VStack(alignment: .leading, spacing: 10) {
                    
                    Text(viewModel.cityName)
                        .font(.title)
                        .fontWeight(.bold)
                    
                    Text(viewModel.temperature)
                    
                    Text(viewModel.windText)
                }
            }
        }
        .padding()
    }
}

#Preview {
    WeatherView()
}
