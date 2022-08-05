//
//  ViewController.swift
//  home_work_23
//
//  Created by Natalia Drozd on 19.06.22.
//

import UIKit
import Alamofire
import RealmSwift
import CoreLocation

class WeatherViewController: UIViewController {
    
    lazy var coreManager: CLLocationManager = {
        let manager = CLLocationManager()
        manager.desiredAccuracy = kCLLocationAccuracyBest
        return manager
    }()
    
    @IBOutlet weak var locationButton: UIButton!
    
    @IBOutlet weak var searchPlaceButton: UIButton!
    @IBOutlet weak var blurEffectView: UIVisualEffectView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    private var apiProvider: RestAPIProviderProtocol!
    private var provaider: RealmProviderProtocol!
    var nameCity: String!
    @IBOutlet weak var tableView: UITableView!
    
    var currentClouds: String!
    var temp: Double!
    var weatherImage: UIImage!
    
    var dailyMaxTempArray: [Double] = []
    var dailyArrayDt: [String] = []
    var dailyArrayMinTemp: [Double] = []
    var dailyImageArray: [UIImage] = []
    
    var hourlyArrayTemp: [Double] = []
    var hourlyArrayDt: [String] = []
    var hourlyArrayImage: [UIImage] = []
    var hourlyArrayBadWeatherDt: [Int] = []
    var hourlyArrayBadWeatherId: [Int] = []
    
    let notificationCenter = UNUserNotificationCenter.current()
    var refreshControl: UIRefreshControl!
    
    var currentCoordinate: CLLocationCoordinate2D!
    var currentName: String!
    var newNameCity: UITextField!
    var defaults = UserDefaults()
    var selectionMode: ModeType = .none {
        didSet {
            locationButton.isSelected = selectionMode == .navigation
            if locationButton.isSelected {
                locationButton.tintColor = .red
                UserDefaults.standard.set(true, forKey: "isNavigation")
            } else {
                locationButton.tintColor = .white
            }
            searchPlaceButton.isSelected = selectionMode == .selectionCity
            if searchPlaceButton.isSelected {
                searchPlaceButton.tintColor = .red
                UserDefaults.standard.set(false, forKey: "isNavigation")
            } else {
                searchPlaceButton.tintColor = .white
            }
        }
    }
    var objectNotificationToken: NotificationToken?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        provaider = RealmProvader()
        let listSetting = provaider.getResult(nameObject: RealmSettings.self).last
        let system = listSetting?.typeSystem ?? false
        let dateFormat = listSetting?.formatDate ?? false
        
        let conditional = provaider.getResult(nameObject: WeatherConditional.self).last
        let snow = conditional?.snow ?? false
        let rain = conditional?.rain ?? false
        let thunderStorm = conditional?.thunderStorm ?? false

        provaider.setConditionalWeather(rain: rain, snow: snow, thunderStorm: thunderStorm)
        provaider.setSettingsList(system: system, format: dateFormat)
        
        guard let settings = provaider.getResult(nameObject: RealmSettings.self).last else {
            return
        }
        objectNotificationToken = settings.observe { change in
            switch change {
            case .change:
                self.getCoordinatesByName()
                self.tableView.reloadData()
            case .error(let error):
                print("An error occurred: \(error)")
            case .deleted:
                print("The object was deleted.")
            }
        }
        
        coreManager.delegate = self
        view.backgroundColor = UIColor(patternImage: UIImage(named: "e6d438f7bc89107d163f0db9f1e1f601.jpeg")!)
        
        blurEffectView.isHidden = false
        activityIndicator.startAnimating()
        nameCity = "Minsk"
        if Locale.preferredLanguages.first == "ru" {
            nameCity = "Минск"
        }
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UINib(nibName: "CurrentWeatherCell", bundle: nil), forCellReuseIdentifier: CurrentWeatherCell.key)
        tableView.register(UINib(nibName: "HourlyWeatherCell", bundle: nil), forCellReuseIdentifier: HourlyWeatherCell.key)
        tableView.register(UINib(nibName: "DailyWeatherCell", bundle: nil), forCellReuseIdentifier: DailyWeatherCell.key)
        
        tableView.layer.backgroundColor = UIColor.clear.cgColor
        tableView.backgroundColor = .clear
        
        refreshControl = UIRefreshControl()
        tableView.refreshControl = refreshControl
        refreshControl.attributedTitle = NSAttributedString(string: NSLocalizedString("Refreshing", comment: ""), attributes: [.foregroundColor: UIColor.white])
        refreshControl.tintColor = .white
        refreshControl.addTarget(self, action: #selector(refresh), for: .valueChanged)
        
        notificationCenter.removeAllPendingNotificationRequests()
        provaider = RealmProvader()
        apiProvider = AlamofireProvaider()
        
        if !defaults.bool(forKey: "isAppAlreadyLaunchedOnce") || !defaults.bool(forKey: "isNone") {
            UserDefaults.standard.set(true, forKey: "isAppAlreadyLaunchedOnce")
            getCoordinatesByName()
        } else if defaults.bool(forKey: "isNavigation") {
            selectionMode = .navigation
        } else {
            selectionMode = .selectionCity
            nameCity = defaults.string(forKey: "city")
            getCoordinatesByName()
        }
    }
    
    // MARK: Refresh tableView
    @objc private func refresh() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            self.tableView.reloadData()
        }
        refreshControl.endRefreshing()
    }
    
    func getWeatherByLocation() {
        guard currentCoordinate != nil else {return}
        self.blurEffectView.isHidden = false
        self.activityIndicator.startAnimating()
        self.nameCity = currentName
        self.getWeatherByCoordinates(cityLat: Double(currentCoordinate.latitude), cityLon: Double(currentCoordinate.longitude))
    }
    
    
    
    // MARK: Location weather
    @IBAction func onLocationButton(_ sender: Any) {
        coreManager.requestWhenInUseAuthorization()
        UserDefaults.standard.set(true, forKey: "isNone")
        selectionMode = .navigation
        getWeatherByLocation()
    }
    
    // MARK: Search City
    @IBAction func onSearchButton(_ sender: Any) {
        UserDefaults.standard.set(true, forKey: "isNone")
        selectionMode = .selectionCity
        let alert = UIAlertController(title: NSLocalizedString("Enter the name of the city", comment: ""), message: nil, preferredStyle: .alert)
        alert.addTextField { textField in
            textField.delegate = self
            textField.placeholder = NSLocalizedString("Enter name", comment: "")
            self.newNameCity = textField
        }
        
        let okButton = UIAlertAction(title: NSLocalizedString("Ok", comment: ""), style: .default) { [weak self] _ in
            guard let self = self else {return}
            guard let newName = self.newNameCity.text else {return}
            UserDefaults.standard.set(newName, forKey: "city")
            self.nameCity = newName
            self.blurEffectView.isHidden = false
            self.activityIndicator.startAnimating()
            self.getCoordinatesByName()
        }
        let cancelButton = UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .destructive)
        alert.addAction(okButton)
        alert.addAction(cancelButton)
        present(alert, animated: true)
        
    }
    
    // MARK: getCoordinatesByName
    fileprivate func getCoordinatesByName() {
        guard let nameCity = nameCity else {return}
        var lang = "en"
        if let preferredLanguage = Locale.preferredLanguages.first, preferredLanguage == "ru" {
            lang = preferredLanguage
        }
        apiProvider.getCoordinatesByName(name: nameCity) { [weak self] result in
            guard let self = self else {return}
            switch result {
            case .success(let value):
                if let city = value.first, let localName = city.localNames[lang] {
                    self.nameCity = localName
                    self.getWeatherByCoordinates(cityLat: city.lat, cityLon: city.lon)
                } else {
                    self.blurEffectView.isHidden = true
                    self.activityIndicator.stopAnimating()
                    let errorAlert = UIAlertController(title: NSLocalizedString("Place not found", comment: ""), message: nil, preferredStyle: .alert)
                    let okButton = UIAlertAction(title: NSLocalizedString("Ok", comment: ""), style: .cancel) { _ in
                    }
                    errorAlert.addAction(okButton)
                    self.present(errorAlert, animated: true)
                }
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    }
    // MARK: Notifications
    private func setWeatherNotifications(arrayTime: [Int]) {
        guard let time = arrayTime.first else {return}
        let content = UNMutableNotificationContent()
        content.body = NSLocalizedString("Weather conditions will worsen soon", comment: "")
        var date = DateComponents()
        date.hour = Int(time.convertUnix(formattedType: .hourSecondType))
        date.minute = Int(time.convertUnix(formattedType: .minutly))
        let calendarTrigger = UNCalendarNotificationTrigger(dateMatching: date, repeats: false)
        let indentifier = String(time)
        let request = UNNotificationRequest(identifier: indentifier, content: content, trigger: calendarTrigger)
        self.notificationCenter.add(request) { error in
            if let error = error {
                print (error)
            }
        }
    }
    // MARK: getWeatherByCoordinates
    private func getWeatherByCoordinates(cityLat: Double, cityLon: Double) {
        apiProvider.getWeatherForCityCoordinates(lat: cityLat, lon: cityLon) { [weak self] result in
            guard let self = self else {return}
            self.blurEffectView.isHidden = true
            self.activityIndicator.stopAnimating()
            switch result {
            case .success(let value):
                guard let current = value.current, let weather = current.weather, let temp = current.temp, let clouds = weather.first?.description, let lat = value.lat, let lon = value.lon else {return}
                self.temp = temp
                self.currentClouds = clouds
                let date = Int(Date().timeIntervalSince1970)
                self.provaider.setCurrentWeatherQueryList(temp: temp, weather: clouds, time: date, isCurrentWeather: true)
                self.provaider.setQueryList(lat: lat, lon: lon, time: date)
                
                // MARK: Hourly
                guard let hourly = value.hourly else {return }
                let snow = 600...699
                let rain = 500...599
                let thunderstorm = 200...299
                self.hourlyArrayImage.removeAll()
                self.hourlyArrayDt.removeAll()
                self.hourlyArrayTemp.removeAll()
                self.hourlyArrayBadWeatherId.removeAll()
                for item in hourly {
                    guard let hourlyTemp = item.temp, let hourlyDt = item.dt, let weather = item.weather, let icon = weather.first?.icon, let weatherId = weather.first?.id else {return}
                    if let url = URL(string: "https://openweathermap.org/img/wn/\(icon)@2x.png") {
                        do {
                            let data = try Data(contentsOf: url)
                            guard let icon = UIImage(data: data) else {return}
                            self.hourlyArrayImage.append(icon)
                        } catch _ {
                            print("error")
                        }
                    }
                    
                    let listSetting = self.provaider.getResult(nameObject: RealmSettings.self).last
                    let dateFormat = listSetting?.formatDate ?? false

                    self.hourlyArrayDt.append(hourlyDt.convertUnix(formattedType: dateFormat ? .hourFirstType : .hourSecondType))
                    self.hourlyArrayTemp.append(hourlyTemp)
                                        
                    guard let conditional = self.provaider.getResult(nameObject: WeatherConditional.self).last else {
                        return
                    }
                    
                    if conditional.thunderStorm && thunderstorm.contains(weatherId) {
                        self.hourlyArrayBadWeatherDt.append(hourlyDt - 60 * 30)
                    }
                    
                    if conditional.rain && rain.contains(weatherId) {
                        self.hourlyArrayBadWeatherDt.append(hourlyDt - 60 * 30)
                    }
                    
                    if conditional.snow && snow.contains(weatherId) {
                        self.hourlyArrayBadWeatherDt.append(hourlyDt - 60 * 30)
                    }
                }
                self.setWeatherNotifications(arrayTime: self.hourlyArrayBadWeatherDt)
                
                // MARK: DAILY
                guard let daily = value.daily else {return }
                self.dailyImageArray.removeAll()
                self.dailyMaxTempArray.removeAll()
                self.dailyArrayMinTemp.removeAll()
                self.dailyArrayDt.removeAll()
                
                for item in daily {
                    guard let temp = item.temp, let maxTemp = temp.max, let minTemp = temp.min, let days = item.dt, let weather = item.weather, let icon = weather.first?.icon else {return}
                    
                    if let url = URL(string: "https://openweathermap.org/img/wn/\(icon)@2x.png") {
                        do {
                            let data = try Data(contentsOf: url)
                            guard let icon = UIImage(data: data) else {return}
                            self.dailyImageArray.append(icon)
                        } catch _ {
                            print("error")
                        }
                    }
                    self.dailyMaxTempArray.append(maxTemp)
                    self.dailyArrayMinTemp.append(minTemp)
                    self.dailyArrayDt.append(days.convertUnix(formattedType: .day))
                    
                }
                self.tableView.reloadData()
            case .failure(let error):
                print(error)
            }
        }
    }
}
