
import Foundation


final class APIManager{
    
    private var basicURL = "https://api.restcountries.com/countries/v5"
    private let apiKey = "rc_live_cda58c75421c44fc86eeee77829ec20c"
    private let pageSize = 100
    private let requestTimeout: TimeInterval = 30


    private let responseFields = [
        "names.common", "names.official",
        "codes.alpha_2", "codes.alpha_3",
        "flag.emoji",
        "region",
        "capitals.name",
        "population",
        "area.kilometers",
        "currencies.code", "currencies.name", "currencies.symbol",
        "languages.name",
        "timezones",
        "coordinates.lat", "coordinates.lng"
    ].joined(separator: ",")

    private struct PageResponse: Decodable {
        struct PageData: Decodable {
            struct Meta: Decodable {
                let more: Bool?
            }
            let objects: [Country]
            let meta: Meta?
        }
        let data: PageData
    }

    func fetchAllCountries(completion: @escaping (Countries?, String?) -> Void) {
        fetchPage(offset: 0, accumulated: [], completion: completion)
    }

    private func fetchPage(offset: Int,
                           accumulated: [Country],
                           completion: @escaping (Countries?, String?) -> Void) {
        guard var components = URLComponents(string: basicURL) else {
            finish(completion, with: nil, error: "Invalid API URL")
            return
        }
        components.queryItems = [
            URLQueryItem(name: "limit", value: String(pageSize)),
            URLQueryItem(name: "offset", value: String(offset)),
            URLQueryItem(name: "response_fields", value: responseFields)
        ]
        guard let url = components.url else {
            finish(completion, with: nil, error: "Invalid API URL")
            return
        }

        var request = URLRequest(url: url, timeoutInterval: requestTimeout)
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Accept")

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                self.finish(completion, with: nil, error: error.localizedDescription)
                return
            }
            guard let httpResponse = response as? HTTPURLResponse else {
                self.finish(completion, with: nil, error: "Invalid response from server")
                return
            }
            guard httpResponse.statusCode == 200 else {
                self.finish(completion, with: nil, error: "Server error (HTTP \(httpResponse.statusCode))")
                return
            }
            guard let data = data else {
                self.finish(completion, with: nil, error: "Server returned no data")
                return
            }

            do {
                let page = try JSONDecoder().decode(PageResponse.self, from: data)
                let countries = accumulated + page.data.objects
                let hasMore = page.data.meta?.more ?? (page.data.objects.count == self.pageSize)

                if hasMore && !page.data.objects.isEmpty {
                    self.fetchPage(offset: offset + page.data.objects.count,
                                   accumulated: countries,
                                   completion: completion)
                } else {
                    self.finish(completion,
                                with: Countries(data: CountriesData(objects: countries)),
                                error: nil)
                }
            } catch {
                self.finish(completion,
                            with: nil,
                            error: "Failed to decode countries: \(error.localizedDescription)")
            }
        }.resume()
    }

    /// Always reports back on the main queue, exactly once per request chain,
    /// so a failed request can never leave the UI loading forever.
    private func finish(_ completion: @escaping (Countries?, String?) -> Void,
                        with countries: Countries?,
                        error: String?) {
        DispatchQueue.main.async {
            completion(countries, error)
        }
    }
}
