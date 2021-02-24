// структура для ответа (модель)

// WEATHER
// получено: https://app.quicktype.io

import Foundation

struct ForecastWeatherData:  Codable {
    let list: [List]
    let city: City
}

// MARK: - City
struct City: Codable {
    let name: String
   
}

// MARK: - List
struct List: Codable {
    let dt: Int
    let main: MainClass
    let dtTxt: String

    enum CodingKeys: String, CodingKey {
        case dt, main
        case dtTxt = "dt_txt"
    }
}

// MARK: - MainClass
struct MainClass: Codable {
    let temp, feelsLike: Double
    
    enum CodingKeys: String, CodingKey {
        case temp
        case feelsLike = "feels_like"
    }
}

