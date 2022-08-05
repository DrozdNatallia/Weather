//
//  AlamofireProvader.swift
//  home_work_23
//
//  Created by Natalia Drozd on 25.06.22.
//

import Foundation
import Alamofire

class AlamofireProvaider: RestAPIProviderProtocol {
    var key: String? {
        get {
            Bundle.main.infoDictionary?["API_KEY"] as? String
        }
    }
    
    func getCoordinatesByName(name: String, completion: @escaping (Result<[InfoCity], Error>) -> Void) {
        let params = addParams(queryItems: ["q": name])
        
        AF.request(Constants.getCodingURL, method: .get, parameters: params).responseDecodable(of: [InfoCity].self) { response in
            switch response.result {
            case .success(let result):
                completion(.success(result))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    func getWeatherForCityCoordinates(lat: Double, lon: Double, completion: @escaping (Result<WeatherData, Error>) -> Void) {
        var lang = "en"
        if let preferredLanguage = Locale.preferredLanguages.first, preferredLanguage == "ru" {
            lang = preferredLanguage
        }
        let provaider = RealmProvader()
        let listSetting = provaider.getResult(nameObject: RealmSettings.self).last
        let typeSystem = listSetting?.typeSystem ?? false
        let system = typeSystem ? "metric" : "imperial"
        
        let params = addParams(queryItems: ["lat": lat.description, "lon": lon.description, "exlcude":"minutely,alerts", "units" : system, "lang" : lang])

        
        AF.request(Constants.weatherURL, method: .get, parameters: params).responseDecodable(of: WeatherData.self){ response in
            switch response.result {
            case .success(let result):
                completion(.success(result))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    private func addParams(queryItems: [String: String]) -> [String: String] {
        var params: [String: String] = [:]
        params = queryItems
        if let key = key  {
            params["appid"] = "\(key)"
            return params
        }
        return params
    }
}
        
