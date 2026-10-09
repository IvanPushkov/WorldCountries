
import Foundation


final class APIManager{
    
    private var basicURL = "https://api.restcountries.com/countries/v5"
    private let apiKey = "rc_live_cda58c75421c44fc86eeee77829ec20c"
    
    func fetchAllCountries(complection: @escaping (Countries?, String?) -> Void){
        guard let baseURL = URL(string: basicURL) else{
            fatalError("Wrong URL")
        }
        var urlRequest = URLRequest(url: baseURL)
        urlRequest.setValue(apiKey, forHTTPHeaderField: "Authorization")
        let session = URLSession.shared
        let task = session.dataTask(with: urlRequest){ data, response, error in
            if error != nil {
                DispatchQueue.main.async {
                    complection(nil, "Нет подключения к интернету")
                }
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                print("Invalid response from server")
                return
            }
            
            guard let data = data else {
                DispatchQueue.main.async {
                    complection(nil, "Ошибка сервера")
                }
                return
            }
            
            do {
                let countries = try JSONDecoder().decode(Countries.self, from: data)
                DispatchQueue.main.async {
                    complection(countries, nil)
                }
            } catch {
                print("Failed to decode JSON: \(error)")
            }
            
        }
        task.resume()
    }
    
}
