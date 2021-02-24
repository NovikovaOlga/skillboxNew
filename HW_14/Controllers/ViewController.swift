
import UIKit
import CoreData

class ViewController: UIViewController, UITableViewDataSource {
    
    var weatherOld = [WeatherOld]() // прогноз погоды: база данных
    
    // менеджеры сетевых запросов
    let networkWeatherManager = NetworkWeatherManager()  // адрес внутри
    let forecastNetworkWeatherManager = ForecastNetworkWeatherManager() // адрес тут
    var forecastWeatherData: ForecastWeatherData? = nil
    let citySelect = city // текущая погода: город (город,ключ API храним отдельно)
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    var statusData = 0 // переключатель (0 - грузим DataSourse из CoreData, 1 - парсим с сервера
    @IBOutlet weak var weatherIconImageView: UIImageView!
    @IBOutlet weak var cityLabel: UILabel!
    @IBOutlet weak var temperatureLabel: UILabel!
    @IBOutlet weak var feelsLikeTemperatureLabel: UILabel!
    
    @IBOutlet weak var table: UITableView!
    
    // чтобы скрыть и отобразить после загрузки данных (для красоты)
    @IBOutlet weak var dateTitle: UILabel!
    @IBOutlet weak var tempTitle: UILabel!
    @IBOutlet weak var feelsTitle: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
       
        setupCurrentWeather() // загрузим текущую погоду
        setupForecastWeather() // загрузка прогноз погоды в талицу
        setupColorCurrentWeather() // меняем цвет текста устаревших данных погоды
        loadForecastWeatherOld()
        print(statusData)
        
        // прогноз на несколько дней
        let urlString = "https://api.openweathermap.org/data/2.5/forecast?q=\(city)&appid=\(apiKey)&units=metric" // строка с адресом (тип - String). ВАЖНО: &units=metric - с сайта openWeather, чтобы градусы были в цельсиях, а не в кельвинах
        
        forecastNetworkWeatherManager.request(urlString: urlString) { [weak self] (list) in
            switch list {
            case .success(let forecastWeatherData):
                self?.forecastWeatherData = forecastWeatherData // передали данные
                self?.table.reloadData()
                
            case .failure(let error):
                print("error:", error)
            }
        }
        
        // текущая погода
        networkWeatherManager.onCompletion = { [weak self] currentWeather in
            guard let self = self else { return }  // [weak self] - точно знаем, что нет цикла сильных сылок - если проложение разрастется и будет много экранов
            self.updateInterfaceWith(weather: currentWeather) // обновим интерфейс
        }
        networkWeatherManager.fetchCurrentWeather(forCity: citySelect)  // вызовем функция сетеового запроса из менеджера для указанного города (current weather)
    }
    
    // текущая погода: сохраняем до загрузки данных
    class OldWeatherCurrent {
        static let shared = OldWeatherCurrent()
        
        private let kCity = "OldWeatherCurrent.kCity" // храним старое название города
        private let kTemperature = "OldWeatherCurrent.kTemperature" // храним старую температуру
        private let kFeelsLikeTemperature = "OldWeatherCurrent.kFeelsLikeTemperature" // храним старую температуру
        
        var city: String {
            set { UserDefaults.standard.set(newValue, forKey: kCity)}
            get { return UserDefaults.standard.string(forKey: kCity) ?? "" }
        }
        
        var temperature: String {
            set { UserDefaults.standard.set(newValue, forKey: kTemperature)}
            get { return UserDefaults.standard.string(forKey: kTemperature) ?? ""}
        }
        
        var feelsLikeTemperature: String {
            set { UserDefaults.standard.set(newValue, forKey: kFeelsLikeTemperature)}
            get { return UserDefaults.standard.string(forKey: kFeelsLikeTemperature) ?? ""}
        }
    }
    
    // текущая погода: обновим интерфейс для продолжения работы
    func updateInterfaceWith(weather: CurrentWeather) {
        DispatchQueue.main.async { // так как поток пользовательского интерфейеса имеет приоритетный поток (но вызов его в бекграeндном потоке), то переводим вызов этого блока в главном потоке - асинхронно (не заставим главную очередь ожидать этого блока, чтобы при долгой загрузке устройство не выглядело зависшим)
            self.cityLabel.text = weather.cityName
            self.temperatureLabel.text = ("\(weather.temperatureString) °C")
            self.feelsLikeTemperatureLabel.text = ("feels like \(weather.feelsLikeTemperatureString) °C")
            self.weatherIconImageView.image = UIImage(systemName: weather.systemIconNameString)
            
            // сохраним данные для последующей загрузки (до парсинга данных с сервера погоды) (OldWeatherCurrent)
            OldWeatherCurrent.shared.city = self.cityLabel.text!
            OldWeatherCurrent.shared.temperature = self.temperatureLabel.text!
            OldWeatherCurrent.shared.feelsLikeTemperature = self.feelsLikeTemperatureLabel.text!
            self.statusData = 1
            print(self.statusData)
            // проверка цвета текста и видимости иконки (после сетевого запроса), чтобы не крэшнулось (много строк - придумать как зациклить: например собрать элементы в массив(?) и проверять их видимость)
            if  self.weatherIconImageView.isHidden == true {
                self.weatherIconImageView.isHidden = false
            }
            
            if self.cityLabel.textColor == .blue {
                self.cityLabel.textColor = .black
            }
            
            if self.temperatureLabel.textColor == .blue {
                self.temperatureLabel.textColor = .black
            }
            
            if self.feelsLikeTemperatureLabel.textColor == .blue {
                self.feelsLikeTemperatureLabel.textColor = .black
            }
            
            if self.dateTitle.textColor == .blue {
                self.dateTitle.textColor = .black
            }
            
            if self.tempTitle.textColor == .blue {
                self.tempTitle.textColor = .black
            }
            
            if self.feelsTitle.textColor == .blue {
                self.feelsTitle.textColor = .black
            }
        }
    }
    
    // текущая погода: вынесено из viewDidLoad (загрузка ранее сохраненных данные до парсинга данных (OldWeatherCurrent))
    private func setupCurrentWeather() {
        cityLabel.text = OldWeatherCurrent.shared.city
        temperatureLabel.text = OldWeatherCurrent.shared.temperature
        feelsLikeTemperatureLabel.text = OldWeatherCurrent.shared.feelsLikeTemperature
    }
    
    // прогноз погоды: вынесено из viewDidLoad (датасорс и делегат)
    private func setupForecastWeather() {
        //  table.isHidden = true // сделаем таблицу невидимой до загрузки данных (некрасиво моргает белым цветом)
        //     table.delegate = self // нужен для язагрузки хидера
        table.dataSource = self
        table.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
    }
    
    // текущая погода: вынесено из viewDidLoad  (меняем цвет текста устаревших данных до парсинга обновленных данных)
    private func setupColorCurrentWeather() {
        weatherIconImageView.isHidden = true
        cityLabel.textColor = .blue
        temperatureLabel.textColor = .blue
        feelsLikeTemperatureLabel.textColor = .blue
        dateTitle.textColor = .blue
        tempTitle.textColor = .blue
        feelsTitle.textColor = .blue
    }
    
    // прогноз погоды: очистим таблицу базы данных
    private func deleteWeather() {
        let fetch = NSFetchRequest<NSFetchRequestResult>(entityName: "WeatherOld")
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetch)
        
        do {
            try context.execute(deleteRequest)
        } catch {
            print(error.localizedDescription)
        }
    }
    
    //прогноз погоды: сохранение загруженных данных в контекст
    func saveForecastWeatherOld(){
        do{
            try context.save()
        }catch {
            print("Error saving category with \(error)")
        }
        //   table.reloadData() // не обновляем - так как таблица отваливается
    }
    
    //прогноз погоды: загрузка данных
    func loadForecastWeatherOld(){
        let request: NSFetchRequest<WeatherOld> = WeatherOld.fetchRequest()
        do {
            weatherOld = try context.fetch(request)
        }catch{
            print("Error fetching data from context \(error)")
        }
        table.reloadData()
    }
}

extension ViewController {
    
    // придумала только вариант с переключателем
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if statusData == 0 {
            return weatherOld.count
        } else if statusData == 1 {
            return forecastWeatherData?.list.count ?? 0
        } else {
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        table.layer.backgroundColor = UIColor.clear.cgColor // прозрачная таблица
        let cell = table.dequeueReusableCell(withIdentifier: "cellTable", for: indexPath) as! ForecastTableViewCell
        
        if statusData == 0 {
            
            cell.dateTimeLabel.textColor = .blue
            cell.tempLabel.textColor = .blue
            cell.feelsLikeLabel.textColor = .blue
            
            let weatherOldLoad = weatherOld[indexPath.row]
            cell.dateTimeLabel?.text = weatherOldLoad.dateOld
            cell.tempLabel?.text = weatherOldLoad.tempOld
            cell.feelsLikeLabel?.text = weatherOldLoad.feelsTempOld
            
            deleteWeather() // очистим CoreData после загрузки данных из нее

        } else if statusData == 1 {
            
            let weather = forecastWeatherData?.list[indexPath.row]
            
            let dataTime = weather?.dtTxt
            let temp = weather?.main.temp
            var tempString: String {
                return String(format: "%.0f", temp!)
            }
            
            let feelsLike = weather?.main.feelsLike
            var feelsLikeString: String {
                return String(format: "%.0f", feelsLike!)
            }
            
            cell.dateTimeLabel.text = dataTime
            cell.tempLabel.text = ("\(tempString) °C")
            cell.feelsLikeLabel.text = ("\(feelsLikeString) °C")
            
            // сохраним прогноз погоды для последующего показа в таблице до парсинга в таблицу
            let oldWeather = WeatherOld(context: self.context)
            oldWeather.dateOld = cell.dateTimeLabel.text!
            oldWeather.tempOld = cell.tempLabel.text!
            oldWeather.feelsTempOld = cell.feelsLikeLabel.text!
            self.weatherOld.append(oldWeather)
            self.saveForecastWeatherOld() // сохранение загруженных данных по прогнозу
            
            // переключим цвет
            if cell.dateTimeLabel.textColor == .blue {
                cell.dateTimeLabel.textColor = .black
            }

            if cell.tempLabel.textColor == .blue {
                cell.tempLabel.textColor = .black
            }

            if cell.feelsLikeLabel.textColor == .blue {
                cell.feelsLikeLabel.textColor = .black
            }
        }
        return cell
    }
}

