//
//  TimeTableEntity.swift
//  GoEuroTest
//
//  Created by Peter Prokop on 11/02/17.
//  Copyright © 2017 Prokop. All rights reserved.
//

import Foundation

@objc class TimeTableEntity: NSObject, JSONConvertible {
    
    let id: Int
    let providerLogoURLTemplate: String?
    let priceInEuros: Double // Could be String or Number in JSON
    let departureTime: String
    let arrivalTime: String
    let numberOfStops: Int
    
    enum Keys {
        static let id                           = "id"
        static let providerLogoURLTemplate      = "provider_logo"
        static let priceInEuros                 = "price_in_euros"
        static let departureTime                = "departure_time"
        static let arrivalTime                  = "arrival_time"
        static let numberOfStops                = "number_of_stops"
    }
    
    required init(value: Any?) throws {
        id                          = try value.int(Keys.id)
        providerLogoURLTemplate     = try? value.string(Keys.providerLogoURLTemplate)
        
        priceInEuros    = try value.double(Keys.priceInEuros)
        departureTime   = try value.string(Keys.departureTime)
        arrivalTime     = try value.string(Keys.arrivalTime)
        numberOfStops   = try value.int(Keys.numberOfStops)
        
        super.init()
    }
    
    func providerLogoURL(forSize size: Int) -> URL? {
        guard let providerLogoURLTemplate = providerLogoURLTemplate else { return nil }
        
        var urlString = providerLogoURLTemplate.replacingOccurrences(of: "{size}", with: "\(size)")
        
        if !urlString.contains("https") {
            urlString = urlString.replacingOccurrences(of: "http", with: "https")
        }
        
        return URL(string: urlString)
    }
    
    func numberOfStopsDescription() -> String {
        if numberOfStops == 0 {
            return "Direct"
        }
        
        if numberOfStops % 10 == 1 {
            return "\(numberOfStops) change"
        }
        
        return "\(numberOfStops) changes"
    }
    
}
