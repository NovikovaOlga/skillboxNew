// ТЕКУЩАЯ ПОГОДА
// менеджер сетевых запросов

import Foundation

class NetworkWeatherManager {
    
    var onCompletion: ((CurrentWeather) -> Void)? // примет CurrentWeather (клоужр) - подпишемся под изменения сurrentWeather
    
    func fetchCurrentWeather(forCity city: String) { // функция сетевого запроса с запросом города
        
        let urlString = "https://api.openweathermap.org/data/2.5/weather?q=\(city)&apikey=\(apiKey)&units=metric"
        guard let url = URL(string: urlString) else { return }
        let session = URLSession(configuration: .default) // создадим сессию (конфигурация дефолтная в 99 процентах)
        let task = session.dataTask(with: url) { data, response, error in
            if let data = data {
                if let currentWeather = self.parseJSON(withData: data) { // здесь парсим наш джейсон
                    self.onCompletion?(currentWeather)
                }
            }
        }
        task.resume() // вызываем resume, чтобы  task начал работать
    }
    
    func parseJSON(withData data: Data) -> CurrentWeather? { // распарсим данные (разложим данные по модели, которую мы создали)
        let decoder = JSONDecoder() // докидируем данные (раскодируем информацию из джейсона и вернем объект)
        do {
            let currentWeatherData = try decoder.decode(CurrentWeatherData.self, from: data) // как декодировать (если есть try, то всегда есть do-catch блок)
            guard let currentWeather = CurrentWeather(currentWeatherData: currentWeatherData) else {
                return nil
            }
            return currentWeather // если объект создан, то вернем его
        } catch let error as NSError { //
            print(error.localizedDescription)
        }
        return nil
    }
}
