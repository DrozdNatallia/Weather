//
//  ViewController.swift
//  home_work_23
//
//  Created by Natalia Drozd on 19.06.22.
//

import UIKit
import Alamofire
import RealmSwift
import GoogleMaps
import CoreLocation

class WeatherViewController: UIViewController{
    
    private lazy var coreManager: CLLocationManager = {
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
    
    enum ContentType: Int {
        case current = 0
        case hourly
        case daily
        var description: String {
            switch self {
            case .current:
                return "Current weather"
            case .hourly:
                return "Hourly weather"
            case .daily:
                return "Daily weather"
            }
        }
    }
    let notificationCenter = UNUserNotificationCenter.current()
    var refreshControl: UIRefreshControl!
    
    var currentCoordinate: CLLocationCoordinate2D!
    var currentName: String!
    override func viewDidLoad() {
        super.viewDidLoad()
        let realm = try! Realm()
        try! realm.write {
            realm.deleteAll()
        }
        coreManager.delegate = self
        view.backgroundColor = UIColor(patternImage: UIImage(named: "e6d438f7bc89107d163f0db9f1e1f601.jpeg")!)
        
        blurEffectView.isHidden = false
        activityIndicator.startAnimating()
        nameCity = "Minsk"
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UINib(nibName: "CurrentWeatherCell", bundle: nil), forCellReuseIdentifier: CurrentWeatherCell.key)
        tableView.register(UINib(nibName: "HourlyWeatherCell", bundle: nil), forCellReuseIdentifier: HourlyWeatherCell.key)
        tableView.register(UINib(nibName: "DailyWeatherCell", bundle: nil), forCellReuseIdentifier: DailyWeatherCell.key)
        
        tableView.layer.backgroundColor = UIColor.clear.cgColor
        tableView.backgroundColor = .clear
        
        refreshControl = UIRefreshControl()
        tableView.refreshControl = refreshControl
        refreshControl.attributedTitle = NSAttributedString(string: "Refreshing")
        refreshControl.addTarget(self, action: #selector(refresh), for: .valueChanged)
        
        notificationCenter.removeAllPendingNotificationRequests()
        
        provaider = RealmProvader()
        apiProvider = AlamofireProvaider()
        getCoordinatesByName()
    }
    
    
    @objc private func refresh() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            self.tableView.reloadData()
        }
        refreshControl.endRefreshing()
    }
    
    @IBAction func onLocationButton(_ sender: Any) {
        
        coreManager.requestWhenInUseAuthorization()
        self.blurEffectView.isHidden = false
        self.activityIndicator.startAnimating()
        self.nameCity = currentName
        self.getWeatherByCoordinates(cityLat: Double(currentCoordinate.latitude), cityLon: Double(currentCoordinate.longitude))   
    }
    
    
    
    
    fileprivate func getCoordinatesByName() {
        guard let nameCity = nameCity else {return}
        apiProvider.getCoordinatesByName(name: nameCity) { [weak self] result in
            guard let self = self else {return}
            switch result {
            case .success(let value):
                if let city = value.first {
                    self.nameCity = city.name
                    self.getWeatherByCoordinates(cityLat: city.lat, cityLon: city.lon)
                }
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    }
    
    private func setWeatherNotifications(arrayTime: [Int]) {
        guard let time = arrayTime.first else {return}
        let content = UNMutableNotificationContent()
        content.body = "Weather conditions will worsen soon"
        var date = DateComponents()
        date.hour = Int(time.convertUnix(formattedType: .hour))
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
                self.provaider.setCurrentWeatherQueryList(temp: temp, weather: clouds, time: date)
                self.provaider.setQueryList(lat: lat, lon: lon, time: date)
                
                // MARK: Hourly
                guard let hourly = value.hourly else {return }
                let snow = 600...699
                let rain = 500...599
                let thunderstorm = 200...299
                for item in hourly {
                    guard let hourlyTemp = item.temp, let hourlyDt = item.dt, let weather = item.weather, let icon = weather.first?.icon, let weatherId = weather.first?.id else {return}
                    if let url = URL(string: "https://openweathermap.org/img/wn/\(icon)@2x.png") {
                        do {
                            let data = try Data(contentsOf: url)
                            self.hourlyArrayImage.append(UIImage(data: data)!)
                        } catch _ {
                            print("error")
                        }
                    }
                    self.hourlyArrayDt.append(hourlyDt.convertUnix(formattedType: .hour))
                    self.hourlyArrayTemp.append(hourlyTemp)
                    self.hourlyArrayBadWeatherId.append(weatherId)
                    
                    if snow.contains(weatherId) || rain.contains(weatherId) || thunderstorm.contains(weatherId) {
                        self.hourlyArrayBadWeatherDt.append(hourlyDt - 60 * 30)
                    }
                }
                self.setWeatherNotifications(arrayTime: self.hourlyArrayBadWeatherDt)
                
                // MARK: DAILY
                guard let daily = value.daily else {return }
                
                for item in daily {
                    guard let temp = item.temp, let maxTemp = temp.max, let minTemp = temp.min, let days = item.dt, let weather = item.weather, let icon = weather.first?.icon else {return}
                    
                    if let url = URL(string: "https://openweathermap.org/img/wn/\(icon)@2x.png") {
                        do {
                            let data = try Data(contentsOf: url)
                            self.dailyImageArray.append(UIImage(data: data)!)
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








extension WeatherViewController: CLLocationManagerDelegate {
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        if manager.authorizationStatus == .authorizedAlways || manager.authorizationStatus == .authorizedWhenInUse {
            coreManager.startUpdatingLocation()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
       guard let location = locations.first else {return}
        self.currentCoordinate = location.coordinate
        
        let geocoder = CLGeocoder()
        geocoder.reverseGeocodeLocation(location) { (placemarks, error) in
            if let error = error {
                print("Unable to Reverse Geocode Location (\(error))")
            } else {
                if let placemarks = placemarks, let placemark = placemarks.first {
                    self.currentName = placemark.locality!
                }
            }
        }
        
    }
    
    

}
