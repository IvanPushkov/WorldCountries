
import Foundation


class APIManager{
    
    
    private var basicURL = "https://restcountries.com/v3.1/"
    
    func fetchAllCountries(complection: @escaping (Countries?, String?) -> Void){
        guard let requestURL = URL(string: "\(basicURL)all") else{
            fatalError("Wrong URL")
        }
        let session = URLSession.shared
        let task = session.dataTask(with: requestURL){ data, response, error in
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
