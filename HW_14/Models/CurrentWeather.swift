// ТЕКУЩАЯ ПОГОДА
// передача данных во View Controller

import UIKit

// передаем данные во View Controller
struct CurrentWeather {
    let cityName: String // город
    
    let temperature: Double // температура
    var temperatureString: String { // так как информацяи размещается в ярлыке, то передавать надо строку - создадим строку с температурой (вычисляемое свойство)
        return String(format: "%.0f", temperature) // округлим значение целиком %.0f, если %.1f - то один знак после запятой и тд
    }

    struct Icon { // структура для иконок из Assets
        let icon: UIImage?
    }
    
    let feelsLikeTemperature: Double // ощущается
    var feelsLikeTemperatureString: String { // так как информацяи размещается в ярлыке, то передавать надо строку (на вьюшке приложения тольок строковые значения) - создадим строку с "ощущается" (вычисляемое свойство)
        return String(format: "%.1f", feelsLikeTemperature)
    }
    
    // работаем с иконкой - смена, в зависимости от погоды
    let conditionCode: Int // обновление иконки
 
    var systemIconNameString: String { // системный иконки
    //    let snow = Icon(icon: UIImage(named: "09d"))
        switch conditionCode { // коды для иконок с сайта https://openweathermap.org/weather-conditions
        
        case 200...232: return "cloud.bolt.rain.fill" // подберем картинку в стоиборде во вью Image (гроза)
        case 300...321: return "cloud.drizzle.fill" // мелкий дождь
        case 500...531: return "cloud.rain.fill" // дождь
        case 600...622: return "cloud.snow.fill" // снег
        case 701...781: return "smoke.fill" // туман
        case 800: return "sun.min.fill" //солнце
        case 801...804: return "cloud.fill" // облачность
        default: return "nosing" // иконка для дефолтного значения

        }
    }
    
    init?(currentWeatherData: CurrentWeatherData) {  // инициализатор, которы может вернуть nil и внутри которого мы будем передавать данные
        cityName = currentWeatherData.name // город
        temperature = currentWeatherData.main.temp // температура
        feelsLikeTemperature = currentWeatherData.main.feelsLike // температура
        conditionCode = currentWeatherData.weather.first!.id // иконка
    }
}

