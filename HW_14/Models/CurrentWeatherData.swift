// ТЕКУЩАЯ ПОГОДА
// модель, чтобы распарсить данные
// удобно использовать для получения данных https://app.quicktype.io

import Foundation

struct CurrentWeatherData: Codable { // Codable - это совокупность двух протоколов decodable и incodable - можем кодировать и раскодировать данные
    let name: String // город
    let main: Main // температура
    let weather: [Weather] // структура погоды - массив
}

struct Main: Codable { // температура
    let temp: Double // температура
    let feelsLike: Double // ощущается
    
    enum CodingKeys: String, CodingKey { // для изменения ключа (стандартная запись)
        case temp // не делаем ничего
        case feelsLike = "feels_like" // меняем ключ на более удобный
    }
}

struct Weather: Codable { // так как Weather- массив
    let id: Int
}

